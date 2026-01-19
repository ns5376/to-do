import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/task.dart';

class MockTaskApi {
  // Simulate network delay
  static const Duration _delay = Duration(milliseconds: 500);

  Future<List<Task>> fetchTasks() async {
    await Future.delayed(_delay);
    
    try {
      final String jsonString = await rootBundle.loadString('assets/mock_tasks.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> tasksJson = jsonData['tasks'] as List<dynamic>;
      
      return tasksJson.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // If asset loading fails, return empty list
      return [];
    }
  }
}
