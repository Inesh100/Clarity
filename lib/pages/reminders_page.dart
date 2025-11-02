import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reminders_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/reminder_model.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  DateTime selected = DateTime.now();
  String repeat = 'none';
  int? weekday;
  Stream<List<ReminderModel>>? _reminderStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final vm = Provider.of<RemindersViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;

    if (uid != null && _reminderStream == null) {
      _reminderStream = vm.streamReminders(uid);
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selected),
    );
    if (pickedTime == null) return;

    setState(() {
      selected = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
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
                    controller: messageCtrl,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('When: ${DateFormat.yMd().add_jm().format(selected)}'),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _pickDateTime,
                        child: const Text('Pick date/time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: repeat,
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No repeat')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    ],
                    onChanged: (v) => setState(() => repeat = v ?? 'none'),
                  ),
                  if (repeat == 'weekly')
                    DropdownButton<int>(
                      value: weekday ?? DateTime.now().weekday,
                      items: List.generate(
                        7,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i]),
                        ),
                      ),
                      onChanged: (v) => setState(() => weekday = v),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty || messageCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a title and message.')),
                        );
                        return;
                      }

                      await vm.addReminder(
                        userId: uid!,
                        title: titleCtrl.text,
                        message: messageCtrl.text,
                        dateTime: selected,
                        repeat: repeat,
                        weekday: weekday,
                      );

                      titleCtrl.clear();
                      messageCtrl.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Reminder saved & notification scheduled!')),
                      );
                    },
                    child: const Text('Save reminder'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Your Reminders', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _reminderStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<ReminderModel>>(
                            stream: _reminderStream,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final items = snap.data!;
                              if (items.isEmpty) return const Center(child: Text('No reminders'));
                              return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (ctx, i) {
                                  final r = items[i];
                                  return ListTile(
                                    title: Text(r.title),
                                    subtitle: Text(DateFormat.yMd().add_jm().format(r.dateTime)),
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
