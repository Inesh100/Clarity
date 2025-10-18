class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int hour;
  final int minute;

  Medicine({ required this.id, required this.userId, required this.name, required this.dosage, required this.hour, required this.minute });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'dosage': dosage,
    'hour': hour,
    'minute': minute,
  };

  factory Medicine.fromMap(Map<String, dynamic> m) => Medicine(
    id: m['id'],
    userId: m['userId'],
    name: m['name'],
    dosage: m['dosage'],
    hour: m['hour'],
    minute: m['minute'],
  );
}
