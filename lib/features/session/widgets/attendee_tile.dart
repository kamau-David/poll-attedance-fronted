import 'package:flutter/material.dart';
import '../models/attendee.dart';

class AttendeeTile extends StatelessWidget {
  final Attendee attendee;

  const AttendeeTile({super.key, required this.attendee});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${attendee.checkedInAt.hour.toString().padLeft(2, '0')}:${attendee.checkedInAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            attendee.name.isNotEmpty ? attendee.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(
          attendee.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(attendee.registrationNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: Colors.greenAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}