import 'package:fitness_tracker_app/model/exercise.dart';
import 'package:flutter/material.dart'; 
import '../helpers/database_helper.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  // Edit mode state
  bool _isEditMode = false;
  int? _editingExerciseId;
  // Track which card is expanded
  int? _expandedIndex;

  // Modern color palette
  final Color primaryColor = Color(0xFF6C63FF); // purple
  final Color accentColor = Color(0xFF00BFAE); // teal
  final Color orangeColor = Color(0xFFFFA726);
  final Color grayColor = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    _exercises = await DatabaseHelper.instance.getAllExercises();
    setState(() => _isLoading = false);
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode && _editingExerciseId != null) {
        final updatedExercise = Exercise(
          id: _editingExerciseId,
          name: _nameController.text,
          type: _typeController.text,
          description: _descriptionController.text,
        );
        await DatabaseHelper.instance.updateExercise(updatedExercise);
      } else {
        final exercise = Exercise(
          name: _nameController.text,
          type: _typeController.text,
          description: _descriptionController.text,
        );
        await DatabaseHelper.instance.insertExercise(exercise);
      }
      _loadExercises();
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _descriptionController.clear();
    setState(() {
      _isEditMode = false;
      _editingExerciseId = null;
    });
  }

  void _startEditExercise(Exercise exercise) {
    setState(() {
      _isEditMode = true;
      _editingExerciseId = exercise.id;
      _nameController.text = exercise.name;
      _typeController.text = exercise.type;
      _descriptionController.text = exercise.description;
    });
  }

  Future<void> _deleteExercise(int id) async {
    await DatabaseHelper.instance.deleteExercise(id);
    _loadExercises();
    if (_isEditMode && _editingExerciseId == id) {
      _clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grayColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Exercises', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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
                elevation: 20,
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
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Exercise Name',
                            prefixIcon: Icon(Icons.fitness_center, color: accentColor),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter exercise name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _typeController,
                          decoration: InputDecoration(
                            labelText: 'Type (e.g., Abs, Cardio)',
                            prefixIcon: Icon(Icons.category, color: orangeColor),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter exercise type';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description, color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveExercise,
                                icon: Icon(_isEditMode ? Icons.save : Icons.add, color: Colors.white),
                                label: Text(_isEditMode ? 'Update Exercise' : 'Save Exercise'),
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
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _exercises.isEmpty
                        ? Center(child: Text('No exercises added yet', style: TextStyle(color: Colors.grey)))
                        : Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: _exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = _exercises[index];
                                final isExpanded = _expandedIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? null : index;
                                    });
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 3,
                                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: accentColor.withOpacity(0.15),
                                        child: Icon(Icons.fitness_center, color: accentColor),
                                      ),
                                      title: Text(
                                        exercise.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.category, size: 16, color: orangeColor),
                                              SizedBox(width: 4),
                                              Text('Type: ${exercise.type}', style: TextStyle(color: Colors.black54)),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.description, size: 16, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: AnimatedCrossFade(
                                                  firstChild: Text(
                                                    exercise.description.length > 40 && !isExpanded
                                                        ? exercise.description.substring(0, 40) + '...'
                                                        : exercise.description,
                                                    style: TextStyle(color: Colors.black45),
                                                    maxLines: isExpanded ? null : 1,
                                                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                                  ),
                                                  secondChild: Text(
                                                    exercise.description,
                                                    style: TextStyle(color: Colors.black45),
                                                  ),
                                                  crossFadeState: isExpanded
                                                      ? CrossFadeState.showSecond
                                                      : CrossFadeState.showFirst,
                                                  duration: Duration(milliseconds: 200),
                                                ),
                                              ),
                                              if (exercise.description.length > 40)
                                                Icon(
                                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                                  color: accentColor,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: orangeColor),
                                            tooltip: 'Edit',
                                            onPressed: () => _startEditExercise(exercise),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.redAccent),
                                            tooltip: 'Delete',
                                            onPressed: () => _deleteExercise(exercise.id!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}