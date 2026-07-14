import 'attendee.dart';

class ClassSession {
  final String id;
  final String courseCode;
  final String title;
  final String joinCode;
  final String lecturerName;
  final bool isActive;
  final List<Attendee> attendees;

  const ClassSession({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.joinCode,
    required this.lecturerName,
    required this.isActive,
    required this.attendees,
  });

  ClassSession copyWith({
    bool? isActive,
    List<Attendee>? attendees,
  }) {
    return ClassSession(
      id: id,
      courseCode: courseCode,
      title: title,
      joinCode: joinCode,
      lecturerName: lecturerName,
      isActive: isActive ?? this.isActive,
      attendees: attendees ?? this.attendees,
    );
  }
}