import 'package:flutter/material.dart';
import '../models/medicine_log_model.dart';
import '../viewmodels/medicine_log_vm.dart';
import '../repositories/medicine_repository.dart';
import 'package:table_calendar/table_calendar.dart';
import '../styles/app_colors.dart';
import '../styles/app_text.dart';

class MedicineLogPage extends StatefulWidget {
  final String userId;
  const MedicineLogPage({super.key, required this.userId});

  @override
  State<MedicineLogPage> createState() => _MedicineLogPageState();
}

class _MedicineLogPageState extends State<MedicineLogPage> {
  final _vm = MedicineLogViewModel();
  final _medRepo = MedicineRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine History"),
        backgroundColor: theme.primaryColor,
      ),
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: theme.colorScheme.onPrimary),
              selectedTextStyle:
                  TextStyle(color: theme.colorScheme.onSecondary),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle:
                  AppTextStyles.heading2.copyWith(color: theme.colorScheme.onBackground),
              formatButtonVisible: false,
            ),
          ),

          const SizedBox(height: 10),
          Text(
            "Daily Logs",
            style: AppTextStyles.heading2.copyWith(
                color: theme.colorScheme.onBackground),
          ),

          Expanded(
            child: StreamBuilder<List<MedicineLog>>(
              stream: _vm.streamLogs(widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data!
                    .where((log) =>
                        log.scheduledTime.year == _selectedDay.year &&
                        log.scheduledTime.month == _selectedDay.month &&
                        log.scheduledTime.day == _selectedDay.day)
                    .toList();

                if (logs.isEmpty) {
                  return Center(
                    child: Text(
                      "No logs for this day",
                      style: AppTextStyles.body.copyWith(
                          color: theme.colorScheme.onBackground),
                    ),
                  );
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
                      color: theme.cardColor,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 32),

                        title: FutureBuilder<String>(
                          future: _medRepo.getMedicineName(log.medicineId),
                          builder: (_, snap) {
                            return Text(
                              snap.data ?? "Loading...",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onBackground,
                              ),
                            );
                          },
                        ),

                        subtitle: Text(
                          "Scheduled: "
                          "${log.scheduledTime.hour.toString().padLeft(2, '0')}:"
                          "${log.scheduledTime.minute.toString().padLeft(2, '0')}",
                          style: AppTextStyles.body.copyWith(
                              color: theme.colorScheme.onBackground),
                        ),

                        trailing: _buildActionButtons(log, theme),
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

  Widget _buildActionButtons(MedicineLog log, ThemeData theme) {
    if (log.status != "pending") {
      return Text(
        log.status == "taken" ? "✅ Taken" : "❌ Missed",
        style: AppTextStyles.body.copyWith(
          color: log.status == "taken" ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          tooltip: "Mark Taken",
          onPressed: () => _vm.markTaken(log.id),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          tooltip: "Mark Missed",
          onPressed: () => _vm.markMissed(log.id),
        ),
      ],
    );
  }
}
