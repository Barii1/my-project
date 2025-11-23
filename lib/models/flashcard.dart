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
    back: 'A linear data structure that follows the Last In First Out (LIFO) principle. Elements are added and removed from the same end (top). Common operations: push(), pop(), peek().',
  ),
  Flashcard(
    front: 'What is the time complexity of Binary Search?',
    back: 'O(log n) - The search space is halved with each comparison. It requires a sorted array and divides the problem size by 2 at each step.',
  ),
  Flashcard(
    front: 'What is a Queue?',
    back: 'A linear data structure that follows the First In First Out (FIFO) principle. Elements are added at the rear (enqueue) and removed from the front (dequeue). Used in BFS, scheduling, and buffers.',
  ),
  Flashcard(
    front: 'What is Big O notation?',
    back: 'A mathematical notation describing the upper bound of an algorithm\'s time or space complexity. It expresses worst-case performance as input size grows. Example: O(n), O(n²), O(log n).',
  ),
  Flashcard(
    front: 'What is a Hash Table?',
    back: 'A data structure that maps keys to values using a hash function. Provides O(1) average time for insert, delete, and search. Handles collisions via chaining or open addressing.',
  ),
  Flashcard(
    front: 'What is the difference between Array and Linked List?',
    back: 'Array: Contiguous memory, O(1) random access, fixed/dynamic size. Linked List: Non-contiguous, O(n) access, dynamic size, efficient insertion/deletion at ends.',
  ),
  Flashcard(
    front: 'What is a Binary Tree?',
    back: 'A hierarchical data structure where each node has at most two children (left and right). Used in BST, heaps, expression parsing. Height determines traversal complexity.',
  ),
  Flashcard(
    front: 'What is recursion?',
    back: 'A programming technique where a function calls itself to solve smaller instances of the same problem. Must have: base case (stopping condition) and recursive case (self-call with modified input).',
  ),
  Flashcard(
    front: 'What is Dynamic Programming?',
    back: 'An optimization technique that solves complex problems by breaking them into overlapping subproblems. Stores results (memoization) to avoid redundant calculations. Used in Fibonacci, knapsack, LCS.',
  ),
  Flashcard(
    front: 'What is a Graph?',
    back: 'A non-linear data structure consisting of vertices (nodes) and edges (connections). Can be directed/undirected, weighted/unweighted. Representations: adjacency matrix, adjacency list.',
  ),
  Flashcard(
    front: 'What is BFS vs DFS?',
    back: 'BFS (Breadth-First Search): Explores level by level using a queue. Finds shortest path. DFS (Depth-First Search): Explores deep using a stack/recursion. Uses less memory for sparse graphs.',
  ),
  Flashcard(
    front: 'What is a Heap?',
    back: 'A complete binary tree that satisfies the heap property. Max-Heap: parent ≥ children. Min-Heap: parent ≤ children. Used in priority queues, heap sort. O(log n) insert/delete.',
  ),
  Flashcard(
    front: 'What is the difference between == and === in JavaScript?',
    back: '== performs type coercion before comparison (loose equality). === checks both value and type without coercion (strict equality). Always prefer === to avoid unexpected behavior.',
  ),
  Flashcard(
    front: 'What is polymorphism in OOP?',
    back: 'The ability of objects to take multiple forms. Allows methods to behave differently based on the object calling them. Types: compile-time (overloading) and runtime (overriding).',
  ),
  Flashcard(
    front: 'What is the CAP theorem?',
    back: 'States that distributed systems can only guarantee 2 of 3: Consistency (all nodes see same data), Availability (every request gets response), Partition Tolerance (works despite network failures).',
  ),
  Flashcard(
    front: 'What is REST API?',
    back: 'Representational State Transfer - architectural style for web services. Uses HTTP methods (GET, POST, PUT, DELETE), stateless communication, resource-based URLs, and standard status codes.',
  ),
  Flashcard(
    front: 'What is the difference between SQL and NoSQL?',
    back: 'SQL: Relational, structured schema, ACID transactions, vertical scaling (MySQL, PostgreSQL). NoSQL: Non-relational, flexible schema, horizontal scaling, eventual consistency (MongoDB, Cassandra).',
  ),
  Flashcard(
    front: 'What is a Closure in JavaScript?',
    back: 'A function that has access to variables in its outer (enclosing) scope, even after the outer function has returned. Enables data privacy, factory functions, and callbacks.',
  ),
  Flashcard(
    front: 'What is the difference between Process and Thread?',
    back: 'Process: Independent program with own memory space, heavyweight, isolated. Thread: Lightweight unit within a process, shares memory, faster context switching, enables concurrency.',
  ),
  Flashcard(
    front: 'What is the Singleton pattern?',
    back: 'A design pattern that restricts a class to a single instance and provides global access to it. Used for logging, configuration, database connections. Ensures one shared state across the app.',
  ),
  Flashcard(
    front: 'What is Git merge vs rebase?',
    back: 'Merge: Creates a new merge commit, preserves complete history, non-destructive. Rebase: Rewrites commits on top of another branch, creates linear history, cleaner but rewrites history.',
  ),
  Flashcard(
    front: 'What is the difference between Stack and Heap memory?',
    back: 'Stack: Stores local variables and function calls, LIFO, automatic allocation/deallocation, fast, limited size. Heap: Stores dynamic objects, manual management, slower, larger, risk of memory leaks.',
  ),
  Flashcard(
    front: 'What is asynchronous programming?',
    back: 'Programming paradigm where operations run independently without blocking execution. Uses callbacks, promises, async/await. Enables non-blocking I/O, better performance, and responsive UIs.',
  ),
  Flashcard(
    front: 'What is the SOLID principle?',
    back: 'Five OOP design principles: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. Promotes maintainable, scalable, and flexible code architecture.',
  ),
];