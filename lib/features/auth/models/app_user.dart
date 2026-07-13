enum UserRole { lecturer, student }

class AppUser {
  final String id;
  final String name;
  final String registrationNumber;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String? ?? '',
      role: json['role'] == 'lecturer' ? UserRole.lecturer : UserRole.student,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registrationNumber': registrationNumber,
      'role': role.name,
    };
  }
}