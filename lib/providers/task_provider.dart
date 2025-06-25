import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.dateTime.year == today.year &&
          task.dateTime.month == today.month &&
          task.dateTime.day == today.day;
    }).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Stream<List<Task>> getTasksStream(String userId) {
    return _supabaseService.getTasks(userId);
  }

  Future<List<Task>> getTasksByDate(String userId, DateTime date) async {
    return await _supabaseService.getTasksByDate(userId, date);
  }

  Future<void> addTask(Task task) async {
    try {
      _setLoading(true);
      _clearError();
      await _supabaseService.addTask(task);
      // Add the task to the local list immediately for UI responsiveness
      _tasks = [..._tasks, task];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      _setLoading(true);
      _clearError();
      await _supabaseService.updateTask(task);

      // Update task locally for immediate UI response
      _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      _setLoading(true);
      _clearError();
      await _supabaseService.deleteTask(taskId);

      // Remove task locally for immediate UI response
      _tasks = _tasks.where((task) => task.id != taskId).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _supabaseService.toggleTaskCompletion(taskId, isCompleted);

      // Update the task completion status locally
      _tasks = _tasks.map((task) {
        if (task.id == taskId) {
          return Task(
            id: task.id,
            title: task.title,
            description: task.description,
            category: task.category,
            dateTime: task.dateTime,
            isCompleted: isCompleted,
            userId: task.userId,
            createdAt: task.createdAt,
          );
        }
        return task;
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void updateTaskList(List<Task> tasks) {
    if (_tasks.length != tasks.length ||
        tasks.any((task) => !_tasks.any((t) => t.id == task.id))) {
      _tasks = tasks;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize tasks for a specific user
  Future<void> initializeTasksForUser(String userId) async {
    try {
      _setLoading(true);
      // Get initial tasks
      final initialTasks = await _supabaseService.getTasksByDate(
        userId,
        DateTime.now(),
      );
      updateTaskList(initialTasks);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  List<String> get categories {
    return ['Work', 'Personal', 'Health', 'Education', 'Shopping', 'Other'];
  }

  Map<String, int> get taskCountByCategory {
    Map<String, int> counts = {};
    for (String category in categories) {
      counts[category] = _tasks
          .where((task) => task.category == category)
          .length;
    }
    return counts;
  }
}
