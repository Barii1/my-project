import 'package:flutter/material.dart';

class TopicQuizScreen extends StatefulWidget {
  final Map<String, dynamic> topic;

  const TopicQuizScreen({super.key, required this.topic});

  @override
  State<TopicQuizScreen> createState() => _TopicQuizScreenState();
}

class _TopicQuizScreenState extends State<TopicQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final topicId = widget.topic['id'] as String;
    _questions = _getQuestionsForTopic(topicId);
  }

  List<Map<String, dynamic>> _getQuestionsForTopic(String topicId) {
    // Computer Science Topics
    if (topicId == 'arrays-strings') {
      return [
        {
          'question': 'What is the time complexity of accessing an element in an array by index?',
          'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
          'correctAnswer': 0,
        },
        {
          'question': 'Which string operation has O(n) time complexity?',
          'options': ['Accessing a character', 'Finding length', 'Concatenation', 'Comparing two strings'],
          'correctAnswer': 3,
        },
        {
          'question': 'What is the result of "Hello".substring(1, 4)?',
          'options': ['Hel', 'ell', 'ello', 'Hell'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'linked-lists') {
      return [
        {
          'question': 'What is the time complexity of inserting at the head of a singly linked list?',
          'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
          'correctAnswer': 0,
        },
        {
          'question': 'Which pointer does a doubly linked list node contain?',
          'options': ['Only next', 'Only prev', 'Both next and prev', 'None'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is the main advantage of linked lists over arrays?',
          'options': ['Random access', 'Dynamic size', 'Cache locality', 'Less memory'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'stacks-queues') {
      return [
        {
          'question': 'What principle does a stack follow?',
          'options': ['FIFO', 'LIFO', 'LILO', 'Random'],
          'correctAnswer': 1,
        },
        {
          'question': 'Which operation is NOT a standard stack operation?',
          'options': ['Push', 'Pop', 'Peek', 'Dequeue'],
          'correctAnswer': 3,
        },
        {
          'question': 'What data structure is used for BFS traversal?',
          'options': ['Stack', 'Queue', 'Array', 'Tree'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'trees-bst') {
      return [
        {
          'question': 'What is the maximum number of children a binary tree node can have?',
          'options': ['1', '2', '3', 'Unlimited'],
          'correctAnswer': 1,
        },
        {
          'question': 'In a BST, where are values less than the root stored?',
          'options': ['Right subtree', 'Left subtree', 'Root', 'Anywhere'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the time complexity of searching in a balanced BST?',
          'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'graphs') {
      return [
        {
          'question': 'Which data structure is commonly used to represent a graph?',
          'options': ['Array only', 'Adjacency list', 'Stack', 'Queue'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is a graph with no cycles called?',
          'options': ['Connected graph', 'Complete graph', 'Acyclic graph', 'Directed graph'],
          'correctAnswer': 2,
        },
        {
          'question': 'Which algorithm finds shortest path in weighted graphs?',
          'options': ['BFS', 'DFS', 'Dijkstra', 'Binary Search'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'sorting') {
      return [
        {
          'question': 'What is the average time complexity of Quick Sort?',
          'options': ['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'],
          'correctAnswer': 1,
        },
        {
          'question': 'Which sorting algorithm is NOT comparison-based?',
          'options': ['Merge Sort', 'Quick Sort', 'Counting Sort', 'Heap Sort'],
          'correctAnswer': 2,
        },
        {
          'question': 'Which sorting algorithm is stable?',
          'options': ['Quick Sort', 'Heap Sort', 'Merge Sort', 'Selection Sort'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'searching') {
      return [
        {
          'question': 'What is required for binary search to work?',
          'options': ['Sorted array', 'Linked list', 'Tree', 'Graph'],
          'correctAnswer': 0,
        },
        {
          'question': 'What is the time complexity of linear search?',
          'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
          'correctAnswer': 2,
        },
        {
          'question': 'In binary search, how is the search space reduced?',
          'options': ['By 1 element', 'By half', 'By quarter', 'Randomly'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'recursion') {
      return [
        {
          'question': 'What is the base case in recursion?',
          'options': ['First call', 'Last call', 'Stopping condition', 'Middle call'],
          'correctAnswer': 2,
        },
        {
          'question': 'What happens if recursion has no base case?',
          'options': ['Compiles faster', 'Stack overflow', 'Works fine', 'Memory leak'],
          'correctAnswer': 1,
        },
        {
          'question': 'Which is NOT solved efficiently with recursion?',
          'options': ['Factorial', 'Fibonacci', 'Linear search in array', 'Tree traversal'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'dynamic-programming') {
      return [
        {
          'question': 'What technique does DP use to optimize recursive solutions?',
          'options': ['Divide and conquer', 'Greedy', 'Memoization', 'Backtracking'],
          'correctAnswer': 2,
        },
        {
          'question': 'Which approach builds solution bottom-up in DP?',
          'options': ['Memoization', 'Tabulation', 'Recursion', 'Iteration'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is required for a problem to use DP?',
          'options': ['Optimal substructure', 'Sorted input', 'Tree structure', 'Graph'],
          'correctAnswer': 0,
        },
      ];
    } else if (topicId == 'oop') {
      return [
        {
          'question': 'What is encapsulation in OOP?',
          'options': ['Inheritance', 'Data hiding', 'Polymorphism', 'Abstraction'],
          'correctAnswer': 1,
        },
        {
          'question': 'Which keyword is used for inheritance in most languages?',
          'options': ['implements', 'extends', 'inherits', 'derives'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is polymorphism?',
          'options': ['Many forms', 'Single form', 'No form', 'Abstract form'],
          'correctAnswer': 0,
        },
      ];
    } else if (topicId == 'databases') {
      return [
        {
          'question': 'What does SQL stand for?',
          'options': ['Structured Query Language', 'Simple Query Language', 'System Query Language', 'Standard Query Language'],
          'correctAnswer': 0,
        },
        {
          'question': 'Which SQL command is used to retrieve data?',
          'options': ['INSERT', 'UPDATE', 'SELECT', 'DELETE'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is a primary key?',
          'options': ['Any column', 'Unique identifier', 'Foreign key', 'Index'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'operating-systems') {
      return [
        {
          'question': 'What is the main function of an operating system?',
          'options': ['Browse web', 'Manage resources', 'Edit documents', 'Play games'],
          'correctAnswer': 1,
        },
        {
          'question': 'Which scheduling algorithm gives shortest jobs priority?',
          'options': ['FCFS', 'Round Robin', 'SJF', 'Priority'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is a deadlock?',
          'options': ['Fast execution', 'Circular wait', 'CPU scheduling', 'Memory allocation'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'computer-networks') {
      return [
        {
          'question': 'Which layer of OSI model handles routing?',
          'options': ['Physical', 'Data Link', 'Network', 'Transport'],
          'correctAnswer': 2,
        },
        {
          'question': 'What protocol is used for web browsing?',
          'options': ['FTP', 'SMTP', 'HTTP', 'SSH'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is the IP address range for Class A?',
          'options': ['0-127', '128-191', '192-223', '224-255'],
          'correctAnswer': 0,
        },
      ];
    }
    // Mathematics Topics
    else if (topicId == 'algebra') {
      return [
        {
          'question': 'What is the solution to x + 5 = 12?',
          'options': ['5', '7', '12', '17'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the quadratic formula?',
          'options': ['x = b/2a', 'x = (-b ± √(b²-4ac))/2a', 'x = ab²', 'x = a + b'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is (x + 2)² equal to?',
          'options': ['x² + 4', 'x² + 2x + 4', 'x² + 4x + 4', 'x² + 2'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'linear-algebra') {
      return [
        {
          'question': 'What is a matrix with one row called?',
          'options': ['Column matrix', 'Row matrix', 'Square matrix', 'Identity matrix'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the determinant of a 2x2 identity matrix?',
          'options': ['0', '1', '2', '4'],
          'correctAnswer': 1,
        },
        {
          'question': 'What operation combines matrices by element-wise multiplication?',
          'options': ['Dot product', 'Cross product', 'Hadamard product', 'Matrix multiplication'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'calculus-1') {
      return [
        {
          'question': 'What is the derivative of x²?',
          'options': ['x', '2x', 'x²', '2x²'],
          'correctAnswer': 1,
        },
        {
          'question': 'What does the derivative represent?',
          'options': ['Area', 'Volume', 'Rate of change', 'Distance'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is the integral of 1/x?',
          'options': ['x', 'ln|x|', 'e^x', '1/x²'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'calculus-2') {
      return [
        {
          'question': 'What method is used for ∫u dv?',
          'options': ['Substitution', 'Integration by parts', 'Partial fractions', 'Direct integration'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is a Taylor series?',
          'options': ['Geometric series', 'Power series expansion', 'Arithmetic series', 'Harmonic series'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the integral of e^x?',
          'options': ['e^x', 'xe^x', 'ln(x)', '1/e^x'],
          'correctAnswer': 0,
        },
      ];
    } else if (topicId == 'discrete-math') {
      return [
        {
          'question': 'What is 5! (5 factorial)?',
          'options': ['20', '60', '120', '240'],
          'correctAnswer': 2,
        },
        {
          'question': 'How many subsets does a set with n elements have?',
          'options': ['n', 'n²', '2^n', 'n!'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is the complement of set A?',
          'options': ['A itself', 'Empty set', 'Universal set - A', 'A ∩ B'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'probability') {
      return [
        {
          'question': 'What is the probability of getting heads when flipping a fair coin?',
          'options': ['0', '0.25', '0.5', '1'],
          'correctAnswer': 2,
        },
        {
          'question': 'If two events are independent, P(A and B) = ?',
          'options': ['P(A) + P(B)', 'P(A) × P(B)', 'P(A) / P(B)', 'P(A) - P(B)'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the sum of all probabilities in a sample space?',
          'options': ['0', '0.5', '1', 'Infinity'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'statistics') {
      return [
        {
          'question': 'What measure represents the middle value in a dataset?',
          'options': ['Mean', 'Median', 'Mode', 'Range'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the most frequently occurring value called?',
          'options': ['Mean', 'Median', 'Mode', 'Variance'],
          'correctAnswer': 2,
        },
        {
          'question': 'What measures the spread of data?',
          'options': ['Mean', 'Median', 'Standard deviation', 'Mode'],
          'correctAnswer': 2,
        },
      ];
    } else if (topicId == 'geometry') {
      return [
        {
          'question': 'What is the sum of angles in a triangle?',
          'options': ['90°', '180°', '270°', '360°'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the area of a circle with radius r?',
          'options': ['πr', 'πr²', '2πr', 'πr³'],
          'correctAnswer': 1,
        },
        {
          'question': 'How many sides does a hexagon have?',
          'options': ['5', '6', '7', '8'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'trigonometry') {
      return [
        {
          'question': 'What is sin²θ + cos²θ equal to?',
          'options': ['0', '1', 'sin θ', 'cos θ'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the value of sin(90°)?',
          'options': ['0', '0.5', '1', 'undefined'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is tan θ equal to?',
          'options': ['sin θ / cos θ', 'cos θ / sin θ', 'sin θ × cos θ', '1 / sin θ'],
          'correctAnswer': 0,
        },
      ];
    } else if (topicId == 'number-theory') {
      return [
        {
          'question': 'What is the smallest prime number?',
          'options': ['0', '1', '2', '3'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is GCD(12, 18)?',
          'options': ['2', '3', '6', '9'],
          'correctAnswer': 2,
        },
        {
          'question': 'Which number is NOT prime?',
          'options': ['2', '3', '4', '5'],
          'correctAnswer': 2,
        },
      ];
    }
    // General Knowledge Topics
    else if (topicId == 'general-science') {
      return [
        {
          'question': 'What is the chemical symbol for water?',
          'options': ['H2O', 'O2', 'CO2', 'H2'],
          'correctAnswer': 0,
        },
        {
          'question': 'What planet is known as the Red Planet?',
          'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the speed of light?',
          'options': ['300,000 km/s', '150,000 km/s', '500,000 km/s', '100,000 km/s'],
          'correctAnswer': 0,
        },
      ];
    } else if (topicId == 'tech-trivia') {
      return [
        {
          'question': 'Who is the founder of Microsoft?',
          'options': ['Steve Jobs', 'Bill Gates', 'Mark Zuckerberg', 'Elon Musk'],
          'correctAnswer': 1,
        },
        {
          'question': 'What does CPU stand for?',
          'options': ['Central Processing Unit', 'Computer Personal Unit', 'Central Program Utility', 'Computer Processing Utility'],
          'correctAnswer': 0,
        },
        {
          'question': 'When was the first iPhone released?',
          'options': ['2005', '2007', '2009', '2010'],
          'correctAnswer': 1,
        },
      ];
    } else if (topicId == 'math-puzzles') {
      return [
        {
          'question': 'If 2 + 2 = 4, and 3 + 3 = 6, what is 4 + 4?',
          'options': ['6', '7', '8', '9'],
          'correctAnswer': 2,
        },
        {
          'question': 'What is the next number: 2, 4, 8, 16, __?',
          'options': ['20', '24', '28', '32'],
          'correctAnswer': 3,
        },
        {
          'question': 'How many triangles are in a pentagram (5-pointed star)?',
          'options': ['5', '10', '15', '20'],
          'correctAnswer': 1,
        },
      ];
    }

    // Default fallback questions
    return [
      {
        'question': 'This is a sample question for ${widget.topic['name']}',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correctAnswer': 0,
      },
    ];
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null || _hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      if (_selectedAnswerIndex == _questions[_currentQuestionIndex]['correctAnswer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quiz Complete! 🎉',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_score / ${_questions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3DA89A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${((_score / _questions.length) * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswerIndex = null;
                _hasAnswered = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3DA89A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<String>;
    final correctAnswer = question['correctAnswer'] as int;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF34495E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.topic['name'] as String,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3DA89A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: const Color(0xFF3DA89A),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 32),

              // Question card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Text(
                  question['question'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34495E),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswerIndex == index;
                    final isCorrect = index == correctAnswer;
                    final showCorrect = _hasAnswered && isCorrect;
                    final showWrong = _hasAnswered && isSelected && !isCorrect;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: showCorrect
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : showWrong
                                      ? const Color(0xFFEF4444).withOpacity(0.1)
                                      : isSelected
                                          ? const Color(0xFF3DA89A).withOpacity(0.1)
                                          : (isDark ? const Color(0xFF16213E) : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: showCorrect
                                    ? const Color(0xFF10B981)
                                    : showWrong
                                        ? const Color(0xFFEF4444)
                                        : isSelected
                                            ? const Color(0xFF3DA89A)
                                            : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                                width: showCorrect || showWrong ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: showCorrect
                                          ? const Color(0xFF10B981)
                                          : showWrong
                                              ? const Color(0xFFEF4444)
                                              : isSelected
                                                  ? const Color(0xFF3DA89A)
                                                  : const Color(0xFFD1D5DB),
                                      width: 2,
                                    ),
                                    color: showCorrect || showWrong || isSelected
                                        ? (showCorrect
                                            ? const Color(0xFF10B981)
                                            : showWrong
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF3DA89A))
                                        : Colors.transparent,
                                  ),
                                  child: showCorrect || showWrong || isSelected
                                      ? const Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.white : const Color(0xFF34495E),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (showCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF10B981),
                                    size: 24,
                                  ),
                                if (showWrong)
                                  const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFEF4444),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Action button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _selectedAnswerIndex == null && !_hasAnswered
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                        ),
                  color: _selectedAnswerIndex == null && !_hasAnswered ? const Color(0xFFE5E7EB) : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedAnswerIndex != null || _hasAnswered
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4DB8A8).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hasAnswered ? _nextQuestion : _submitAnswer,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          _hasAnswered
                              ? (_currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'Show Results')
                              : 'Submit Answer',
                          style: TextStyle(
                            color: _selectedAnswerIndex == null && !_hasAnswered
                                ? const Color(0xFF94A3B8)
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
