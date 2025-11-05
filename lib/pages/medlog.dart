
/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/medicine_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/medicine_model.dart';
import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';

class MedicineLogPage extends StatefulWidget {
  const MedicineLogPage({super.key});

  @override
  State<MedicineLogPage> createState() => _MedicineLogPageState();
}

class _MedicineLogPageState extends State<MedicineLogPage> {
  Stream<List<Medicine>>? _medicinesStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final medVm = Provider.of<MedicineViewModel>(context, listen: false);
    final uid = authVm.firebaseUser?.uid;

    if (uid != null && _medicinesStream == null) {
      _medicinesStream = medVm.streamMedicines(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medVm = Provider.of<MedicineViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final uid = authVm.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Log')),
      body: uid == null
          ? const Center(child: Text('Sign in to view medicine log'))
          : _medicinesStream == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Medicine>>(
                  stream: _medicinesStream,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final meds = snap.data!;
                    if (meds.isEmpty) {
                      return const Center(child: Text('No medicines logged yet'));
                    }

                    return ListView.builder(
                      itemCount: meds.length,
                      itemBuilder: (context, i) {
                        final m = meds[i];

                        // Reverse logs so newest first
                        final reversedLog = m.log.reversed.toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ExpansionTile(
                            title: Text(m.name, style: AppTextStyles.heading2),
                            subtitle: Text(m.dosage),
                            children: reversedLog.isEmpty
                                ? [
                                    const ListTile(
                                      title: Text('No log entries yet'),
                                    )
                                  ]
                                : reversedLog
                                    .map(
                                      (entry) {
                                        final date =
                                            DateTime.parse(entry['date']);
                                        final status =
                                            entry['taken'] ? 'Taken' : 'Missed';
                                        final color = entry['taken']
                                            ? Colors.green
                                            : Colors.red;
                                        return ListTile(
                                          leading: Icon(
                                            entry['taken']
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: color,
                                          ),
                                          title: Text(
                                              '${DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
                                          trailing: Text(
                                            status,
                                            style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      },
                                    )
                                    .toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}

*/