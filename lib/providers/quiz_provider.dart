import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider() {
    _initializeOfflineData();
  }

  Future<void> _initializeOfflineData() async {
    // Cache all quiz data for offline access
    await _cacheQuizData();
  }

  Future<void> _cacheQuizData() async {
    // Save categories
    final categoriesMap = _categories.map((c) => {
      'id': c.id,
      'title': c.title,
      'description': c.description,
    }).toList();
    await OfflineStorageService.saveQuizCategories(categoriesMap);

    // Save topics
    for (final entry in _topics.entries) {
      final topicsMap = entry.value.map((t) => {
        'id': t.id,
        'categoryId': t.categoryId,
        'title': t.title,
      }).toList();
      await OfflineStorageService.cacheData('quiz_topics_${entry.key}', topicsMap);
    }

    // Save sets
    for (final entry in _sets.entries) {
      final setsMap = entry.value.map((s) => {
        'id': s.id,
        'topicId': s.topicId,
        'title': s.title,
        'timeLimitSec': s.timeLimitSec,
      }).toList();
      await OfflineStorageService.cacheData('quiz_sets_${entry.key}', setsMap);
    }

    // Save questions
    for (final entry in _questions.entries) {
      final questionsData = entry.value.map((q) => {
        'id': q.id,
        'setId': q.setId,
        'stem': q.stem,
        'options': q.options.map((o) => {
          'id': o.id,
          'text': o.text,
          'correct': o.correct,
        }).toList(),
        'explanation': q.explanation,
        'difficulty': q.difficulty,
      }).toList();
      await OfflineStorageService.saveQuizQuestions(entry.key, questionsData);
    }
  }

  final List<QuizCategory> _categories = [
    QuizCategory(id: 'cat_ds', title: 'Data Structures', description: 'Arrays, Trees, Graphs'),
    QuizCategory(id: 'cat_algo', title: 'Algorithms', description: 'Sorting, Searching, DP'),
    QuizCategory(id: 'cat_math', title: 'Discrete Math', description: 'Logic, Sets, Combinatorics'),
  ];

  final Map<String, List<QuizTopic>> _topics = {
    'cat_ds': [
      QuizTopic(id: 'top_arrays', categoryId: 'cat_ds', title: 'Arrays'),
      QuizTopic(id: 'top_trees', categoryId: 'cat_ds', title: 'Trees'),
      QuizTopic(id: 'top_graphs', categoryId: 'cat_ds', title: 'Graphs'),
    ],
    'cat_algo': [
      QuizTopic(id: 'top_sort', categoryId: 'cat_algo', title: 'Sorting'),
      QuizTopic(id: 'top_search', categoryId: 'cat_algo', title: 'Searching'),
      QuizTopic(id: 'top_dp', categoryId: 'cat_algo', title: 'Dynamic Programming'),
    ],
    'cat_math': [
      QuizTopic(id: 'top_logic', categoryId: 'cat_math', title: 'Logic'),
      QuizTopic(id: 'top_sets', categoryId: 'cat_math', title: 'Sets'),
      QuizTopic(id: 'top_comb', categoryId: 'cat_math', title: 'Combinatorics'),
    ],
  };

  final Map<String, List<QuizSet>> _sets = {
    'top_arrays': [
      QuizSet(id: 'set_arrays_basic', topicId: 'top_arrays', title: 'Arrays Basics', timeLimitSec: 300),
      QuizSet(id: 'set_arrays_adv', topicId: 'top_arrays', title: 'Advanced Arrays', timeLimitSec: 480),
    ],
    'top_trees': [
      QuizSet(id: 'set_trees_basic', topicId: 'top_trees', title: 'Trees Fundamentals', timeLimitSec: 420),
    ],
    'top_dp': [
      QuizSet(id: 'set_dp_intro', topicId: 'top_dp', title: 'DP Introduction', timeLimitSec: 600),
    ],
  };

  final Map<String, List<QuizQuestion>> _questions = {
    'set_arrays_basic': [
      QuizQuestion(
        id: 'q1',
        setId: 'set_arrays_basic',
        stem: 'What is the time complexity of accessing an element by index in an array?',
        options: [
          QuizOption(id: 'o1', text: 'O(1)', correct: true),
          QuizOption(id: 'o2', text: 'O(n)', correct: false),
          QuizOption(id: 'o3', text: 'O(log n)', correct: false),
          QuizOption(id: 'o4', text: 'O(n log n)', correct: false),
        ],
        explanation: 'Direct index gives constant time in contiguous memory.',
        difficulty: 1,
      ),
      QuizQuestion(
        id: 'q2',
        setId: 'set_arrays_basic',
        stem: 'What is the best choice for dynamic resizing arrays in Dart?',
        options: [
          QuizOption(id: 'o1', text: 'List', correct: true),
          QuizOption(id: 'o2', text: 'Queue', correct: false),
          QuizOption(id: 'o3', text: 'Set', correct: false),
          QuizOption(id: 'o4', text: 'Map', correct: false),
        ],
        explanation: 'Dart List supports dynamic resizing and indexing.',
        difficulty: 1,
      ),
    ],
  };

  List<QuizCategory> get categories => List.unmodifiable(_categories);
  List<QuizTopic> topicsFor(String categoryId) => List.unmodifiable(_topics[categoryId] ?? const []);
  List<QuizSet> setsFor(String topicId) => List.unmodifiable(_sets[topicId] ?? const []);
  List<QuizQuestion> questionsFor(String setId) => List.unmodifiable(_questions[setId] ?? const []);

  List<QuizQuestion> mixedQuestions({int max = 10}) {
    final all = <QuizQuestion>[];
    for (final entry in _questions.entries) {
      all.addAll(entry.value);
    }
    all.shuffle();
    return all.take(max).toList();
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  QuizCategory({required this.id, required this.title, required this.description});
}

class QuizTopic {
  final String id;
  final String categoryId;
  final String title;
  QuizTopic({required this.id, required this.categoryId, required this.title});
}

class QuizSet {
  final String id;
  final String topicId;
  final String title;
  final int timeLimitSec;
  QuizSet({required this.id, required this.topicId, required this.title, required this.timeLimitSec});
}

class QuizQuestion {
  final String id;
  final String setId;
  final String stem;
  final List<QuizOption> options;
  final String explanation;
  final int difficulty;
  QuizQuestion({required this.id, required this.setId, required this.stem, required this.options, required this.explanation, required this.difficulty});
}

class QuizOption {
  final String id;
  final String text;
  final bool correct;
  QuizOption({required this.id, required this.text, required this.correct});
}