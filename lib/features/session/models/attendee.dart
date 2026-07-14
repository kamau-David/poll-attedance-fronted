class Attendee {
  final String id;
  final String name;
  final String registrationNumber;
  final DateTime checkedInAt;

  const Attendee({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.checkedInAt,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      checkedInAt: DateTime.parse(json['checkedInAt'] as String),
    );
  }
}