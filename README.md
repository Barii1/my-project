# 📚 Ostaad - AI-Powered Learning Companion

<div align="center">
  <img src="assets/images/generated-image.png" alt="Ostaad Logo" width="200"/>
  
  **An intelligent educational platform combining AI tutoring, gamification, and community learning**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 🎯 Overview

**Ostaad** (اُستاد - "Teacher" in Urdu) is a comprehensive mobile learning application built with Flutter that revolutionizes education through AI-powered features, gamification, and social learning. Designed with Pakistani students in mind, it provides personalized learning experiences while fostering community engagement.

### ✨ Key Features

#### 🤖 **AI-Powered Learning**
- **Muallim AI Tutor**: Personalized AI assistant using Groq API (GPT-4o-mini)
- **Smart Document Processing**: Upload PDFs and images with OCR text extraction
- **Auto-Summarization**: Generate concise summaries from notes and PDFs
- **AI Quiz Generation**: Create custom quizzes from your study materials
- **Flashcard Generation**: Automatically create flashcards from content

#### 📝 **Interactive Study Tools**
- **Quiz System**: Multi-category quizzes (Data Structures, Algorithms, Discrete Math)
- **Daily Quizzes**: Earn XP and maintain streaks with daily challenges
- **Smart Flashcards**: Spaced repetition system with mastery tracking
- **Note Taking**: Rich text editor with markdown export and PDF generation
- **Practice Mode**: Subject-specific practice sessions

#### 🏆 **Gamification & Progress**
- **XP System**: Earn experience points for completing activities
- **Streak Tracking**: Daily login rewards and consistency monitoring
- **Achievements & Badges**: Unlock rewards (Perfect Score, XP Legend, Quiz Master)
- **Subject Accuracy**: Track performance across different topics
- **Weekly Analytics**: Visualize your learning progress with charts

#### 👥 **Community & Social**
- **Global Leaderboard**: Compete with learners worldwide (real-time updates)
- **Friends System**: Add friends and view their progress
- **Community Posts**: Share resources, ask questions, create study groups
- **Friend Chats**: Collaborate with peers
- **User Profiles**: Customizable profiles with avatars and stats

#### 📱 **Offline-First Architecture**
- Complete quiz access offline
- View flashcards and notes without internet
- Cached AI chat history
- Automatic sync when connection restored
- Visual offline indicators

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `^3.9.2`
- Dart SDK: `^3.9.2`
- Android Studio / VS Code with Flutter extensions
- Firebase account (for backend services)
- Groq API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Barii1/my-project.git
   cd Ostaad_APP
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add your Android/iOS apps
   - Download `google-services.json` (Android) to `android/app/`
   - Download `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Run Firebase setup:
     ```bash
     flutterfire configure
     ```

4. **Set up API keys**
   - Create `lib/secrets.dart`:
     ```dart
     class Secrets {
       static const String groqApiKey = 'YOUR_GROQ_API_KEY';
     }
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration
├── secrets.dart                   # API keys (gitignored)
├── chatbot.dart                   # Muallim AI chat interface
│
├── config/                        # App configuration
│   └── runtime_config.dart
│
├── constants/                     # App-wide constants
│   └── app_assets.dart
│
├── models/                        # Data models
│   ├── flashcard.dart
│   ├── note.dart
│   └── user_profile.dart
│
├── providers/                     # State management (Provider)
│   ├── auth_provider.dart         # Authentication state
│   ├── stats_provider.dart        # User stats & XP
│   ├── theme_provider.dart        # Dark/Light theme
│   ├── quiz_provider.dart         # Quiz data
│   ├── social_provider.dart       # Community features
│   └── app_state_provider.dart    # Global app state
│
├── screens/                       # UI screens
│   ├── home_screen_v3.dart        # Main dashboard
│   ├── login_screen.dart          # Authentication
│   ├── ai_tutor_screen.dart       # AI subject tutors
│   ├── chatbot.dart               # Muallim AI chat
│   ├── quizzes_screen.dart        # Quiz categories
│   ├── daily_quiz_screen.dart     # Daily challenges
│   ├── flashcards_screen.dart     # Flashcard decks
│   ├── notes_screen.dart          # Note taking
│   ├── community_modern.dart      # Social features
│   ├── progress_screen.dart       # Analytics dashboard
│   ├── profile_screen.dart        # User profile
│   ├── settings_screen_modern.dart # App settings
│   └── home/components/           # Reusable home widgets
│       ├── streak_summary.dart
│       ├── progress_cards_row.dart
│       └── friends_section.dart
│
├── services/                      # Business logic
│   ├── groq_service.dart          # AI API integration
│   ├── xp_service.dart            # XP & achievements
│   ├── friend_service.dart        # Social features
│   ├── offline_storage_service.dart # Hive database
│   ├── connectivity_service.dart  # Network monitoring
│   ├── chat_history_service.dart  # AI chat persistence
│   └── usage_service.dart         # App usage tracking
│
├── theme/                         # UI theming
│   └── app_theme.dart
│
├── utils/                         # Utility functions
│   └── validators.dart
│
└── widgets/                       # Reusable widgets
    ├── offline_indicator.dart
    └── custom_buttons.dart
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Material Design 3**: Modern UI components
- **Provider**: State management
- **Rive & Lottie**: Animations

### Backend & Services
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage (PDFs, images)
- **Groq API**: AI-powered chat (GPT-4o-mini)

### Local Storage
- **Hive**: NoSQL local database (offline support)
- **Shared Preferences**: Simple key-value storage
- **Path Provider**: File system access

### AI/ML Features
- **Google ML Kit**: Text recognition (OCR)
- **Syncfusion PDF**: PDF text extraction
- **Image Picker**: Camera/gallery access

### Utilities
- **Connectivity Plus**: Network monitoring
- **Share Plus**: Content sharing
- **File Picker**: Document selection
- **Confetti**: Celebration animations

---

## 🎮 Core Features Explained

### 1. AI Muallim Chat
The intelligent tutor that can:
- Answer homework questions
- Explain complex concepts
- Process uploaded PDFs (30-page limit)
- Extract text from images via OCR
- Maintain conversation context
- Work in light/dark mode

**Tech**: Groq API, ML Kit OCR, Syncfusion PDF

### 2. Streak & XP System
Gamification engine that:
- Awards XP for quiz completion (based on score %)
- Tracks consecutive daily logins
- Resets streak on missed days
- Unlocks badges at milestones
- Syncs across devices via Firestore

**Implementation**: `xp_service.dart` + Firestore triggers

### 3. Real-Time Leaderboard
Competitive ranking system:
- Global and friends leaderboards
- Real-time updates via Firestore streams
- Demo mode with 10+ Pakistani users
- Search functionality
- Profile quick views

**Tech**: StreamBuilder + Firestore queries

### 4. Offline Mode
Seamless offline experience:
- Hive database with 7 specialized boxes
- Auto-sync when connection restored
- Cached quiz data, flashcards, notes
- Offline authentication
- Visual connectivity indicators

**Architecture**: See [OFFLINE_MODE_DOCUMENTATION.md](OFFLINE_MODE_DOCUMENTATION.md)

---

## 📊 Database Schema

### Firestore Collections

```
users/
  {userId}/
    - email: string
    - displayName: string
    - photoURL: string
    - xp: number
    - streakDays: number
    - lastActiveDate: timestamp
    - dailyXp: number
    - achievements: map
    - subjectAccuracy: map
    - weeklyData: array

flashcards/
  {flashcardId}/
    - userId: string
    - deckName: string
    - cards: array
    - createdAt: timestamp
    - mastered: number

notes/
  {noteId}/
    - userId: string
    - title: string
    - content: string
    - category: string
    - createdAt: timestamp
    - updatedAt: timestamp

posts/
  {postId}/
    - authorId: string
    - content: string
    - likes: number
    - comments: number
    - timestamp: timestamp

friends/
  {userId}/
    - friends: array
    - requests: array
```

---

## 🎨 UI/UX Highlights

- **Dual Theme**: Professionally designed light/dark modes
- **Cultural Localization**: Pakistani names and context
- **Smooth Animations**: Confetti, Lottie, Rive animations
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: High contrast, readable fonts

---

## 🔐 Security Features

- Firebase Authentication with email/password
- Hashed password storage for offline mode
- Firestore security rules
- API key obfuscation
- User data isolation

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (planned)
- ✅ Windows (experimental)
- ✅ macOS (experimental)
- ✅ Linux (experimental)

---

## 🧪 Testing

Run tests:
```bash
flutter test
```

Key test files:
- `test/widget_test.dart` - Widget tests
- `test/quizzes_flow_test.dart` - Quiz functionality

---

## 📖 Documentation

- **[DEMO_GUIDE.md](DEMO_GUIDE.md)** - How to demonstrate app features
- **[OFFLINE_MODE_DOCUMENTATION.md](OFFLINE_MODE_DOCUMENTATION.md)** - Offline architecture
- **[CHATBOT_COMPLETE.md](CHATBOT_COMPLETE.md)** - AI chat implementation
- **[DATABASE_TEST_GUIDE.md](DATABASE_TEST_GUIDE.md)** - Database testing
- **[PROJECT_PROPOSAL.md](PROJECT_PROPOSAL.md)** - Project overview and goals

---

## 🚧 Roadmap

- [ ] Video lessons integration
- [ ] Voice chat with AI tutor
- [ ] Advanced analytics dashboard
- [ ] Group study rooms
- [ ] Peer-to-peer tutoring marketplace
- [ ] Mobile notifications for streaks
- [ ] Web platform launch

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Barii1**
- GitHub: [@Barii1](https://github.com/Barii1)
- Repository: [my-project](https://github.com/Barii1/my-project)

---

## 🙏 Acknowledgments

- **Groq** for providing fast AI inference
- **Firebase** for backend infrastructure
- **Flutter Team** for the amazing framework
- **Google ML Kit** for OCR capabilities
- **Pakistani Student Community** for feedback and testing

---

## 📞 Support

For issues and feature requests:
- Open an [issue](https://github.com/Barii1/my-project/issues)
- Check existing [documentation](docs/)

---

<div align="center">
  <p>Made with ❤️ for Pakistani students</p>
  <p>Empowering education through technology</p>
</div>
