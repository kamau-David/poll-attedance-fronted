import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/models/app_user.dart';
import '../../auth/screens/login_screen.dart';
import '../../poll/screens/live_poll_room_screen.dart';
import '../models/class_session.dart';
import '../services/mock_session_service.dart';
import '../widgets/attendee_tile.dart';
import '../widgets/session_code_banner.dart';

class LecturerDashboardScreen extends StatefulWidget {
  final AppUser user;

  const LecturerDashboardScreen({super.key, required this.user});

  @override
  State<LecturerDashboardScreen> createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  final _sessionService = MockSessionService();
  final _courseController = TextEditingController(text: 'CCS 3304');
  final _titleController =
      TextEditingController(text: 'Mobile App Architecture');

  ClassSession? _activeSession;
  StreamSubscription<ClassSession>? _sub;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _sub = _sessionService.sessionStream.listen((updated) {
      if (_activeSession != null && updated.joinCode == _activeSession!.joinCode) {
        setState(() => _activeSession = updated);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _courseController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_courseController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty) {
      return;
    }

    setState(() => _creating = true);
    final session = await _sessionService.createSession(
      courseCode: _courseController.text,
      title: _titleController.text,
      lecturer: widget.user,
    );
    if (!mounted) return;
    setState(() {
      _activeSession = session;
      _creating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Host: ${widget.user.name}'),
        actions: [
          IconButton(
            tooltip: 'Switch User',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _activeSession == null
            ? _buildCreateSessionForm()
            : _buildActiveSessionView(),
      ),
    );
  }

  Widget _buildCreateSessionForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Start New Class Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate a join code for students to check in and vote.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Lecture Topic',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _creating ? null : _startSession,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Launch Attendance & Poll Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSessionView() {
    final session = _activeSession!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SessionCodeBanner(session: session),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LivePollRoomScreen(
                        session: session,
                        user: widget.user,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.poll_rounded),
                label: const Text('Open Live Poll'),
              ),
            ),
            const SizedBox(width: 10),
            if (session.isActive)
              OutlinedButton(
                onPressed: () => _sessionService.closeSession(session.joinCode),
                child: const Text('End Session'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'Checked-In Students',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Chip(
              label: Text('${session.attendees.length} Present'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: session.attendees.isEmpty
              ? Center(
                  child: Text(
                    'Waiting for students to join with code ${session.joinCode}...',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                )
              : ListView.builder(
                  itemCount: session.attendees.length,
                  itemBuilder: (_, index) =>
                      AttendeeTile(attendee: session.attendees[index]),
                ),
        ),
      ],
    );
  }
}