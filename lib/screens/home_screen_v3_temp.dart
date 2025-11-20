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
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  List<bool> _isTapped = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(_flameController);
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_sparkleController);
  }

  @override
  void dispose() {
    _flameController.dispose();
    _sparkleController.dispose();
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
        onStartQuiz: (quiz) {},
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
      backgroundColor: const Color(0xFFF0FDFC),
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          _buildWelcomeRow(name),
          const SizedBox(height: 28),
          _buildStreakCard(),
          const SizedBox(height: 20),
          _buildProgressRingsRow(),
          const SizedBox(height: 32),
          _buildQuickStartSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeRow(String name) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/96'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Welcome back, $name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          color: const Color(0xFF1A1A1A),
          onPressed: () => Navigator.of(context).pushNamed('/notifications'),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '12 Day Streak',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006D77),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _flameAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _flameAnimation.value,
                child: const Icon(
                  Icons.local_fire_department,
                  size: 90,
                  color: Color(0x99006D77),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the fire burning!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRingsRow() {
    return Row(
      children: [
        Expanded(child: _buildProgressCard('Quiz Master', 0.80)),
        const SizedBox(width: 16),
        Expanded(child: _buildProgressCard('Note Taker', 0.60)),
      ],
    );
  }

  Widget _buildProgressCard(String title, double progress) {
    final percentage = (progress * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFE8F4F8),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9D9)),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (progress >= 0.8)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _sparkleAnimation.value,
                          child: const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.yellow,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
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
        const Text(
          'Quick Start',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildQuickStartCard(0, 'Daily Quiz', Icons.quiz_outlined, () => Navigator.of(context).pushNamed('/dailyQuiz')),
            _buildQuickStartCard(1, 'Flashcards', Icons.style_outlined, () => Navigator.of(context).pushNamed('/flashcards')),
            _buildQuickStartCard(2, 'Practice', Icons.psychology_outlined, () => Navigator.of(context).pushNamed('/practice')),
            _buildQuickStartCard(3, 'Notes', Icons.note_alt_outlined, () => Navigator.of(context).pushNamed('/notes')),
          ],
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
            color: Colors.black.withOpacity(0.05),
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
              decoration: const BoxDecoration(
                color: Color(0xFF00A3A3),
                shape: BoxShape.circle,
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
    W i d g e t   _ b u i l d Q u i c k S t a r t C a r d ( i n t   i n d e x ,   S t r i n g   l a b e l ,   I c o n D a t a   i c o n ,   V o i d C a l l b a c k   o n P r e s s e d )   { 
  Widget _buildQuickStartCard(int index, String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTapped[index] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isTapped[index] = false;
        });
        onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isTapped[index] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _isTapped[index] ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFB2EBE5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 68,
              color: const Color(0xFF00A3A3),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
