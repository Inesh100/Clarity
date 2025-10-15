class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
    id: m['id'],
    userId: m['userId'],
    title: m['title'],
    content: m['content'],
    createdAt: DateTime.parse(m['createdAt']),
  );
}
