class PollOption {
  final String id;
  final String text;
  final int votes;

  const PollOption({
    required this.id,
    required this.text,
    required this.votes,
  });

  PollOption copyWith({int? votes}) {
    return PollOption(
      id: id,
      text: text,
      votes: votes ?? this.votes,
    );
  }
}

class Poll {
  final String id;
  final String sessionJoinCode;
  final String question;
  final bool isOpen;
  final List<PollOption> options;

  const Poll({
    required this.id,
    required this.sessionJoinCode,
    required this.question,
    required this.isOpen,
    required this.options,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);

  Poll copyWith({
    bool? isOpen,
    List<PollOption>? options,
  }) {
    return Poll(
      id: id,
      sessionJoinCode: sessionJoinCode,
      question: question,
      isOpen: isOpen ?? this.isOpen,
      options: options ?? this.options,
    );
  }
}