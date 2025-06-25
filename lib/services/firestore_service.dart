import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Get tasks for a specific user
  Stream<List<Task>> getTasks(String userId) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date_time', ascending: true)
        .map((data) {
          return data.map((item) => Task.fromJson(item)).toList();
        });
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      await _supabase.from('tasks').insert(task.toJson());
    } catch (e) {
      throw Exception('Failed to add task: ${e.toString()}');
    }
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    try {
      await _supabase.from('tasks').update(task.toJson()).eq('id', task.id!);
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _supabase
          .from('tasks')
          .update({'is_completed': isCompleted})
          .eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to toggle task completion: ${e.toString()}');
    }
  }

  // Get tasks by date
  Future<List<Task>> getTasksByDate(String userId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('date_time', startOfDay.toIso8601String())
          .lte('date_time', endOfDay.toIso8601String())
          .order('date_time', ascending: true);

      return response.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by date: ${e.toString()}');
    }
  }

  // Get tasks by category
  Future<List<Task>> getTasksByCategory(String userId, String category) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('date_time', ascending: true);

      return response.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by category: ${e.toString()}');
    }
  }
}
