import 'package:flutter/material.dart';
// provider already imported above
import '../providers/auth_provider.dart';
import '../theme/app_branding.dart';
import '../theme/app_theme.dart';
import 'ai_tutor_screen.dart';
import 'ai_chat_screen.dart';
import 'history_screen.dart';
// removed: course_detail_screen.dart is no longer used here
import 'quizzes_screen.dart';
import 'community_modern.dart';
import 'settings_modern.dart';
import 'login_screen.dart';
import '../widgets/streak_card.dart';
import '../widgets/quick_start_card.dart';
import '../widgets/circular_progress_ring.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/chat_thread.dart';

class HomeScreenV3 extends StatelessWidget {
  const HomeScreenV3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 900 ? 900.0 : screenWidth;

    return Scaffold(
      // Use the app gradient at the top and a soft background below
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surface
                  : AppTheme.primary.withAlpha(0x10),
        Theme.of(context).brightness == Brightness.dark
          ? AppTheme.background
          : Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: _HomeContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingWithLabel extends StatelessWidget {
  final String title;
  final int numerator;
  final int denominator;
  const _RingWithLabel({required this.title, required this.numerator, required this.denominator});

  @override
  Widget build(BuildContext context) {
    final progress = denominator == 0 ? 0.0 : (numerator / denominator).clamp(0.0, 1.0);
    final percentText = "${(progress * 100).round()}%";
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressRing(
                progress: progress,
                label: percentText,
                gradient: const [Color(0xFF00BFA6), Color(0xFF00E5FF)],
                celebrateAtFull: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Warm up persisted recent chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = Provider.of<AppStateProvider>(context, listen: false);
      app.loadRecentChatsFromPrefs();
      // Seed some demo chats if empty (first run)
      if (app.recentChats.isEmpty) {
        app.addRecentChat(ChatThread(id: '1', title: 'Algorithms deep dive', subject: 'CS', time: DateTime.now().subtract(const Duration(minutes: 12)), preview: 'Let\'s explore Dijkstra...'));
        app.addRecentChat(ChatThread(id: '2', title: 'Integration practice', subject: 'Math', time: DateTime.now().subtract(const Duration(hours: 3, minutes: 4)), preview: 'Try substitution on this one...'));
        app.addRecentChat(ChatThread(id: '3', title: 'Exam strategy', subject: 'CS', time: DateTime.now().subtract(const Duration(days: 1, hours: 2)), preview: 'Focus on complexity analysis...'));
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent(BuildContext context, String name) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // Added extra bottom padding for navigation bar
    children: [
          Row(
            children: [
              AppBranding.logo(size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(name, 
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // New animated streak card
          StreakCard(streak: 12),
          const SizedBox(height: 24),
          _buildProgressRingsRow(),
          const SizedBox(height: 24),
          _buildQuickStartSection(),
          const SizedBox(height: 24),
          _buildRecentChatsSection(),
          const SizedBox(height: 24),
          _buildRecentProgress(),
        ],
    );
  }

  // Removed old stats card in favor of StreakCard

  // Removed old stat item helper

  Widget _buildProgressRingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RingWithLabel(title: 'Quiz Master', numerator: 12, denominator: 15),
        _RingWithLabel(title: 'Note Taker', numerator: 8, denominator: 10),
      ],
    );
  }


  Widget _buildRecentChatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: _RecentChatsList(),
        ),
      ],
    );
  }

  Widget _buildQuickStartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Start', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 16),
        // Use card-based buttons placed in two rows to maintain spacing and contrast
        Row(
          children: [
            Expanded(
              child: _buildQuickCard(
                'Daily Quiz',
                Icons.quiz_outlined,
                onPressed: () => Navigator.of(context).pushNamed('/dailyQuiz'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickCard(
                'Flashcards',
                Icons.style_outlined,
                onPressed: () => Navigator.of(context).pushNamed('/flashcards'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickCard(
                'Practice',
                Icons.psychology_outlined,
                onPressed: () => Navigator.of(context).pushNamed('/practice'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickCard(
                'Notes',
                Icons.note_alt_outlined,
                onPressed: () => Navigator.of(context).pushNamed('/notes'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildQuickCard(String text, IconData icon, {required VoidCallback onPressed}) {
    // Map labels to lottie assets
    String asset;
    switch (text) {
      case 'Daily Quiz':
        asset = 'assets/lottie/brain.json';
        break;
      case 'Flashcards':
        asset = 'assets/lottie/cards.json';
        break;
      case 'Practice':
        asset = 'assets/lottie/target.json';
        break;
      case 'Notes':
        asset = 'assets/lottie/pen.json';
        break;
      default:
        asset = 'assets/lottie/brain.json';
    }
    return QuickStartCard(
      title: text,
      lottieAsset: asset,
      fallbackIcon: icon,
      onTap: onPressed,
    );
  }

  Widget _buildRecentProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Progress', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('7-Day Streak!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Keep going to earn bonus XP!',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withAlpha((0.85 * 255).round())),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/dailyQuiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Start Today\'s Quiz'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final name = (auth.fullName?.isNotEmpty ?? false) ? auth.fullName! : 'Learner';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = {
      'name': authProvider.fullName ?? 'Learner',
      'email': authProvider.email ?? ''
    };

    final pages = [
      _buildHomeContent(context, name),
      AITutorScreen(
        onSelectCourse: (course) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIChatScreen(
                course: course,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
        onNavigate: (screen) {
          if (screen == 'history') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          } else {
            // fallback: show a simple snackbar for unknown navigation
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate: $screen')));
          }
        },
      ),

      // Quizzes tab: show the QuizzesScreen and wire simple callbacks
      QuizzesScreen(
        onStartQuiz: (quiz) {
          // Default: open QuizTakerScreen (QuizzesScreen already does this on tap), so leave no-op
        },
        onNavigate: (screen) {
          if (screen == 'notes') Navigator.of(context).pushNamed('/notes');
        },
      ),

  // Community tab
  const CommunityModernScreen(),

      // Settings tab
      SettingsModernScreen(
        user: user,
        onLogout: () async {
          await authProvider.logout();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    ];

    return Stack(
      children: [
        // Use an IndexedStack so state is preserved between tabs
        IndexedStack(index: _selectedIndex, children: pages),
        
        // Bottom Navigation
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, -2)
                )
              ]
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.black54,
                elevation: 0,
                selectedLabelStyle: const TextStyle(fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), 
                    activeIcon: Icon(Icons.home),
                    label: 'Home'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.access_time), 
                    activeIcon: Icon(Icons.access_time),
                    label: 'AI Tutor'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_outlined), 
                    activeIcon: Icon(Icons.menu_book),
                    label: 'Quizzes'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline), 
                    activeIcon: Icon(Icons.people),
                    label: 'Community'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), 
                    activeIcon: Icon(Icons.settings),
                    label: 'Settings'
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Recent Chats AnimatedList
class _RecentChatsList extends StatefulWidget {
  const _RecentChatsList();

  @override
  State<_RecentChatsList> createState() => _RecentChatsListState();
}

class _RecentChatsListState extends State<_RecentChatsList> {
  final Set<String> _collapsing = <String>{};

  Color _subjectStartColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'cs':
        return const Color(0xFF7C4DFF); // purple
      case 'math':
        return const Color(0xFFFF7043); // orange/red
      default:
        return const Color(0xFF29B6F6); // blue
    }
  }

  Color _subjectEndColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'cs':
        return const Color(0xFF536DFE); // indigo-blue
      case 'math':
        return const Color(0xFFEF5350); // red
      default:
        return const Color(0xFF00E5FF); // cyan
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _buildItem(BuildContext context, ChatThread chat) {
    final start = _subjectStartColor(chat.subject);
    final end = _subjectEndColor(chat.subject);

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _collapsing.contains(chat.id)
          ? const SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Dismissible(
          key: ValueKey(chat.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            setState(() => _collapsing.add(chat.id));
            await Future.delayed(const Duration(milliseconds: 260));
            if (!mounted) return false;
            Provider.of<AppStateProvider>(context, listen: false).removeRecentChat(chat.id);
            return false; // we remove manually via provider after animation
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Open chat — navigation can be implemented by caller
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open chat: ${chat.title}')));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Gradient left border
                    Container(
                      width: 6,
                      height: 56,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(colors: [start, end], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(chat.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text(_timeAgo(chat.time), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.6 * 255).round()), fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: start.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: start.withAlpha((0.12 * 255).round())),
                                ),
                                child: Text(chat.subject, style: TextStyle(color: start, fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(chat.preview, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // trailing chevron with fade
                    ShaderMask(
                      shaderCallback: (Rect rect) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, Colors.grey],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Icon(Icons.chevron_right, size: 26, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, app, _) {
        final chats = app.recentChats;
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) => _buildItem(context, chats[index]),
        );
      },
    );
  }
}