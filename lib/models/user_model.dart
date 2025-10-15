class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  AppUser({required this.id, required this.name, required this.email, this.photoUrl});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'],
    name: m['name'] ?? '',
    email: m['email'] ?? '',
    photoUrl: m['photoUrl'],
  );
}
