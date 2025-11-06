class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };

  // Create from Firestore map
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'],
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        photoUrl: m['photoUrl'],
      );

  // ✅ Add copyWith for easy updates
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
