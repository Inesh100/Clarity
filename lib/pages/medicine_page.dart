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

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final vm = Provider.of<MedicineViewModel>(context);
    final uid = authVm.firebaseUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Schedule')),
      body: uid == null ? const Center(child: Text('Sign in to manage medicines')) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine name')),
          TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage info')),
          const SizedBox(height: 8),
          Row(children: [
            Text('Time: ${time.format(context)}'),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () async {
              final picked = await showTimePicker(context: context, initialTime: time);
              if (picked != null) setState(() => time = picked);
            }, child: const Text('Pick time')),
          ]),
          ElevatedButton(onPressed: () {
            vm.addMedicine(userId: uid, name: nameCtrl.text, dosage: dosageCtrl.text, hour: time.hour, minute: time.minute);
            nameCtrl.clear(); dosageCtrl.clear();
          }, child: const Text('Add medicine')),
          const SizedBox(height: 12),
          const Text('Your medicines', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Expanded(child: StreamBuilder<List<Medicine>>(
            stream: vm.streamMedicines(uid),
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
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => vm.deleteMedicine(m.id)),
                  );
                }
              );
            }
          )),
        ]),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
