import 'dart:async';
import 'dart:math';
import '../../auth/models/app_user.dart';
import '../models/attendee.dart';
import '../models/class_session.dart';

class MockSessionService {
  // Singleton so lecturer and student screens share mock state in memory
  static final MockSessionService _instance = MockSessionService._internal();
  factory MockSessionService() => _instance;
  MockSessionService._internal() {
    _seedDemoSession();
  }

  final Map<String, ClassSession> _sessionsByCode = {};
  final _sessionController = StreamController<ClassSession>.broadcast();
  Timer? _demoCheckInTimer;

  Stream<ClassSession> get sessionStream => _sessionController.stream;

  void _seedDemoSession() {
    const demoCode = 'CS304A';
    _sessionsByCode[demoCode] = ClassSession(
      id: 'sess_demo_1',
      courseCode: 'CCS 3304',
      title: 'Distributed Systems & APIs',
      joinCode: demoCode,
      lecturerName: 'Dr. Wanjiku',
      isActive: true,
      attendees: [
        Attendee(
          id: 'att_1',
          name: 'Faith Mutua',
          registrationNumber: 'CS/0019/24',
          checkedInAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        Attendee(
          id: 'att_2',
          name: 'Brian Ochieng',
          registrationNumber: 'CS/0084/24',
          checkedInAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
    );
  }

  Future<ClassSession> createSession({
    required String courseCode,
    required String title,
    required AppUser lecturer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final code = _generateCode();
    final session = ClassSession(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      courseCode: courseCode.trim().toUpperCase(),
      title: title.trim(),
      joinCode: code,
      lecturerName: lecturer.name,
      isActive: true,
      attendees: [],
    );
    _sessionsByCode[code] = session;
    _startSimulatingIncomingStudents(code);
    return session;
  }

  Future<ClassSession> joinSession({
    required String joinCode,
    required AppUser student,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final normalized = joinCode.trim().toUpperCase();
    final existing = _sessionsByCode[normalized];

    if (existing == null) {
      throw Exception('Invalid class code. Try demo code: CS304A');
    }
    if (!existing.isActive) {
      throw Exception('This attendance session has already closed.');
    }

    final alreadyCheckedIn = existing.attendees.any(
      (a) => a.registrationNumber == student.registrationNumber,
    );

    if (alreadyCheckedIn) return existing;

    final updated = existing.copyWith(
      attendees: [
        Attendee(
          id: student.id,
          name: student.name,
          registrationNumber: student.registrationNumber,
          checkedInAt: DateTime.now(),
        ),
        ...existing.attendees,
      ],
    );
    _sessionsByCode[normalized] = updated;
    _sessionController.add(updated);
    return updated;
  }

  void closeSession(String joinCode) {
    _demoCheckInTimer?.cancel();
    final existing = _sessionsByCode[joinCode];
    if (existing != null) {
      final closed = existing.copyWith(isActive: false);
      _sessionsByCode[joinCode] = closed;
      _sessionController.add(closed);
    }
  }

  // Simulates classmates checking in every few seconds for live UI testing
  void _startSimulatingIncomingStudents(String joinCode) {
    _demoCheckInTimer?.cancel();
    final sampleStudents = [
      ('Mercy Chebet', 'CS/0112/24'),
      ('Kevin Mwangi', 'CS/0045/24'),
      ('Amina Hassan', 'CS/0078/24'),
      ('Ian Kiprop', 'CS/0156/24'),
    ];
    int index = 0;

    _demoCheckInTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (index >= sampleStudents.length) {
        timer.cancel();
        return;
      }
      final current = _sessionsByCode[joinCode];
      if (current == null || !current.isActive) {
        timer.cancel();
        return;
      }
      final (name, reg) = sampleStudents[index++];
      final updated = current.copyWith(
        attendees: [
          Attendee(
            id: 'sim_$index',
            name: name,
            registrationNumber: reg,
            checkedInAt: DateTime.now(),
          ),
          ...current.attendees,
        ],
      );
      _sessionsByCode[joinCode] = updated;
      _sessionController.add(updated);
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}