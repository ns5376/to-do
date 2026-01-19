import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../data/task_repository.dart';

// Filter type for tasks
enum TaskFilter { all, completed, pending }

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter.all;
});

// Search query for task list
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier(ref.read(taskRepositoryProvider));
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  List<Task> _sorted(List<Task> tasks) {
    // Pending first, then completed.
    // Within each group, newest first by createdAt.
    final sorted = [...tasks];
    sorted.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1; // pending (false) before completed (true)
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.loadTasks();
      state = AsyncValue.data(_sorted(tasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      throw Exception('Task title cannot be empty');
    }

    final currentTasks = state.value ?? [];
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      completed: false,
      createdAt: DateTime.now(),
    );

    try {
      final updatedTasks = await _repository.addTask(currentTasks, newTask);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> renameTask(int taskId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      throw Exception('Task title cannot be empty');
    }

    final currentTasks = state.value ?? [];
    final task = currentTasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(title: newTitle.trim());

    try {
      final updatedTasks =
          await _repository.updateTask(currentTasks, updatedTask);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleComplete(int taskId) async {
    final currentTasks = state.value ?? [];
    final task = currentTasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(completed: !task.completed);

    try {
      final updatedTasks =
          await _repository.updateTask(currentTasks, updatedTask);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTask(int taskId) async {
    final currentTasks = state.value ?? [];
    try {
      final updatedTasks =
          await _repository.deleteTask(currentTasks, taskId);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> restoreTask(Task task) async {
    final currentTasks = state.value ?? [];
    final updatedTasks = [...currentTasks, task];
    try {
      await _repository.saveTasks(updatedTasks);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAllComplete() async {
    final currentTasks = state.value ?? [];
    if (currentTasks.isEmpty) return;

    final updatedTasks = currentTasks
        .map((t) => t.completed ? t : t.copyWith(completed: true))
        .toList();
    try {
      await _repository.saveTasks(updatedTasks);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearCompleted() async {
    final currentTasks = state.value ?? [];
    final updatedTasks =
        currentTasks.where((task) => !task.completed).toList();
    try {
      await _repository.saveTasks(updatedTasks);
      state = AsyncValue.data(_sorted(updatedTasks));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
