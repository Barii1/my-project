import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friend_chat_screen.dart';

class DemoFriendProfileScreen extends StatelessWidget {
  final String friendName;
  final String currentUserName;

  const DemoFriendProfileScreen({
    super.key,
    required this.friendName,
    required this.currentUserName,
  });

  Map<String, dynamic> _getDemoProfile(String name) {
    if (name == 'Sara Hameed') {
      return {
        'bio': 'Computer Science student at NUST. Love solving algorithms! 💻',
        'xp': 5100,
        'streak': 19,
        'totalQuizzes': 127,
        'accuracy': 89,
        'favoriteSubject': 'Data Structures',
        'joinedDays': 45,
      };
    } else if (name == 'Fahad Saeed') {
      return {
        'bio': 'Engineering student passionate about Math and Physics 📐',
        'xp': 4900,
        'streak': 12,
        'totalQuizzes': 98,
        'accuracy': 85,
        'favoriteSubject': 'Calculus',
        'joinedDays': 60,
      };
    } else if (name == 'Alina Tariq') {
      return {
        'bio': 'Medical student preparing for MDCAT. Study partner needed! 📚',
        'xp': 4400,
        'streak': 16,
        'totalQuizzes': 115,
        'accuracy': 92,
        'favoriteSubject': 'General Knowledge',
        'joinedDays': 38,
      };
    } else if (name == 'Ali Ahmed') {
      return {
        'bio': 'Business student at LUMS. Focused on Economics and Finance 💼',
        'xp': 4700,
        'streak': 10,
        'totalQuizzes': 89,
        'accuracy': 87,
        'favoriteSubject': 'Economics',
        'joinedDays': 20,
      };
    } else if (name == 'Zainab Hussain') {
      return {
        'bio': 'Law student preparing for CSS. History and Politics enthusiast 📖',
        'xp': 4500,
        'streak': 8,
        'totalQuizzes': 95,
        'accuracy': 90,
        'favoriteSubject': 'History',
        'joinedDays': 15,
      };
    } else {
      return {
        'bio': 'Student on Ostaad',
        'xp': 3000,
        'streak': 5,
        'totalQuizzes': 50,
        'accuracy': 80,
        'favoriteSubject': 'General',
        'joinedDays': 30,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = _getDemoProfile(friendName);
    final initials = friendName.split(' ').map((n) => n[0]).join();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF16213E) : const Color(0xFF3DA89A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF16213E), const Color(0xFF0F3460)]
                        : [const Color(0xFF3DA89A), const Color(0xFF4DB8A8)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      friendName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile['bio'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('XP', profile['xp'].toString(), Icons.star, const Color(0xFFFFA500), isDark),
                      _buildStatCard('Streak', '${profile['streak']} days', Icons.local_fire_department, const Color(0xFFFF6B6B), isDark),
                      _buildStatCard('Quizzes', profile['totalQuizzes'].toString(), Icons.quiz, const Color(0xFF3DA89A), isDark),
                      _buildStatCard('Accuracy', '${profile['accuracy']}%', Icons.check_circle, const Color(0xFF4CAF50), isDark),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Favorite Subject', profile['favoriteSubject'] as String, Icons.book, isDark),
                        const Divider(height: 24),
                        _buildInfoRow('Member Since', '${profile['joinedDays']} days ago', Icons.calendar_today, isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendChatScreen(
                              friendId: 'demo_${friendName.replaceAll(' ', '_').toLowerCase()}',
                              currentUserName: currentUserName,
                              currentUserId: FirebaseAuth.instance.currentUser?.uid ?? 'demo_user',
                              friendName: friendName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Send Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3DA89A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1F2937))),
      ],
    );
  }
}
