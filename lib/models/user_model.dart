class UserModel {
  final String id;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}
