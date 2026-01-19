import '../models/task.dart';
import 'mock_task_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskRepository {
  final MockTaskApi _api = MockTaskApi();
  static const String _storageKey = 'todo-tasks';

  Future<List<Task>> loadTasks() async {
    // Try to load from local storage first
    final prefs = await SharedPreferences.getInstance();
    final storedTasksJson = prefs.getString(_storageKey);
    
    if (storedTasksJson != null) {
      try {
        final List<dynamic> tasksJson = json.decode(storedTasksJson);
        return tasksJson.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e) {
        // If parsing fails, fall back to mock API
      }
    }
    
    // If no stored data, load from mock API
    return await _api.fetchTasks();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(tasksJson));
  }

  Future<List<Task>> addTask(List<Task> currentTasks, Task newTask) async {
    final updatedTasks = [newTask, ...currentTasks];
    await saveTasks(updatedTasks);
    return updatedTasks;
  }

  Future<List<Task>> updateTask(List<Task> currentTasks, Task updatedTask) async {
    final updatedTasks = currentTasks.map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList();
    await saveTasks(updatedTasks);
    return updatedTasks;
  }

  Future<List<Task>> deleteTask(List<Task> currentTasks, int taskId) async {
    final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
    await saveTasks(updatedTasks);
    return updatedTasks;
  }

  List<Task> filterTasks(List<Task> tasks, String filter) {
    switch (filter) {
      case 'completed':
        return tasks.where((task) => task.completed).toList();
      case 'pending':
        return tasks.where((task) => !task.completed).toList();
      case 'all':
      default:
        return tasks;
    }
  }
}
