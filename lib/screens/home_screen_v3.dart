import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _selectedIndex = 0;

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
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildQuickStartSection(),
          const SizedBox(height: 24),
          _buildRecentBadges(),
          const SizedBox(height: 24),
          _buildRecentProgress(),
        ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.appGradient,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.appGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6, offset: const Offset(0,4))],
                ),
                child: Icon(Icons.local_fire_department, color: Theme.of(context).colorScheme.onPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Current Streak', 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Quiz Master', '12/15'),
              const SizedBox(width: 24),
              _buildStatItem('Note Taker', '8/10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String progress) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withAlpha((0.7 * 255).round()),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
            ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: Theme.of(context).colorScheme.onPrimary.withAlpha((0.24 * 255).round()),
              valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onPrimary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(progress,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBadge('7-day Streak', Icons.local_fire_department),
              _buildBadge('Quiz Master', Icons.psychology),
              _buildBadge('Note Taker', Icons.edit_note),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.appGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
          const SizedBox(height: 8),
          Text(title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ),
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
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.primary,
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