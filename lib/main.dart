import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'screens/settings_screen_modern.dart';
import 'screens/quizzes_screen.dart';
import 'screens/quiz_categories_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'providers/auth_provider.dart' as MyAuth;
import 'providers/stats_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/social_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/ai_chat_sessions_provider.dart';
import 'theme/app_theme.dart';
import 'screens/community_create_post.dart';
import 'screens/topic_overview_screen.dart';
import 'screens/quick_quiz_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/add_friend_screen.dart';
import 'screens/database_test_screen.dart';
import 'screens/camera_screen.dart';
import 'chatbot.dart';
import 'services/offline_storage_service.dart';
import 'services/chat_history_service.dart';
import 'services/connectivity_service.dart';
import 'lib/Email Verification/pin_screen.dart' as ev;
import 'screens/debug_input_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialize Firebase BEFORE using FirebaseAuth / providers
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler and initialize notifications
  FirebaseMessaging.onBackgroundMessage(NotificationService.backgroundHandler);
  await NotificationService().initialize();

  // Configure local Firebase emulators if enabled
  await _configureFirebaseEmulators();

  // 🔹 Initialize Hive for offline storage
  await OfflineStorageService.initialize();
  // 🔹 Initialize chat history storage
  await ChatHistoryService.initialize();

  final prefs = await SharedPreferences.getInstance();

  // Your UI setup
  AppTheme.setSystemUI();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProxyProvider<ConnectivityService, MyAuth.AuthProvider>(
          create: (context) {
            final auth = MyAuth.AuthProvider();
            final connectivity = context.read<ConnectivityService>();
            auth.setConnectivityService(connectivity);
            return auth;
          },
          update: (context, connectivity, previous) {
            if (previous != null) {
              previous.setConnectivityService(connectivity);
              return previous;
            }
            final auth = MyAuth.AuthProvider();
            auth.setConnectivityService(connectivity);
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) {
          final p = AppStateProvider();
          p.loadFlashcardsFromPrefs();
          return p;
        }),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AiChatSessionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ostaad',
            theme: AppTheme.getTheme(Brightness.light),
            darkTheme: AppTheme.getTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/ai-chat':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => AIChatScreen(
                      course: args['course'] as String,
                      sessionId: args['sessionId'] as String?,
                      onBack: () => Navigator.pop(context),
                    ),
                  );
                case '/aiTutor':
                  return MaterialPageRoute(
                    builder: (context) => HomeScreenV3(), // TODO: integrate AITutorScreen if separated
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
                case '/quizCategories':
                  return MaterialPageRoute(
                    builder: (context) => const QuizCategoriesScreen(),
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
                      Provider.of<MyAuth.AuthProvider>(context, listen: false);
                  final Map<String, String> user = {
                    'name': auth.fullName ?? 'User',
                    'email': auth.email ?? '',
                  };
                  return MaterialPageRoute(
                    builder: (context) => SettingsScreenModern(
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
                case '/friends':
                  return MaterialPageRoute(
                    builder: (context) => const FriendsScreen(),
                  );
                case '/friends/add':
                  return MaterialPageRoute(
                    builder: (context) => const AddFriendScreen(),
                  );
                case '/topicOverview':
                  final args = settings.arguments as Map<String, dynamic>?;
                  final title = args?['title'] as String? ?? 'Topic';
                  final courseId = args?['courseId'] as String? ?? title;
                  return MaterialPageRoute(
                    builder: (context) => TopicOverviewScreen(title: title, courseId: courseId),
                  );
                case '/quizQuick':
                  final args = settings.arguments as Map<String, dynamic>?;
                  final topic = args?['topic'] as String? ?? 'Topic';
                  return MaterialPageRoute(
                    builder: (context) => QuickQuizScreen(topic: topic),
                  );
                case '/database-test':
                  return MaterialPageRoute(
                    builder: (context) => const DatabaseTestScreen(),
                  );
                case '/camera':
                  return MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  );
                case '/chat':
                  return MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  );
                case '/email-pin-login':
                  return MaterialPageRoute(builder: (_) => const ev.LoginScreen());
                case '/debug-input':
                  return MaterialPageRoute(builder: (_) => const DebugInputScreen());
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

// Configure Firebase emulators (optional: for local debugging)
// Move emulator setup inside main after initialization
Future<void> _configureFirebaseEmulators() async {
  // Intentionally left empty. To use local emulators, add:
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}

