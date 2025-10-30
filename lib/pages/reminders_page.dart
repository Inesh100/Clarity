import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reminders_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/reminder_model.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';
import 'package:intl/intl.dart';

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
  void initState() {
    super.initState();
    // delay stream init until after first frame so context/providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final vm = Provider.of<RemindersViewModel>(context, listen: false);
      final uid = authVm.firebaseUser?.uid;
      if (uid != null) {
        setState(() {
          _reminderStream = vm.streamReminders(uid);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    if (uid == null || _reminderStream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final vm = Provider.of<RemindersViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Padding(
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
                  onPressed: () async {
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
                  },
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
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
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
                    child: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]),
                  ),
                ),
                onChanged: (v) => setState(() => weekday = v),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                vm.addReminder(
                  userId: uid,
                  title: titleCtrl.text,
                  message: messageCtrl.text,
                  dateTime: selected,
                  repeat: repeat,
                  weekday: weekday,
                );
                titleCtrl.clear();
                messageCtrl.clear();
              },
              child: const Text('Save reminder'),
            ),
            const SizedBox(height: 12),
            const Text('Your Reminders', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            // isolated StreamBuilder widget
            Expanded(
              child: ReminderList(stream: _reminderStream!),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}

// Separate widget isolates StreamBuilder from parent rebuilds
class ReminderList extends StatelessWidget {
  final Stream<List<ReminderModel>> stream;
  const ReminderList({required this.stream, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RemindersViewModel>(context, listen: false);

    return StreamBuilder<List<ReminderModel>>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

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
                onPressed: () => vm.deleteReminder(r.id),
              ),
            );
          },
        );
      },
    );
  }
}
