import 'package:flutter/material.dart';

class DiscoveryVoteRail extends StatelessWidget {
  const DiscoveryVoteRail({
    super.key,
    required this.voteScore,
    required this.currentDeviceVote,
    required this.onVoteUp,
    required this.onVoteDown,
    this.votePending = false,
  });

  final int voteScore;
  final int? currentDeviceVote;
  final VoidCallback onVoteUp;
  final VoidCallback onVoteDown;
  final bool votePending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 60,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: currentDeviceVote == 1 ? 'Remove upvote' : 'Vote up',
              onPressed: votePending ? null : onVoteUp,
              icon: Icon(
                currentDeviceVote == 1
                    ? Icons.thumb_up_alt
                    : Icons.thumb_up_alt_outlined,
                color: currentDeviceVote == 1
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            votePending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '$voteScore',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: voteScore < 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: currentDeviceVote == -1
                  ? 'Remove downvote'
                  : 'Vote down',
              onPressed: votePending ? null : onVoteDown,
              icon: Icon(
                currentDeviceVote == -1
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined,
                color: currentDeviceVote == -1
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
