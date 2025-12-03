import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('leaderboards_global')
            .doc('weekly')
            .snapshots(),
        builder: (context, snapshot) {
          final theme = Theme.of(context);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'No leaderboard data yet',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final List<dynamic> leaders = (data['leaders'] ?? []) as List<dynamic>;

          // Map Firestore payload to UI entries
          final entries = <LeaderboardEntry>[];
          for (final l in leaders) {
            if (l is Map<String, dynamic>) {
              entries.add(
                LeaderboardEntry(
                  name: (l['username'] ?? 'Learner') as String,
                  subject: (l['subject'] ?? 'All Subjects') as String,
                  points: (l['xp'] ?? 0) as int,
                  progress: (l['progress'] ?? '') as String,
                  color: const Color(0xFF27AE60),
                ),
              );
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: theme.cardColor,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < 3 && i < entries.length; i++)
                            _buildTopThreeCard(
                              rank: i + 1 == 1 ? 1 : (i + 1 == 2 ? 2 : 3),
                              name: entries[i].name,
                              points: '${entries[i].points}',
                              color: i == 0
                                  ? const Color(0xFFF1C40F)
                                  : i == 1
                                      ? const Color(0xFF95A5A6)
                                      : const Color(0xFFD35400),
                              isTop: i == 0,
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Learners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final rank = index + 4; // after top 3
                    final learner = entries[index + 3];
                    return _buildLeaderboardTile(context, rank: rank, entry: learner);
                  },
                  childCount: entries.length > 3 ? entries.length - 3 : 0,
                ),
              ),
            ],
          );
        },
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

// Data now sourced from Firestore via StreamBuilder above.