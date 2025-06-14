import 'package:fitness_tracker_app/model/goal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../helpers/database_helper.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<Goal> _goals = [];
  bool _isLoading = true;
  // Edit mode state
  bool _isEditMode = false;
  int? _editingGoalId;

  // Modern color palette
  final Color primaryColor = Color(0xFF6C63FF); // purple
  final Color accentColor = Color(0xFF00BFAE); // teal
  final Color orangeColor = Color(0xFFFFA726);
  final Color grayColor = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    _goals = await DatabaseHelper.instance.getAllGoals();
    setState(() => _isLoading = false);
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      if (_isEditMode && _editingGoalId != null) {
        final updatedGoal = Goal(
          id: _editingGoalId,
          title: _titleController.text,
          totalMinutes: int.parse(_minutesController.text),
          startDate: _startDate!,
          endDate: _endDate!,
          completedMinutes: _goals.firstWhere((g) => g.id == _editingGoalId).completedMinutes,
        );
        await DatabaseHelper.instance.updateGoal(updatedGoal);
      } else {
        final goal = Goal(
          title: _titleController.text,
          totalMinutes: int.parse(_minutesController.text),
          startDate: _startDate!,
          endDate: _endDate!,
        );
        await DatabaseHelper.instance.insertGoal(goal);
      }
      _loadGoals();
      _clearForm();
    }
  }

  void _clearForm() {
    _titleController.clear();
    _minutesController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _isEditMode = false;
      _editingGoalId = null;
    });
  }

  void _startEditGoal(Goal goal) {
    setState(() {
      _isEditMode = true;
      _editingGoalId = goal.id;
      _titleController.text = goal.title;
      _minutesController.text = goal.totalMinutes.toString();
      _startDate = goal.startDate;
      _endDate = goal.endDate;
    });
  }

  Future<void> _deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    _loadGoals();
    if (_isEditMode && _editingGoalId == id) {
      _clearForm();
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
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
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Fitness Goals', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Goal Title',
                            prefixIcon: Icon(Icons.flag, color: accentColor),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter goal title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _minutesController,
                          decoration: InputDecoration(
                            labelText: 'Total Minutes Required',
                            prefixIcon: Icon(Icons.timer, color: orangeColor),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total minutes';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectStartDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    prefixIcon: Icon(Icons.date_range, color: accentColor),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _startDate == null
                                        ? 'Select Date'
                                        : DateFormat('MMM d, y').format(_startDate!),
                                    style: TextStyle(
                                      color: _startDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectEndDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    prefixIcon: Icon(Icons.date_range, color: accentColor),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _endDate == null
                                        ? 'Select Date'
                                        : DateFormat('MMM d, y').format(_endDate!),
                                    style: TextStyle(
                                      color: _endDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveGoal,
                                icon: Icon(_isEditMode ? Icons.save : Icons.add, color: Colors.white),
                                label: Text(_isEditMode ? 'Update Goal' : 'Save Goal'),
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
              // Remove Expanded, just use ListView.builder with shrinkWrap
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _goals.isEmpty
                      ? Center(child: Text('No goals added yet', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            final goal = _goals[index];
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: primaryColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: orangeColor),
                                              tooltip: 'Edit',
                                              onPressed: () => _startEditGoal(goal),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.redAccent),
                                              tooltip: 'Delete',
                                              onPressed: () => _deleteGoal(goal.id!),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.date_range, size: 16, color: accentColor),
                                        SizedBox(width: 4),
                                        Text(goal.formattedDateRange, style: TextStyle(color: Colors.black54)),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: goal.progressPercentage,
                                      backgroundColor: Colors.grey[200],
                                      color: accentColor,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${goal.completedMinutes} / ${goal.totalMinutes} min completed',
                                      style: TextStyle(color: Colors.black45),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }
}