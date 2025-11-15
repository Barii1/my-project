import 'package:flutter/material.dart';
 
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters coming soon')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Top 3 cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTopThreeCard(
                        rank: 2,
                        name: 'Sarah M.',
                        points: '8,750',
                        color: const Color(0xFF95A5A6),
                      ),
                      _buildTopThreeCard(
                        rank: 1,
                        name: 'Alex K.',
                        points: '9,450',
                        color: const Color(0xFFF1C40F),
                        isTop: true,
                      ),
                      _buildTopThreeCard(
                        rank: 3,
                        name: 'Mike R.',
                        points: '8,200',
                        color: const Color(0xFFD35400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Learners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rank = index + 4;
                final learner = _leaderboardEntries[index];
                return _buildLeaderboardTile(context, rank: rank, entry: learner);
              },
              childCount: _leaderboardEntries.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeCard({
    required int rank,
    required String name,
    required String points,
    required Color color,
    bool isTop = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80 + (isTop ? 20 : 0),
          decoration: BoxDecoration(
            color: color.withAlpha(32),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: color, size: 24),
                const SizedBox(height: 4),
                Text('#$rank', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(points, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, {required int rank, required LeaderboardEntry entry}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.color.withAlpha(32),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: entry.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(entry.subject, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.points} pts', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(entry.progress, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final String name;
  final String subject;
  final int points;
  final String progress;
  final Color color;

  const LeaderboardEntry({
    required this.name,
    required this.subject,
    required this.points,
    required this.progress,
    required this.color,
  });
}

final _leaderboardEntries = [
  LeaderboardEntry(
    name: 'David L.',
    subject: 'Computer Science',
    points: 7800,
    progress: '+12% this week',
    color: Color(0xFF27AE60),
  ),
  LeaderboardEntry(
    name: 'Emma S.',
    subject: 'Mathematics',
    points: 7500,
    progress: '+8% this week',
    color: Color(0xFF8E44AD),
  ),
  LeaderboardEntry(
    name: 'James H.',
    subject: 'Physics',
    points: 7200,
    progress: '+15% this week',
    color: Color(0xFF2980B9),
  ),
  LeaderboardEntry(
    name: 'Lisa M.',
    subject: 'Computer Science',
    points: 6900,
    progress: '+5% this week',
    color: Color(0xFFE67E22),
  ),
  LeaderboardEntry(
    name: 'Chris P.',
    subject: 'Mathematics',
    points: 6600,
    progress: '+10% this week',
    color: Color(0xFF16A085),
  ),
];