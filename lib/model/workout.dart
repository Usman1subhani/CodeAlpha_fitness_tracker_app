import 'package:intl/intl.dart';

class Workout {
  int? id;
  final int goalId;
  final int minutes;
  final DateTime date;
  final int calories;
  final String? notes;

  Workout({
    this.id,
    required this.goalId,
    required this.minutes,
    required this.date,
    required this.calories,
    this.notes,
  });

  String get formattedDate {
    return DateFormat('MMM d, y').format(date);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'minutes': minutes,
      'date': date.toIso8601String(),
      'calories': calories,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      goalId: map['goalId'],
      minutes: map['minutes'],
      date: DateTime.parse(map['date']),
      calories: map['calories'],
      notes: map['notes'],
    );
  }
}
