import 'package:flutter/foundation.dart';

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int hour;
  final int minute;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'hour': hour,
        'minute': minute,
      };

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        id: map['id'],
        userId: map['userId'],
        title: map['title'],
        description: map['description'],
        hour: map['hour'],
        minute: map['minute'],
      );
}
