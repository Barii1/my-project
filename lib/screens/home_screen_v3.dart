import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'ai_tutor_screen.dart';
import 'ai_chat_screen.dart';
import 'history_screen.dart';
import 'quizzes_screen.dart';
import 'community_modern.dart';
import 'settings_modern.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';

class HomeScreenV3 extends StatefulWidget {
  const HomeScreenV3({super.key});

  @override
  State<HomeScreenV3> createState() => _HomeScreenV3State();
}

class _HomeScreenV3State extends State<HomeScreenV3> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(_flameController);
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final name = (auth.fullName?.isNotEmpty ?? false) ? auth.fullName!.split(' ')[0] : 'Learner';

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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate: $screen')));
          }
        },
      ),
      QuizzesScreen(
        onStartQuiz: (categoryId) {
          // Handle quiz category selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Starting quiz for: $categoryId')),
          );
        },
        onNavigate: (screen) {
          if (screen == 'notes') Navigator.of(context).pushNamed('/notes');
        },
      ),
      const CommunityModernScreen(),
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

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, String name) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          _buildWelcomeRow(name),
          const SizedBox(height: 20),
          _buildStreakCard(),
          const SizedBox(height: 16),
          _buildProgressRingsRow(),
          const SizedBox(height: 20),
          _buildQuickStartSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeRow(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome back, $name! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              color: const Color(0xFF1A1A1A),
              onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to continue learning?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x15000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '12',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'days',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _flameAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_flameAnimation.value * 0.1),
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 60),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRingsRow() {
    return Row(
      children: [
        Expanded(child: _buildDailyGoalCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildTotalXpCard()),
      ],
    );
  }

  Widget _buildDailyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3DA89A)),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3DA89A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.adjust, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '65%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daily Goal',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalXpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            '3,420',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total XP',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
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
        _buildSubjectAccuracyCard(),
        const SizedBox(height: 20),
        _buildWeeklyProgressGraph(),
        const SizedBox(height: 20),
        _buildRecentBadgesCard(),
        const SizedBox(height: 20),
        _buildQuickStartActionsCard(),
      ],
    );
  }

  Widget _buildSubjectAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Accuracy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildSubjectRow('Computer Science', 78, const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildSubjectRow('Mathematics', 85, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(String subject, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressGraph() {
    // Sample data for the week - hours studied per day
    final weekData = [2.5, 3.0, 1.5, 4.0, 3.5, 2.0, 3.8];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxHours = 5.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '20.3 hrs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hours studied this week',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final height = (weekData[index] / maxHours) * 120;
              final isToday = index == 6; // Sunday is today
              
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${days[index]}: ${weekData[index]} hours'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      weekData[index].toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday 
                            ? [const Color(0xFF4DB8A8), const Color(0xFF3DA89A)]
                            : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                        color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.quiz_outlined,
            label: 'Daily Quiz',
            color: const Color(0xFF3B82F6),
            onTap: () => Navigator.of(context).pushNamed('/dailyQuiz'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.style_outlined,
            label: 'Review Flashcards',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.of(context).pushNamed('/flashcards'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.note_alt_outlined,
            label: 'New Note',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.of(context).pushNamed('/notes'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBadgesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Badges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Icon(Icons.emoji_events, color: Color(0xFF10B981), size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadge('7-day Streak', Icons.local_fire_department, const Color(0xFFFFA726)),
              _buildBadge('Quiz Master', Icons.emoji_events, const Color(0xFFFFD700)),
              _buildBadge('Note Taker', Icons.note_alt, const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.access_time, Icons.access_time, 'AI Tutor'),
            _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book, 'Quizzes'),
            _buildNavItem(3, Icons.people_outline, Icons.people, 'Community'),
            _buildNavItem(4, Icons.settings_outlined, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00A3A3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x4000A3A3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 10),
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF00A3A3) : const Color(0xFF99A3B1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF00A3A3) : const Color(0xFF99A3B1),
            ),
          ),
        ],
      ),
    );
  }
}
