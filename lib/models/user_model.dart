class UserProfile {
  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['auth_id'] as String? ?? '',
      role: json['role'] as String? ?? 'student', 
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
