import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reminders_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/reminder_model.dart';
import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';
import 'calendar_page.dart'; // ✅ Import the calendar page

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  TimeOfDay time = TimeOfDay.now();
  String repeat = 'daily';
  int? weekday;
  DateTime? monthlyDate;

  Stream<List<Reminder>>? _remindersStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final vm = Provider.of<RemindersViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;
    if (uid != null && _remindersStream == null) {
      _remindersStream = vm.streamReminders(uid);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  Future<void> _pickMonthlyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: monthlyDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => monthlyDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<RemindersViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: uid == null
          ? const Center(child: Text('Sign in to manage reminders'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Time: ${time.format(context)}'),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _pickTime,
                        child: const Text('Pick time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: repeat,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    ],
                    onChanged: (v) => setState(() => repeat = v ?? 'daily'),
                  ),
                  const SizedBox(height: 8),
                  if (repeat == 'weekly')
                    DropdownButton<int>(
                      value: weekday ?? DateTime.now().weekday,
                      items: List.generate(
                        7,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                          ),
                        ),
                      ),
                      onChanged: (v) => setState(() => weekday = v),
                    ),
                  if (repeat == 'monthly')
                    ElevatedButton(
                      onPressed: _pickMonthlyDate,
                      child: Text(
                        monthlyDate == null
                            ? 'Pick a date'
                            : DateFormat('dd/MM/yyyy').format(monthlyDate!),
                      ),
                    ),
                  const SizedBox(height: 8),

                  /// ✅ Row with Add Reminder + Calendar Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty ||
                                descCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter title and description.'),
                                ),
                              );
                              return;
                            }

                            if (repeat == 'weekly' && weekday == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a weekday for weekly reminders.'),
                                ),
                              );
                              return;
                            }

                            if (repeat == 'monthly' && monthlyDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please pick a date for monthly reminders.'),
                                ),
                              );
                              return;
                            }

                            await vm.addReminder(
                              context: context,
                              userId: uid!,
                              title: titleCtrl.text,
                              description: descCtrl.text,
                              hour: time.hour,
                              minute: time.minute,
                              repeat: repeat,
                              weekday: weekday,
                              monthlyDate: monthlyDate,
                            );

                            titleCtrl.clear();
                            descCtrl.clear();
                            monthlyDate = null;
                            weekday = null;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Reminder saved & notification scheduled!',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Reminder'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CalendarPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Calendar'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFADD8E6)),
                            backgroundColor: const Color(0xFFADD8E6)
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Text('Your Reminders', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _remindersStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<Reminder>>(
                            stream: _remindersStream,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final reminders = snap.data!;
                              if (reminders.isEmpty) {
                                return const Center(child: Text('No reminders'));
                              }
                              return ListView.builder(
                                itemCount: reminders.length,
                                itemBuilder: (ctx, i) {
                                  final r = reminders[i];
                                  return ListTile(
                                    title: Text(r.title),
                                    subtitle: Text(
                                      '${r.description} — ${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => vm.deleteReminder(r),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
