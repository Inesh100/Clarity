class Flashcard {
  final String id;
  final String userId;
  final String question;
  final String answer;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'question': question,
    'answer': answer,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Flashcard.fromMap(Map<String, dynamic> m) => Flashcard(
    id: m['id'],
    userId: m['userId'],
    question: m['question'],
    answer: m['answer'],
    createdAt: DateTime.parse(m['createdAt']),
  );
}
