// Legacy community screen disabled.
// Replaced with a harmless stub to avoid analyzer errors.
import 'package:flutter/widgets.dart';

/// Deprecated legacy screen kept as a no-op to satisfy imports.
class CommunityModernOld extends StatelessWidget {
  const CommunityModernOld({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/*

                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.people_alt_outlined,
                            label: 'Friends',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendsScreen(),
                                ),
                              );
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.person_add_alt_1,
                            label: 'Add Friend',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddFriendScreen(),
                                ),
                              );
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.bookmarks_outlined,
                            label: 'Bookmarks',
                            color: const Color(0xFFEC4899),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookmarksScreen(),
                                ),
                              );
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Posts Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_loading) ...[
                      const _PostSkeleton(),
                      const SizedBox(height: 12),
                      const _PostSkeleton(),
                      const SizedBox(height: 12),
                      const _PostSkeleton(),
                    ] else ...[
                      _CommunityPost(
                      postId: 'post1',
                      author: 'Alex Morgan',
                      time: '3h ago',
                      avatar: '🎓',
                      content: 'Just aced my Algorithms exam! The dynamic programming section on this app really helped. Thank you! 💯',
                      comments: 12,
                      hasImage: false,
                    ),
                    SizedBox(height: 12),
                    _CommunityPost(
                      postId: 'post2',
                      author: 'Jordan Lee',
                      time: '5h ago',
                      avatar: '💻',
                      content: 'Created comprehensive notes on Binary Search Trees. Check them out in the notes section!',
                      comments: 9,
                      hasImage: true,
                    ),
                    SizedBox(height: 12),
                    _CommunityPost(
                      postId: 'post3',
                      author: 'Emily Chen',
                      time: '1d ago',
                      avatar: '📚',
                      content: 'Looking for study partners for the upcoming Discrete Math exam. Anyone interested?',
                      comments: 15,
                      hasImage: false,
                    ),
                    ],
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick Access Card Widget
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPost extends StatelessWidget {
  final String postId;
  final String author;
  final String time;
  final String avatar;
  final String content;
  final int comments;
  final bool hasImage;

  const _CommunityPost({
    required this.postId,
    required this.author,
    required this.time,
    required this.avatar,
    required this.content,
    required this.comments,
    this.hasImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final social = Provider.of<SocialProvider>(context, listen: false);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityPostDetailScreen(
              postId: postId,
              author: author,
              time: time,
              avatar: avatar,
              content: content,
              likes: social.likeCount(postId),
              comments: social.commentCount(postId),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityUserProfileScreen(
                        username: author,
                        avatar: avatar,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Content
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF34495E),
              height: 1.5,
            ),
          ),
          
          if (hasImage) ...[
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 14),
          
          // Actions
          _PostActions(postId: postId, author: author, avatar: avatar, content: content, time: time, isDark: isDark),
        ],
      ),
    ),
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED), width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Skeleton(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(22))),
              SizedBox(width: 12),
              Expanded(child: Skeleton(width: double.infinity, height: 16)),
            ],
          ),
          SizedBox(height: 12),
          Skeleton(width: double.infinity, height: 14),
          SizedBox(height: 8),
          Skeleton(width: double.infinity, height: 14),
          SizedBox(height: 8),
          Skeleton(width: 150, height: 14),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : const Color(0xFF34495E)),
      title: Text(label, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF34495E))),
      onTap: onTap,
    );
  }
}

class _PostActions extends StatelessWidget {
  final String postId;
  final String author;
  final String avatar;
  final String content;
  final String time;
  final bool isDark;
  const _PostActions({required this.postId, required this.author, required this.avatar, required this.content, required this.time, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Selector<SocialProvider, _PostActionState>(
      selector: (ctx, social) => _PostActionState(
        liked: social.isLiked(postId),
        likeCount: social.likeCount(postId),
        commentCount: social.commentCount(postId),
        bookmarked: social.isBookmarked(postId),
      ),
      builder: (ctx, state, _) {
        final social = Provider.of<SocialProvider>(context, listen: false);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              icon: state.liked ? Icons.favorite : Icons.favorite_border,
              label: '${state.likeCount}',
              color: const Color(0xFFEC4899),
              onTap: () => social.toggleLike(postId),
            ),
            const SizedBox(width: 20),
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              label: '${state.commentCount}',
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunityPostDetailScreen(
                    postId: postId,
                    author: author,
                    time: time,
                    avatar: avatar,
                    content: content,
                    likes: state.likeCount,
                    comments: state.commentCount,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: state.bookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: 'Save',
              color: const Color(0xFFF59E0B),
              onTap: () => social.toggleBookmark(postId),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              color: const Color(0xFF10B981),
              onTap: () => Share.share('$author: $content'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.more_horiz,
              label: 'More',
              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SheetAction(icon: Icons.link, label: 'Copy Link', onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied (placeholder)')));
                          }),
                          _SheetAction(icon: Icons.flag_outlined, label: 'Report', onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reported (placeholder)')));
                          }),
                          _SheetAction(icon: state.bookmarked ? Icons.bookmark_remove : Icons.bookmark_add_outlined, label: state.bookmarked ? 'Remove Bookmark' : 'Bookmark', onTap: () {
                            social.toggleBookmark(postId);
                            Navigator.pop(context);
                          }),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        );
      },
    );
  }
}

class _PostActionState {
  final bool liked;
  final int likeCount;
  final int commentCount;
  final bool bookmarked;
  const _PostActionState({required this.liked, required this.likeCount, required this.commentCount, required this.bookmarked});
}

*/
