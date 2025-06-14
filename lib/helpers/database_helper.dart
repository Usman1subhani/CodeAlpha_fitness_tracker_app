import 'package:fitness_tracker_app/model/exercise.dart';
import 'package:fitness_tracker_app/model/goal.dart';
import 'package:fitness_tracker_app/model/workout.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; 

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        totalMinutes INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        completedMinutes INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        minutes INTEGER NOT NULL,
        date TEXT NOT NULL,
        calories INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (goalId) REFERENCES goals (id)
      )
    ''');
  }

  // Exercise CRUD operations
  Future<int> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await instance.database;
    final result = await db.query('exercises');
    return result.map((json) => Exercise.fromMap(json)).toList();
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await instance.database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await instance.database;
    final result = await db.query('goals');
    return result.map((json) => Goal.fromMap(json)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Workout CRUD operations
  Future<int> insertWorkout(Workout workout) async {
    final db = await instance.database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await instance.database;
    final result = await db.query('workouts');
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  Future<List<Workout>> getWorkoutsByGoal(int goalId) async {
    final db = await instance.database;
    final result = await db.query(
      'workouts',
      where: 'goalId = ?',
      whereArgs: [goalId],
    );
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await instance.database;
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await instance.database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch workouts for a specific date (YYYY-MM-DD)
  Future<List<Workout>> getWorkoutsByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'workouts',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  // Fetch workouts for a date range (inclusive, YYYY-MM-DD)
  Future<List<Workout>> getWorkoutsByDateRange(String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'workouts',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  // Get total workouts for a specific date
  Future<int> getTotalWorkoutsByDate(String date) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM workouts WHERE date = ?', [date]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total calories burned for a specific date
  Future<int> getTotalCaloriesByDate(String date) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(calories) FROM workouts WHERE date = ?', [date]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Progress statistics
  Future<int> getTotalWorkouts() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM workouts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalGoals() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM goals');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedGoals() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) FROM goals g
      WHERE g.completedMinutes >= g.totalMinutes
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalCaloriesBurned() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(calories) FROM workouts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}