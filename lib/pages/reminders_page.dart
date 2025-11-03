import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reminders_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/reminder_model.dart';
import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';

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
  int? weekOfMonth;
  Stream<List<Reminder>>? _remindersStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final vm = Provider.of<ReminderViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;
    if (uid != null && _remindersStream == null) {
      _remindersStream = vm.streamReminders(uid);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<ReminderViewModel>(context);
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
                  if (repeat == 'weekly' || repeat == 'monthly') 
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
                  if (repeat == 'monthly')
                    DropdownButton<int>(
                      value: weekOfMonth ?? 1,
                      items: List.generate(
                        5,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}${i == 0 ? 'st' : i == 1 ? 'nd' : i == 2 ? 'rd' : 'th'} week'),
                        ),
                      ),
                      onChanged: (v) => setState(() => weekOfMonth = v),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter title and description.')),
                        );
                        return;
                      }

                      await vm.addReminder(
                        userId: uid!,
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        hour: time.hour,
                        minute: time.minute,
                        repeat: repeat,
                        weekday: weekday,
                        weekOfMonth: weekOfMonth,
                      );

                      titleCtrl.clear();
                      descCtrl.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Reminder saved & notification scheduled!')),
                      );
                    },
                    child: const Text('Add Reminder'),
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
                              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                              final reminders = snap.data!;
                              if (reminders.isEmpty) return const Center(child: Text('No reminders'));
                              return ListView.builder(
                                itemCount: reminders.length,
                                itemBuilder: (ctx, i) {
                                  final r = reminders[i];
                                  return ListTile(
                                    title: Text(r.title),
                                    subtitle: Text('${r.description} — ${r.hour.toString().padLeft(2,'0')}:${r.minute.toString().padLeft(2,'0')}'),
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
