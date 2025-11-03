import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/medicine_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/medicine_model.dart';
import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  TimeOfDay time = TimeOfDay.now();
  String repeat = 'daily';
  int? weekday;
  int? weekOfMonth;
  Stream<List<Medicine>>? _medicinesStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final vm = Provider.of<MedicineViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;
    if (uid != null && _medicinesStream == null) {
      _medicinesStream = vm.streamMedicines(uid);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<MedicineViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Schedule')),
      body: uid == null
          ? const Center(child: Text('Sign in to manage medicines'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Medicine name'),
                  ),
                  TextField(
                    controller: dosageCtrl,
                    decoration: const InputDecoration(labelText: 'Dosage info'),
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

                  // Weekday picker for weekly/monthly
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

                  // Week of month picker for monthly
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
                      if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter medicine name and dosage.')),
                        );
                        return;
                      }

                      await vm.addMedicine(
                        userId: uid!,
                        name: nameCtrl.text,
                        dosage: dosageCtrl.text,
                        hour: time.hour,
                        minute: time.minute,
                        repeat: repeat,
                        weekday: weekday,
                        weekOfMonth: weekOfMonth,
                      );

                      nameCtrl.clear();
                      dosageCtrl.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Medicine saved & notification scheduled!')),
                      );
                    },
                    child: const Text('Add medicine'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Your Medicines', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _medicinesStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<Medicine>>(
                            stream: _medicinesStream,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final meds = snap.data!;
                              if (meds.isEmpty) return const Center(child: Text('No medicines'));
                              return ListView.builder(
                                itemCount: meds.length,
                                itemBuilder: (ctx, i) {
                                  final m = meds[i];
                                  return ListTile(
                                    title: Text(m.name),
                                    subtitle: Text('${m.dosage} — ${m.hour.toString().padLeft(2,'0')}:${m.minute.toString().padLeft(2,'0')}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => vm.deleteMedicine(m),
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
