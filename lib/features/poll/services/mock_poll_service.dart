import 'dart:async';
import 'dart:math';
import '../models/poll.dart';

class MockPollService {
  static final MockPollService _instance = MockPollService._internal();
  factory MockPollService() => _instance;
  MockPollService._internal() {
    _seedDemoPoll();
  }

  final Map<String, Poll> _pollsBySession = {};
  final Map<String, String> _userVotes = {}; // key: "pollId_userId" -> optionId
  final _pollController = StreamController<Poll>.broadcast();
  Timer? _demoVoteTimer;

  Stream<Poll> get pollStream => _pollController.stream;

  void _seedDemoPoll() {
    _pollsBySession['CS304A'] = const Poll(
      id: 'poll_demo_1',
      sessionJoinCode: 'CS304A',
      question: 'Which transport layer should we use for real-time updates?',
      isOpen: true,
      options: [
        PollOption(id: 'opt_1', text: 'WebSockets (Socket.io)', votes: 9),
        PollOption(id: 'opt_2', text: 'HTTP Short Polling', votes: 2),
        PollOption(id: 'opt_3', text: 'Server-Sent Events (SSE)', votes: 4),
      ],
    );
  }

  Poll? getActivePoll(String sessionJoinCode) {
    return _pollsBySession[sessionJoinCode];
  }

  String? getUserSelectedOption(String pollId, String userId) {
    return _userVotes['${pollId}_$userId'];
  }

  Future<Poll> createPoll({
    required String sessionJoinCode,
    required String question,
    required List<String> optionTexts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final poll = Poll(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      sessionJoinCode: sessionJoinCode,
      question: question.trim(),
      isOpen: true,
      options: [
        for (int i = 0; i < optionTexts.length; i++)
          PollOption(
            id: 'opt_${i}_${DateTime.now().millisecondsSinceEpoch}',
            text: optionTexts[i].trim(),
            votes: 0,
          ),
      ],
    );
    _pollsBySession[sessionJoinCode] = poll;
    _pollController.add(poll);
    _simulateClassVotes(sessionJoinCode);
    return poll;
  }

  Future<Poll> submitVote({
    required String sessionJoinCode,
    required String userId,
    required String optionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = _pollsBySession[sessionJoinCode];
    if (current == null || !current.isOpen) {
      throw Exception('Poll is closed.');
    }

    final voteKey = '${current.id}_$userId';
    final previousOptionId = _userVotes[voteKey];
    if (previousOptionId == optionId) return current;

    final updatedOptions = current.options.map((opt) {
      if (opt.id == optionId) return opt.copyWith(votes: opt.votes + 1);
      if (opt.id == previousOptionId) {
        return opt.copyWith(votes: (opt.votes - 1).clamp(0, 9999));
      }
      return opt;
    }).toList();

    _userVotes[voteKey] = optionId;
    final updated = current.copyWith(options: updatedOptions);
    _pollsBySession[sessionJoinCode] = updated;
    _pollController.add(updated);
    return updated;
  }

  void closePoll(String sessionJoinCode) {
    _demoVoteTimer?.cancel();
    final current = _pollsBySession[sessionJoinCode];
    if (current != null) {
      final closed = current.copyWith(isOpen: false);
      _pollsBySession[sessionJoinCode] = closed;
      _pollController.add(closed);
    }
  }

  void _simulateClassVotes(String sessionJoinCode) {
    _demoVoteTimer?.cancel();
    final rand = Random();
    int ticks = 0;

    _demoVoteTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      ticks++;
      final current = _pollsBySession[sessionJoinCode];
      if (current == null || !current.isOpen || ticks > 8) {
        timer.cancel();
        return;
      }
      final targetIndex = rand.nextInt(current.options.length);
      final updatedOptions = [
        for (int i = 0; i < current.options.length; i++)
          if (i == targetIndex)
            current.options[i].copyWith(votes: current.options[i].votes + 1)
          else
            current.options[i]
      ];
      final updated = current.copyWith(options: updatedOptions);
      _pollsBySession[sessionJoinCode] = updated;
      _pollController.add(updated);
    });
  }
}