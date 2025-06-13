import 'package:intl/intl.dart';

class Goal {
  int? id;
  final String title;
  final int totalMinutes;
  final DateTime startDate;
  final DateTime endDate;
  int completedMinutes;

  Goal({
    this.id,
    required this.title,
    required this.totalMinutes,
    required this.startDate,
    required this.endDate,
    this.completedMinutes = 0,
  });

  double get progressPercentage {
    return (completedMinutes / totalMinutes).clamp(0.0, 1.0);
  }

  String get formattedDateRange {
    final format = DateFormat('MMM d, y');
    return '${format.format(startDate)} - ${format.format(endDate)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalMinutes': totalMinutes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'completedMinutes': completedMinutes,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      totalMinutes: map['totalMinutes'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      completedMinutes: map['completedMinutes'],
    );
  }
}