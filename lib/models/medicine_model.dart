class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final String repeat; // 'none', 'daily', 'weekly'
  final int? weekday;  // 1=Mon ... 7=Sun, only for weekly

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.repeat = 'daily',
    this.weekday,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'hour': hour,
        'minute': minute,
        'repeat': repeat,
        'weekday': weekday,
      };

  factory Medicine.fromMap(Map<String, dynamic> m) => Medicine(
        id: m['id'],
        userId: m['userId'],
        name: m['name'],
        dosage: m['dosage'],
        hour: m['hour'],
        minute: m['minute'],
        repeat: m['repeat'] ?? 'daily',
        weekday: m['weekday'],
      );
}
