import 'package:flutter/material.dart';
import '../models/medicine_log_model.dart';
import '../viewmodels/medicine_log_vm.dart';
import '../repositories/medicine_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class MedicineLogPage extends StatefulWidget {
  final String userId;
  const MedicineLogPage({super.key, required this.userId});

  @override
  State<MedicineLogPage> createState() => _MedicineLogPageState();
}

class _MedicineLogPageState extends State<MedicineLogPage> {
  final _vm = MedicineLogViewModel();
  final _medRepo = MedicineRepository(); // ✅ instance
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine History")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Daily Logs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: StreamBuilder<List<MedicineLog>>(
              stream: _vm.streamLogs(widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data!.where((log) =>
                    log.scheduledTime.year == _selectedDay.year &&
                    log.scheduledTime.month == _selectedDay.month &&
                    log.scheduledTime.day == _selectedDay.day
                ).toList();

                if (logs.isEmpty) {
                  return const Center(child: Text("No logs for this day"));
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (_, i) {
                    final log = logs[i];

                    IconData icon;
                    Color color;

                    switch (log.status) {
                      case "taken":
                        icon = Icons.check_circle;
                        color = Colors.green;
                        break;
                      case "missed":
                        icon = Icons.cancel;
                        color = Colors.red;
                        break;
                      default:
                        icon = Icons.access_time;
                        color = Colors.orange;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 32),

                        // ✅ Use instance method to get medicine name
                        title: FutureBuilder<String>(
                          future: _medRepo.getMedicineName(log.medicineId),
                          builder: (_, snap) {
                            return Text(
                              snap.data ?? "Loading...",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            );
                          },
                        ),

                        subtitle: Text(
                          "Scheduled: "
                          "${log.scheduledTime.hour.toString().padLeft(2, '0')}:"
                          "${log.scheduledTime.minute.toString().padLeft(2, '0')}",
                        ),

                        trailing: _buildActionButtons(log),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MedicineLog log) {
    if (log.status != "pending") {
      return Text(
        log.status == "taken" ? "✅ Taken" : "❌ Missed",
        style: TextStyle(
          color: log.status == "taken" ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          tooltip: "Mark Taken",
          onPressed: () => _vm.markTaken(log.id),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          tooltip: "Mark Missed",
          onPressed: () => _vm.markMissed(log.id),
        ),
      ],
    );
  }
}
