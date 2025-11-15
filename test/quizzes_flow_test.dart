import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_figma/screens/quizzes_screen.dart';

void main() {
  testWidgets('tapping a quiz opens QuizTakerScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: QuizzesScreen(
        onStartQuiz: (quiz) {},
        onNavigate: (_) {},
      ),
    ));

    // Ensure the quiz tile is present
    expect(find.text('Data Structures Basics'), findsOneWidget);

    // Tap the quiz and wait for navigation
    await tester.tap(find.text('Data Structures Basics'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // QuizTakerScreen shows a header 'Question 1 of 3'
    expect(find.text('Question 1 of 3'), findsOneWidget);
  });
}
