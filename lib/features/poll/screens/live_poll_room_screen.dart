import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/models/app_user.dart';
import '../../session/models/class_session.dart';
import '../models/poll.dart';
import '../services/mock_poll_service.dart';
import '../widgets/poll_option_card.dart';

class LivePollRoomScreen extends StatefulWidget {
  final ClassSession session;
  final AppUser user;

  const LivePollRoomScreen({
    super.key,
    required this.session,
    required this.user,
  });

  @override
  State<LivePollRoomScreen> createState() => _LivePollRoomScreenState();
}

class _LivePollRoomScreenState extends State<LivePollRoomScreen> {
  final _pollService = MockPollService();
  Poll? _activePoll;
  String? _selectedOptionId;
  StreamSubscription<Poll>? _sub;

  @override
  void initState() {
    super.initState();
    _activePoll = _pollService.getActivePoll(widget.session.joinCode);
    if (_activePoll != null) {
      _selectedOptionId = _pollService.getUserSelectedOption(
        _activePoll!.id,
        widget.user.id,
      );
    }

    _sub = _pollService.pollStream.listen((poll) {
      if (poll.sessionJoinCode == widget.session.joinCode) {
        setState(() {
          _activePoll = poll;
          _selectedOptionId = _pollService.getUserSelectedOption(
            poll.id,
            widget.user.id,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _vote(String optionId) async {
    final updated = await _pollService.submitVote(
      sessionJoinCode: widget.session.joinCode,
      userId: widget.user.id,
      optionId: optionId,
    );
    if (!mounted) return;
    setState(() {
      _activePoll = updated;
      _selectedOptionId = optionId;
    });
  }

  Future<void> _showCreatePollDialog() async {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Launch New Poll'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionCtrl,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: opt1Ctrl,
                decoration: const InputDecoration(labelText: 'Option 1'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: opt2Ctrl,
                decoration: const InputDecoration(labelText: 'Option 2'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: opt3Ctrl,
                decoration:
                    const InputDecoration(labelText: 'Option 3 (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final options = [opt1Ctrl.text, opt2Ctrl.text, opt3Ctrl.text]
                  .where((t) => t.trim().isNotEmpty)
                  .toList();
              if (questionCtrl.text.trim().isEmpty || options.length < 2) {
                return;
              }
              Navigator.pop(ctx);
              await _pollService.createPoll(
                sessionJoinCode: widget.session.joinCode,
                question: questionCtrl.text,
                optionTexts: options,
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLecturer = widget.user.role == UserRole.lecturer;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.session.courseCode} • Live Poll'),
        actions: [
          if (isLecturer)
            IconButton(
              tooltip: 'New Poll',
              icon: const Icon(Icons.add_chart_rounded),
              onPressed: _showCreatePollDialog,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _activePoll == null
            ? _buildEmptyState(isLecturer)
            : _buildPollView(_activePoll!, isLecturer),
      ),
    );
  }

  Widget _buildEmptyState(bool isLecturer) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.poll_outlined, size: 56, color: Colors.white38),
          const SizedBox(height: 12),
          Text(
            isLecturer
                ? 'No poll running yet. Launch one for your class.'
                : 'Attendance confirmed! Waiting for lecturer to launch a poll...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          if (isLecturer) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showCreatePollDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Poll'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPollView(Poll poll, bool isLecturer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(poll.isOpen ? 'VOTING OPEN' : 'POLL CLOSED'),
                    ),
                    const Spacer(),
                    Text(
                      '${poll.totalVotes} votes',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: poll.options.length,
            itemBuilder: (_, index) {
              final opt = poll.options[index];
              return PollOptionCard(
                option: opt,
                totalVotes: poll.totalVotes,
                isSelected: _selectedOptionId == opt.id,
                canVote: poll.isOpen && !isLecturer,
                onTap: () => _vote(opt.id),
              );
            },
          ),
        ),
        if (isLecturer && poll.isOpen)
          OutlinedButton.icon(
            onPressed: () => _pollService.closePoll(widget.session.joinCode),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Close Poll'),
          ),
      ],
    );
  }
}