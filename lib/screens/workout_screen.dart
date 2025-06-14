import 'package:fitness_tracker_app/model/goal.dart';
import 'package:fitness_tracker_app/model/workout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../helpers/database_helper.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedGoalId;
  List<Goal> _goals = [];
  List<Workout> _workouts = [];
  bool _isLoading = true;
  
  // Edit mode state
  bool _isEditMode = false;
  int? _editingWorkoutId;

  // Modern color palette
  final Color primaryColor = Color(0xFF6C63FF); // purple
  final Color accentColor = Color(0xFF00BFAE); // teal
  final Color orangeColor = Color(0xFFFFA726);
  final Color grayColor = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _goals = await DatabaseHelper.instance.getAllGoals();
    _workouts = await DatabaseHelper.instance.getAllWorkouts();
    // Sort workouts by date descending, then by id descending (latest first)
    _workouts.sort((a, b) {
      int dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });
    setState(() => _isLoading = false);
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate() && 
        _selectedGoalId != null && 
        _selectedDate != null) {
      if (_isEditMode && _editingWorkoutId != null) {
        // Update existing workout
        final oldWorkout = _workouts.firstWhere((w) => w.id == _editingWorkoutId);
        final goal = _goals.firstWhere((g) => g.id == _selectedGoalId);
        // Adjust completedMinutes: remove old, add new
        goal.completedMinutes -= oldWorkout.minutes;
        final updatedWorkout = Workout(
          id: _editingWorkoutId,
          goalId: _selectedGoalId!,
          minutes: int.parse(_minutesController.text),
          date: _selectedDate!,
          calories: int.parse(_caloriesController.text),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        await DatabaseHelper.instance.updateWorkout(updatedWorkout);
        goal.completedMinutes += updatedWorkout.minutes;
        await DatabaseHelper.instance.updateGoal(goal);
      } else {
        // Insert new workout
        final workout = Workout(
          goalId: _selectedGoalId!,
          minutes: int.parse(_minutesController.text),
          date: _selectedDate!,
          calories: int.parse(_caloriesController.text),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        await DatabaseHelper.instance.insertWorkout(workout);
        final goal = _goals.firstWhere((g) => g.id == _selectedGoalId);
        goal.completedMinutes += workout.minutes;
        await DatabaseHelper.instance.updateGoal(goal);
      }
      _loadData();
      _clearForm();
    }
  }

  void _clearForm() {
    _minutesController.clear();
    _caloriesController.clear();
    _notesController.clear();
    setState(() {
      _selectedGoalId = null;
      _selectedDate = null;
      _isEditMode = false;
      _editingWorkoutId = null;
    });
  }

  void _startEditWorkout(Workout workout) {
    setState(() {
      _isEditMode = true;
      _editingWorkoutId = workout.id;
      _selectedGoalId = workout.goalId;
      _selectedDate = workout.date;
      _minutesController.text = workout.minutes.toString();
      _caloriesController.text = workout.calories.toString();
      _notesController.text = workout.notes ?? '';
    });
  }

  Future<void> _deleteWorkout(int id, int minutes, int goalId) async {
    await DatabaseHelper.instance.deleteWorkout(id);
    final goal = _goals.firstWhere((g) => g.id == goalId);
    goal.completedMinutes -= minutes;
    await DatabaseHelper.instance.updateGoal(goal);
    _loadData();
    if (_isEditMode && _editingWorkoutId == id) {
      _clearForm();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Workout Tracker', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedGoalId,
                          decoration: InputDecoration(
                            labelText: 'Select Goal',
                            prefixIcon: Icon(Icons.flag, color: accentColor),
                            border: OutlineInputBorder(),
                          ),
                          items: _goals.map((goal) {
                            return DropdownMenuItem<int>(
                              value: goal.id,
                              child: Text(goal.title),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGoalId = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a goal';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _minutesController,
                          decoration: InputDecoration(
                            labelText: 'Minutes',
                            prefixIcon: Icon(Icons.timer, color: accentColor),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter minutes';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.date_range, color: accentColor),
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'Select Date'
                                      : DateFormat('MMM d, y').format(_selectedDate!),
                                  style: TextStyle(
                                    color: _selectedDate == null ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _caloriesController,
                          decoration: InputDecoration(
                            labelText: 'Calories Burned',
                            prefixIcon: Icon(Icons.local_fire_department, color: orangeColor),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter calories burned';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            prefixIcon: Icon(Icons.notes, color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveWorkout,
                                icon: Icon(_isEditMode ? Icons.save : Icons.add, color: Colors.white),
                                label: Text(_isEditMode ? 'Update Workout' : 'Save Workout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (_isEditMode) ...[
                              SizedBox(width: 12),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.redAccent),
                                tooltip: 'Cancel Edit',
                                onPressed: _clearForm,
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _workouts.isEmpty
                        ? Center(child: Text('No workouts recorded yet', style: TextStyle(color: Colors.grey)))
                        : Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: _workouts.length,
                              itemBuilder: (context, index) {
                                final workout = _workouts[index];
                                final goal = _goals.firstWhere(
                                  (g) => g.id == workout.goalId,
                                  orElse: () => Goal(
                                    title: 'Unknown Goal',
                                    totalMinutes: 0,
                                    startDate: DateTime.now(),
                                    endDate: DateTime.now(),
                                  ),
                                );
                                // Group by date: show a date header if this is the first workout for that date
                                bool showDateHeader = index == 0 || workout.dateString != _workouts[index - 1].dateString;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDateHeader)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 2),
                                        child: Text(
                                          workout.formattedDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    Card(
                                      color: Colors.white,
                                      elevation: 3,
                                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: accentColor.withOpacity(0.15),
                                          child: Icon(Icons.directions_run, color: accentColor),
                                        ),
                                        title: Text(goal.title, style: TextStyle(color: Colors.black87)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.timer, size: 16, color: accentColor),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${workout.minutes} min',
                                                    style: TextStyle(color: Colors.black54),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.local_fire_department, size: 16, color: orangeColor),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${workout.calories} cal',
                                                    style: TextStyle(color: Colors.black54),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.notes, size: 16, color: Colors.grey),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      workout.notes!,
                                                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black45),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: orangeColor),
                                              tooltip: 'Edit',
                                              onPressed: () => _startEditWorkout(workout),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.redAccent),
                                              tooltip: 'Delete',
                                              onPressed: () => _deleteWorkout(
                                                workout.id!,
                                                workout.minutes,
                                                workout.goalId,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}