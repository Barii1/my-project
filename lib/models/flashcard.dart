class FlashcardDeck {
  final String id;
  final String title;
  final int cards;
  final int mastered;
  final String dueIn;

  FlashcardDeck({
    required this.id,
    required this.title,
    required this.cards,
    required this.mastered,
    required this.dueIn,
  });
}

class Flashcard {
  final String front;
  final String back;

  Flashcard({
    required this.front,
    required this.back,
  });
}

final List<FlashcardDeck> flashcardDecks = [
  FlashcardDeck(
    id: 'ds-basics',
    title: 'Data Structures Basics',
    cards: 24,
    mastered: 18,
    dueIn: '3h',
  ),
  FlashcardDeck(
    id: 'calculus',
    title: 'Calculus Formulas',
    cards: 30,
    mastered: 22,
    dueIn: '1d',
  ),
  FlashcardDeck(
    id: 'algorithms',
    title: 'Algorithm Complexity',
    cards: 16,
    mastered: 10,
    dueIn: 'Now',
  ),
];

final List<Flashcard> sampleCards = [
  Flashcard(
    front: 'What is a Stack?',
    back: 'A linear data structure that follows the Last In First Out (LIFO) principle. Elements are added and removed from the same end.',
  ),
  Flashcard(
    front: 'Time complexity of Binary Search?',
    back: 'O(log n) - The search space is halved with each comparison.',
  ),
  Flashcard(
    front: 'What is a Queue?',
    back: 'A linear data structure that follows the First In First Out (FIFO) principle. Elements are added at the rear and removed from the front.',
  ),
];