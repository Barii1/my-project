# Ostaad

## Overview
Ostaad is a Flutter-based mobile app for students to enhance learning in Computer Science (CS) and Mathematics. It offers subject-specific AI assistance, offline notes and history, quizzes, flashcards, and a community tab for collaboration. Built using the "Flutter Quiz App with Firebase" tutorial, with added features like voice-to-text AI.

## Objectives
- Develop a cross-platform Flutter app for iOS and Android.
- Integrate APIs for quizzes and authentication.
- Provide AI study tips for CS and Math.
- Enable offline access to notes and history.
- Create a community for note-sharing and help.
- Design intuitive UI with dark mode.
- Ensure secure data handling.

## Unique Selling Points
- Subject-Specific AI: Tailored tips like "Explain binary search" or "Solve quadratic equations."
- Community Collaboration: Share notes and seek peer help.
- Gamified Learning: Track progress and study streaks.
- Offline Access: Cached notes and history.
- Voice Interaction: Voice-to-text queries.

## Key Features
- **Aesthetic UI & Dark Mode**: Playful design with theme toggle.
- **AI Tutor**: Predefined responses via Firebase Functions; voice input.
- **Quiz System**: From Open Trivia API; custom quizzes; offline caching.
- **Offline Notes & History**: Save and filter interactions via sqflite.
- **Community Tab**: Post requests, upvotes, comments via Firestore.
- **Progress Dashboard**: Quiz stats and streaks.
- **Flashcard Mode**: Convert notes to flashcards.
- **Push Notifications**: Reminders via Firebase Cloud Messaging.

## Target Users
- Students (16-25) in CS/Math.
- Casual learners for quick quizzes.
- Instructors for evaluation.

## Technology Stack
- **Frontend**: Flutter.
- **APIs**: Open Trivia, Firebase (Auth, Functions, Firestore, Messaging).
- **Packages**: dio, sqflite, shared_preferences, speech_to_text, charts_flutter, flutter_secure_storage.
- **Tools**: VS Code, Postman.
- **Tutorial**: "Flutter Quiz App with Firebase" by Flutter Mapp (2024).

## Implementation
- Fetch data from APIs; cache offline.
- Secure with HTTPS and Firebase Auth.
- Widgets for screens; services for API/caching.

## Security & Privacy
- Google login via Firebase.
- Encrypt data; minimal collection.

## Expected Outcomes
- Functional app with all features.
- Clean code and documentation.
- Engaging UI for learning.

Pocket Tutor showcases mobile dev skills with gamified, collaborative learning.
