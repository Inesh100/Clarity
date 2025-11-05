// models/medicine_model.dart
class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int hour;
  final int minute;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'hour': hour,
        'minute': minute,
      };

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        dosage: map['dosage'] as String,
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      );
}
