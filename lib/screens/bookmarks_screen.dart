import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import 'community_post_detail.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        title: const Text('Bookmarks'),
      ),
      body: Consumer<SocialProvider>(
        builder: (context, social, _) {
          final bookmarked = social.metaEntriesWhereBookmarked();
          if (bookmarked.isEmpty) {
            return Center(
              child: Text(
                'No bookmarks yet',
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: bookmarked.length,
            itemBuilder: (context, i) {
              final item = bookmarked[i];
              return _BookmarkTile(postId: item.id, meta: item.meta, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final String postId;
  final PostMetaView meta;
  final bool isDark;
  const _BookmarkTile({required this.postId, required this.meta, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final social = Provider.of<SocialProvider>(context, listen: false);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityPostDetailScreen(
            postId: postId,
            author: meta.author,
            time: meta.time,
            avatar: meta.avatar,
            content: meta.content,
            likes: social.likeCount(postId),
            comments: social.commentCount(postId),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(meta.avatar, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.author,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF34495E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_remove),
              color: const Color(0xFFF59E0B),
              onPressed: () => social.toggleBookmark(postId),
            ),
          ],
        ),
      ),
    );
  }
}
