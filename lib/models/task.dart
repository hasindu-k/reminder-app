class Task {
  final String title;
  final String interval; // e.g. 'daily', 'weekly'
  Duration timeSpent;

  Task({
    required this.title,
    this.interval = 'daily',
    this.timeSpent = Duration.zero,
  });
}
