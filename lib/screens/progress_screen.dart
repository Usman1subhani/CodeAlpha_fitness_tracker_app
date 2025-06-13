import 'package:fitness_tracker_app/model/goal.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _ProgressScreenState();

  int _totalWorkouts = 0;
  int _totalGoals = 0;
  int _completedGoals = 0;
  int _totalCalories = 0;

  // Modern color palette
  final Color primaryColor = Color(0xFF6C63FF); // purple
  final Color accentColor = Color(0xFF00BFAE); // teal
  final Color orangeColor = Color(0xFFFFA726);
  final Color grayColor = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final totalWorkouts = await DatabaseHelper.instance.getTotalWorkouts();
    final totalGoals = await DatabaseHelper.instance.getTotalGoals();
    final completedGoals = await DatabaseHelper.instance.getCompletedGoals();
    final totalCalories = await DatabaseHelper.instance.getTotalCaloriesBurned();
    setState(() {
      _totalWorkouts = totalWorkouts;
      _totalGoals = totalGoals;
      _completedGoals = completedGoals;
      _totalCalories = totalCalories;
    });
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('Total Workouts', _totalWorkouts.toString(), Icons.fitness_center, accentColor),
                _buildStatCard('Total Goals', _totalGoals.toString(), Icons.flag, primaryColor),
                _buildStatCard('Goals Achieved', _completedGoals.toString(), Icons.check_circle, orangeColor),
                _buildStatCard('Calories Burned', _totalCalories.toString(), Icons.local_fire_department, Colors.redAccent),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Workout Summary',
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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 2, // 2 cards per row with padding
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutChart() {
    // This is a placeholder - you would fetch actual workout data
    // and format it for the chart in a real app
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
            maxY: 20,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt() % 7], style: TextStyle(color: accentColor)),
                  );
                }),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (index + 1) * 2.0,
                    color: accentColor,
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

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

