import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommunityModernScreen extends StatelessWidget {
  const CommunityModernScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16),
          decoration: BoxDecoration(
            gradient: AppTheme.appGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.people, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    SizedBox(height: 4),
                    Text('Join discussions • Share notes • Form study groups', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(
                width: 84,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/community/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Post'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white, elevation: 0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          // Quick filters / trending chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All'),
                _FilterChip(label: 'Trending'),
                _FilterChip(label: 'Study Groups'),
                _FilterChip(label: 'AI Help'),
                _FilterChip(label: 'Exams'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Featured post
          _FeaturedPost(
            title: 'Study Group: Calculus - Join us!',
            subtitle: '2 days ago • 12 members',
            excerpt: 'We meet every evening to solve past papers. DM to join the group chat.',
          ),

          const SizedBox(height: 16),

          // List of posts
          _CommunityPost(
            author: 'Sarah Kim',
            time: '2h ago',
            content: 'Just completed the Binary Search Trees quiz! The visualization helped me.',
            likes: 24,
            comments: 8,
          ),
          const SizedBox(height: 12),
          _CommunityPost(
            author: 'Mike Chen',
            time: '4h ago',
            content: 'AI tutor explanation was amazing. Here are my summary notes.',
            likes: 18,
            comments: 5,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/community/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: () {
          if (label == 'Trending') {
            Navigator.of(context).pushNamed('/community/trending');
          }
        },
        label: Text(label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
      ),
    );
  }
}

class _FeaturedPost extends StatelessWidget {
  final String title;
  final String subtitle;
  final String excerpt;
  const _FeaturedPost({required this.title, required this.subtitle, required this.excerpt});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(excerpt, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _CommunityPost extends StatelessWidget {
  final String author;
  final String time;
  final String content;
  final int likes;
  final int comments;

  const _CommunityPost({required this.author, required this.time, required this.content, required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: AppTheme.primary, child: Text(author[0])),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.thumb_up_outlined), onPressed: () {}),
                Text('$likes'),
                const SizedBox(width: 12),
                IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}),
                Text('$comments'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
