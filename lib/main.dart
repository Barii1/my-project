import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 🔹 Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/daily_quiz_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen_v3.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_modern.dart';
import 'screens/quizzes_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/app_state_provider.dart';
import 'theme/app_theme.dart';
import 'screens/community_create_post.dart';
import 'screens/community_trending.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialize Firebase BEFORE using FirebaseAuth / providers
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Your UI setup
  AppTheme.setSystemUI();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) {
          final p = AppStateProvider();
          p.loadFlashcardsFromPrefs();
          return p;
        }),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ostaad',
            theme: AppTheme.getTheme(Brightness.light),
            darkTheme: AppTheme.getTheme(Brightness.dark),
            themeMode: appState.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/ai-chat':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => AIChatScreen(
                      course: args['course'] as String,
                      onBack: () => Navigator.pop(context),
                    ),
                  );
                case '/flashcards':
                  return MaterialPageRoute(
                    builder: (context) => const FlashcardsScreen(),
                  );
                case '/notes':
                  return MaterialPageRoute(
                    builder: (context) => const NotesScreen(),
                  );
                case '/dailyQuiz':
                  return MaterialPageRoute(
                    builder: (context) => const DailyQuizScreen(),
                  );
                case '/practice':
                  return MaterialPageRoute(
                    builder: (context) => const PracticeScreen(),
                  );
                case '/quiz':
                  return MaterialPageRoute(
                    builder: (context) => const QuizScreen(),
                  );
                case '/progress':
                  return MaterialPageRoute(
                    builder: (context) => const ProgressScreen(),
                  );
                case '/notifications':
                  return MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  );
                case '/history':
                  return MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (context) => const HomeScreenV3(),
                  );
                case '/profile':
                  return MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  );
                case '/settings':
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  final user = {
                    'name': auth.fullName ?? 'User',
                    'email': auth.email ?? '',
                  };
                  return MaterialPageRoute(
                    builder: (context) => SettingsModernScreen(
                      user: user,
                      onLogout: () async {
                        await auth.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  );
                case '/quizzes':
                  return MaterialPageRoute(
                    builder: (context) => QuizzesScreen(
                      onStartQuiz: (quiz) {
                        // No-op placeholder
                      },
                      onNavigate: (screen) {
                        if (screen == 'notes') {
                          Navigator.of(context).pushNamed('/notes');
                        } else if (screen == 'home') {
                          Navigator.of(context).pushNamed('/home');
                        }
                      },
                    ),
                  );
                case '/leaderboard':
                  return MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  );
                case '/community/create':
                  return MaterialPageRoute(
                    builder: (context) =>
                        const CommunityCreatePostScreen(),
                  );
                case '/community/trending':
                  return MaterialPageRoute(
                    builder: (context) =>
                        const CommunityTrendingScreen(),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
