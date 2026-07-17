import 'package:flutter/material.dart';
import '../models/poll.dart';

class PollOptionCard extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool isSelected;
  final bool canVote;
  final VoidCallback onTap;

  const PollOptionCard({
    super.key,
    required this.option,
    required this.totalVotes,
    required this.isSelected,
    required this.canVote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fraction = totalVotes == 0 ? 0.0 : option.votes / totalVotes;
    final percentage = (fraction * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canVote ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181E29),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primary
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      color: primary.withValues(alpha: isSelected ? 0.28 : 0.15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? primary : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percentage% (${option.votes})',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primary : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}