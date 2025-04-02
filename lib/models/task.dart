class Task {
  String title;
  String interval; // e.g. 'daily', 'weekly'
  Duration timeSpent;
  Map<String, int> history; // e.g., { "2025-03-27": 1800 }

  Task({
    required this.title,
    this.interval = 'daily',
    this.timeSpent = Duration.zero,
    Map<String, int>? history,
  }) : history = history ?? {};

  Map<String, dynamic> toJson() => {
        'title': title,
        'interval': interval,
        'timeSpent': timeSpent.inSeconds,
        'history': history,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        interval: json['interval'],
        timeSpent: Duration(seconds: json['timeSpent']),
        history: Map<String, int>.from(json['history'] ?? {}),
      );
}
