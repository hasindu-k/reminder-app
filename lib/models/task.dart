class Task {
  String title;
  String interval; // e.g. 'daily', 'weekly'
  Duration timeSpent;

  Task({
    required this.title,
    this.interval = 'daily',
    this.timeSpent = Duration.zero,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'interval': interval,
        'timeSpent': timeSpent.inSeconds,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        interval: json['interval'],
        timeSpent: Duration(seconds: json['timeSpent']),
      );
}
