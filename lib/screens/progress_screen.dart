import 'package:fitness_tracker_app/model/goal.dart';
import 'package:fitness_tracker_app/model/workout.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';

// Move _GoalDayProgress to top-level
class _GoalDayProgress {
  final String title;
  final int doneToday;
  final int expectedToday;
  final Color color;
  _GoalDayProgress(this.title, this.doneToday, this.expectedToday, this.color);
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _ProgressScreenState();

  int _totalGoals = 0;

  // Selected date and week dates for the selector
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDates = [];

  // Blinking animation for the selected day
  bool _isBlinking = false;

  // Modern color palette
  final Color primaryColor = Color(0xFF6C63FF); // purple
  final Color accentColor = Color(0xFF00BFAE); // teal
  final Color orangeColor = Color(0xFFFFA726);
  final Color grayColor = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _setWeekDates(_selectedDate);
    _loadStats();
    _loadFilteredStats();
  }

  void _setWeekDates(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    _weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _loadFilteredStats() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final workouts = await DatabaseHelper.instance.getWorkoutsByDate(dateStr);
    final goals = await DatabaseHelper.instance.getAllGoals();
    List<_GoalDayProgress> progressList = [];
    final colors = [accentColor, orangeColor, Colors.purple, Colors.blue, Colors.green, Colors.red, Colors.teal, Colors.amber];
    if (goals.isNotEmpty) {
      for (int i = 0; i < goals.length; i++) {
        final goal = goals[i];
        final totalDays = goal.endDate.difference(goal.startDate).inDays + 1;
        final expectedPerDay = (goal.totalMinutes / totalDays).ceil();
        final goalWorkouts = workouts.where((w) => w.goalId == goal.id).toList();
        final doneToday = goalWorkouts.fold<int>(0, (sum, w) => sum + w.minutes);
        progressList.add(_GoalDayProgress(goal.title, doneToday, expectedPerDay, colors[i % colors.length]));
      }
    }
    setState(() {
      // _filteredCalories = calories; // No longer used
      // _filteredMinutes = minutes; // No longer used
    });
  }

  void _onDaySelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isBlinking = true;
    });
    _setWeekDates(date);
    await _loadFilteredStats();
    _startBlinking();
  }

  void _startBlinking() async {
    for (int i = 0; i < 3; i++) {
      setState(() { _isBlinking = true; });
      await Future.delayed(Duration(milliseconds: 200));
      setState(() { _isBlinking = false; });
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() { _isBlinking = false; });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final totalGoals = await DatabaseHelper.instance.getTotalGoals();
    setState(() {
      _totalGoals = totalGoals;
    });
  }

  Widget _buildWeekSelector() {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _weekDates.map((date) {
            final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
            return GestureDetector(
              onTap: () => _onDaySelected(date),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12), // reduce vertical padding
                decoration: BoxDecoration(
                  color: isSelected && _isBlinking ? Colors.white : (isSelected ? accentColor : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? accentColor : grayColor, width: 2),
                  boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 8)] : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // prevent overflow
                  children: [
                    Text(DateFormat('E').format(date), style: TextStyle(
                      color: isSelected ? primaryColor : Colors.black54,
                      fontWeight: FontWeight.bold,
                    )),
                    SizedBox(height: 2), // reduce spacing
                    Text(date.day.toString(), style: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWorkoutChart() {
    return FutureBuilder<List<Workout>>(
      future: DatabaseHelper.instance.getWorkoutsByDateRange(
        DateFormat('yyyy-MM-dd').format(_weekDates.first),
        DateFormat('yyyy-MM-dd').format(_weekDates.last),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final workouts = snapshot.data!;
        final Map<String, int> dayTotals = { for (var d in _weekDates) DateFormat('yyyy-MM-dd').format(d): 0 };
        for (var w in workouts) {
          final wDate = w.dateString;
          if (dayTotals.containsKey(wDate)) {
            dayTotals[wDate] = (dayTotals[wDate] ?? 0) + w.minutes;
          }
        }
        // Find min/max for coloring
        final values = dayTotals.values.toList();
        final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;
        final minVal = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: ((maxVal + 10) / 60).ceil() * 60.0, // round up to next hour
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 60 == 0) {
                          return Text('${(value ~/ 60)}h', style: TextStyle(color: Colors.black54));
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _weekDates.length) return SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(DateFormat('E').format(_weekDates[idx]), style: TextStyle(color: accentColor)),
                      );
                    }),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_weekDates.length, (index) {
                  final dateStr = DateFormat('yyyy-MM-dd').format(_weekDates[index]);
                  final val = dayTotals[dateStr] ?? 0;
                  Color barColor;
                  if (val == maxVal && val > 0) {
                    barColor = Colors.green;
                  } else if (val == minVal && val > 0) {
                    barColor = Colors.red;
                  } else if (val > 0) {
                    barColor = Colors.orange;
                  } else {
                    barColor = grayColor;
                  }
                  final isSelected = dateStr == DateFormat('yyyy-MM-dd').format(_selectedDate);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: val.toDouble(),
                        color: isSelected && _isBlinking ? Colors.purpleAccent : barColor,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsChart() {
    if (_totalGoals == 0) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text('No goals to display', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }
    // Fetch all goals and show each as a concentric progress circle
    return FutureBuilder<List<Goal>>(
      future: DatabaseHelper.instance.getAllGoals(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final goals = snapshot.data!;
        final List<Color> colors = [
          accentColor,
          orangeColor,
          Colors.purple,
          Colors.blue,
          Colors.green,
          Colors.red,
          Colors.teal,
          Colors.amber,
        ];
        final double baseRadius = MediaQuery.of(context).size.width * 0.38;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: baseRadius * 2 + 40,
              width: double.infinity,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < goals.length; i++)
                      SizedBox(
                        height: baseRadius * 2 - (i * 28),
                        width: baseRadius * 2 - (i * 28),
                        child: CircularProgressIndicator(
                          value: goals[i].progressPercentage,
                          strokeWidth: 16,
                          backgroundColor: colors[i % colors.length].withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(colors[i % colors.length]),
                        ),
                      ),
                    // Center: show each goal's percent and title
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < goals.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors[i % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  goals[i].title.length > 14 ? goals[i].title.substring(0, 14) + '...' : goals[i].title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${(goals[i].progressPercentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(color: colors[i % colors.length], fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayColor,
      appBar: AppBar(
        title: Text('Progress Overview', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWeekSelector(),
            SizedBox(height: 16),
            // Workout summary chart at the top
            Text(
              'Workout Summary (Week)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildWorkoutChart(),
            ),
            SizedBox(height: 24),
            // Goals progress at the bottom
            Text(
              'Goals Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildGoalsChart(),
            ),
          ],
        ),
      ),
    );
  }
}

