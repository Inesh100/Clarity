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
  late Stream<List<Medicine>> _medicinesStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final vm = Provider.of<MedicineViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;
    if (uid != null) {
      _medicinesStream = vm.streamMedicines(uid);
    }
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
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: time);
                          if (picked != null) setState(() => time = picked);
                        },
                        child: const Text('Pick time'),
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
                    onChanged: (v) => setState(() => repeat = v ?? 'daily'),
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
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter medicine name and dosage.')),
                        );
                        return;
                      }

                      // Call ViewModel to add medicine and schedule notification
                      vm.addMedicine(
                        userId: uid,
                        name: nameCtrl.text,
                        dosage: dosageCtrl.text,
                        hour: time.hour,
                        minute: time.minute,
                        repeat: repeat,
                        weekday: weekday,
                      );

                      nameCtrl.clear();
                      dosageCtrl.clear();
                    },
                    child: const Text('Add medicine'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Your medicines', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<Medicine>>(
                      stream: _medicinesStream,
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
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
                                onPressed: () => vm.deleteMedicine(m.id),
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
