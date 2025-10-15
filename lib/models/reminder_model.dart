class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime dateTime;
  final String repeat; // none,daily,weekly,monthly
  final int? weekday; // for weekly: 1..7

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.dateTime,
    this.repeat = 'none',
    this.weekday,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'dateTime': dateTime.toIso8601String(),
    'repeat': repeat,
    'weekday': weekday,
  };

  factory ReminderModel.fromMap(Map<String, dynamic> m) => ReminderModel(
    id: m['id'],
    userId: m['userId'],
    title: m['title'],
    message: m['message'],
    dateTime: DateTime.parse(m['dateTime']),
    repeat: m['repeat'] ?? 'none',
    weekday: m['weekday'],
  );
}
