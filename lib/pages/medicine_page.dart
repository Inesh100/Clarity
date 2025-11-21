import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/medicine_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/medicine_model.dart';
import '../styles/app_text.dart';
import '../styles/app_colors.dart';
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
  DateTime? monthlyDate;

  Stream<List<Medicine>>? _medicinesStream;
  String? uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    uid = authVm.firebaseUser?.uid;

    if (uid != null && _medicinesStream == null) {
      final vm = Provider.of<MedicineViewModel>(context, listen: false);
      _medicinesStream = vm.streamMedicines(uid!);
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
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => monthlyDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MedicineViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Schedule')),
      body: uid == null
          ? Center(
              child: Text('Sign in to manage medicines', style: AppTextStyles.body),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Medicine name',
                      labelStyle: AppTextStyles.body,
                    ),
                  ),
                  TextField(
                    controller: dosageCtrl,
                    decoration: InputDecoration(
                      labelText: 'Dosage info',
                      labelStyle: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Time picker
                  Row(
                    children: [
                      Text('Time: ${time.format(context)}', style: AppTextStyles.body),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _pickTime,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Pick time', style: AppTextStyles.buttonText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Repeat dropdown
                  DropdownButtonFormField<String>(
                    value: repeat,
                    decoration: const InputDecoration(),
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
                          child: Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i]),
                        ),
                      ),
                      onChanged: (v) => setState(() => weekday = v),
                    ),

                  if (repeat == 'monthly')
                    ElevatedButton(
                      onPressed: _pickMonthlyDate,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: Text(
                        monthlyDate == null
                            ? 'Pick a date'
                            : DateFormat('dd/MM/yyyy').format(monthlyDate!),
                        style: AppTextStyles.buttonText,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Add medicine button
                  ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter medicine name and dosage.')),
                        );
                        return;
                      }

                      if (repeat == 'weekly' && weekday == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a weekday for weekly medicine.')),
                        );
                        return;
                      }

                      if (repeat == 'monthly' && monthlyDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please pick a date for monthly medicine.')),
                        );
                        return;
                      }

                      await vm.addMedicine(
                        context: context,
                        userId: uid!,
                        name: nameCtrl.text,
                        dosage: dosageCtrl.text,
                        hour: time.hour,
                        minute: time.minute,
                        repeat: repeat,
                        weekday: weekday,
                        monthlyDate: monthlyDate,
                      );

                      nameCtrl.clear();
                      dosageCtrl.clear();
                      monthlyDate = null;
                      weekday = null;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Medicine saved & notification scheduled!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Add medicine', style: AppTextStyles.buttonText),
                  ),
                  const SizedBox(height: 12),
                  Text('Your Medicines', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),

                  // Medicine list
                  Expanded(
                    child: _medicinesStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<Medicine>>(
                            stream: _medicinesStream,
                            builder: (context, snap) {
                              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                              final meds = snap.data!;
                              if (meds.isEmpty) return const Center(child: Text('No medicines', style: AppTextStyles.body));
                              return ListView.builder(
                                itemCount: meds.length,
                                itemBuilder: (ctx, i) {
                                  final m = meds[i];
                                  return ListTile(
                                    title: Text(m.name, style: AppTextStyles.body),
                                    subtitle: Text(
                                        '${m.dosage} — ${m.hour.toString().padLeft(2,'0')}:${m.minute.toString().padLeft(2,'0')}',
                                        style: AppTextStyles.small),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: AppColors.danger),
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
