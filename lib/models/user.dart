class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.createdAt,
  });

  // ========================================
  // CREAR USUARIO DESDE JSON
  // ========================================

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
