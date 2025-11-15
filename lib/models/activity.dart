class Activity {
  final int id;
  final String type;
  final String title;
  final String subject;
  final int? score;
  final String time;
  final String date;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.subject,
    this.score,
    required this.time,
    required this.date,
  });
}

final List<Activity> activityData = [
  Activity(
    id: 1,
    type: 'quiz',
    title: 'Data Structures Basics',
    subject: 'CS',
    score: 85,
    time: '2h ago',
    date: 'Today',
  ),
  Activity(
    id: 2,
    type: 'ai',
    title: 'Asked about Binary Trees',
    subject: 'CS',
    time: '3h ago',
    date: 'Today',
  ),
  Activity(
    id: 3,
    type: 'note',
    title: 'Algorithm Analysis Notes',
    subject: 'CS',
    time: '5h ago',
    date: 'Today',
  ),
  Activity(
    id: 4,
    type: 'quiz',
    title: 'Calculus - Derivatives',
    subject: 'Math',
    score: 92,
    time: '1d ago',
    date: 'Yesterday',
  ),
  Activity(
    id: 5,
    type: 'ai',
    title: 'Integration techniques',
    subject: 'Math',
    time: '1d ago',
    date: 'Yesterday',
  ),
  Activity(
    id: 6,
    type: 'flashcard',
    title: 'Algorithm Complexity',
    subject: 'CS',
    time: '2d ago',
    date: 'Oct 24',
  ),
  Activity(
    id: 7,
    type: 'quiz',
    title: 'Sorting Algorithms',
    subject: 'CS',
    score: 78,
    time: '2d ago',
    date: 'Oct 24',
  ),
  Activity(
    id: 8,
    type: 'note',
    title: 'Linear Algebra Study Guide',
    subject: 'Math',
    time: '3d ago',
    date: 'Oct 23',
  ),
];