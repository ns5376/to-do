import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/components/app_bar.dart';
import '../ui/components/add_task_input.dart';
import '../ui/components/task_list_item.dart';
import '../ui/components/filter_segmented_control.dart';
import '../state/task_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: const AppBarWidget(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // Add Task Section
                  AddTaskInput(
                    onAdd: (title) async {
                      try {
                        await ref.read(tasksProvider.notifier).addTask(title);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task added successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Search + Filter row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                              ),
                              hintText: 'Search tasks...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                            ),
                            onChanged: (value) {
                              ref.read(searchQueryProvider.notifier).state =
                                  value;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilterSegmentedControl(
                        activeFilter: filter,
                        onFilterChanged: (newFilter) {
                          ref.read(taskFilterProvider.notifier).state =
                              newFilter;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Task List
                  Expanded(
                    child: tasksAsync.when(
                      data: (tasks) {
                        final totalCount = tasks.length;
                        final pendingCount =
                            tasks.where((t) => !t.completed).length;
                        final completedCount =
                            tasks.where((t) => t.completed).length;

                        final statusFiltered = switch (filter) {
                          TaskFilter.completed =>
                            tasks.where((t) => t.completed).toList(),
                          TaskFilter.pending =>
                            tasks.where((t) => !t.completed).toList(),
                          TaskFilter.all => tasks,
                        };

                        final query = searchQuery.trim().toLowerCase();
                        final filteredTasks = query.isEmpty
                            ? statusFiltered
                            : statusFiltered
                                .where((t) => t.title
                                    .toLowerCase()
                                    .contains(query))
                                .toList();

                        if (totalCount > 0) {
                          final progress = totalCount == 0
                              ? 0.0
                              : completedCount / totalCount;

                          return Column(
                            children: [
                              // Counts + bulk actions
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$pendingCount pending • $completedCount completed',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  if (pendingCount > 0)
                                    TextButton(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                                tasksProvider.notifier)
                                            .markAllComplete();
                                      },
                                      child: const Text('Mark all complete'),
                                    ),
                                  if (completedCount > 0)
                                    TextButton(
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                            title: const Text(
                                              'Clear completed tasks',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to remove all completed tasks?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child:
                                                    const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                style:
                                                    TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.red,
                                                ),
                                                child:
                                                    const Text('Clear'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          await ref
                                              .read(tasksProvider.notifier)
                                              .clearCompleted();
                                        }
                                      },
                                      child: const Text('Clear completed'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor:
                                        const Color(0xFFE2E8F0),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sorted: Pending → Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: filteredTasks.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              size: 56,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No tasks match your search.',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : AnimatedSwitcher(
                                        duration: const Duration(
                                            milliseconds: 250),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        child: ListView.builder(
                                          key: ValueKey(
                                            '${filter.name}-${filteredTasks.length}-${query}',
                                          ),
                                          itemCount:
                                              filteredTasks.length,
                                          itemBuilder:
                                              (context, index) {
                                            final task =
                                                filteredTasks[index];
                                            return TaskListItem(
                                              key: ValueKey(task.id),
                                              task: task,
                                              onToggleComplete:
                                                  () async {
                                                try {
                                                  await ref
                                                      .read(
                                                          tasksProvider
                                                              .notifier)
                                                      .toggleComplete(
                                                          task.id);
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger
                                                            .of(
                                                                context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Error: $e'),
                                                        backgroundColor:
                                                            Colors
                                                                .red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              onRename: (newTitle) async {
                                                try {
                                                  await ref
                                                      .read(
                                                          tasksProvider
                                                              .notifier)
                                                      .renameTask(
                                                        task.id,
                                                        newTitle,
                                                      );
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger
                                                            .of(
                                                                context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Error: $e'),
                                                        backgroundColor:
                                                            Colors
                                                                .red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              onDelete: () async {
                                                final confirmed =
                                                    await showDialog<
                                                        bool>(
                                                  context: context,
                                                  builder:
                                                      (context) =>
                                                          AlertDialog(
                                                    title: const Text(
                                                        'Delete Task'),
                                                    content: Text(
                                                      'Are you sure you want to delete \"${task.title}\"?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                false),
                                                        child:
                                                            const Text(
                                                                'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                true),
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors
                                                                  .red,
                                                        ),
                                                        child:
                                                            const Text(
                                                                'Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirmed == true) {
                                                  final deletedTask =
                                                      task;
                                                  try {
                                                    await ref
                                                        .read(
                                                            tasksProvider
                                                                .notifier)
                                                        .deleteTask(
                                                            task.id);
                                                    if (mounted) {
                                                      ScaffoldMessenger
                                                              .of(
                                                                  context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content:
                                                              const Text(
                                                            'Task deleted',
                                                          ),
                                                          action:
                                                              SnackBarAction(
                                                            label:
                                                                'Undo',
                                                            onPressed:
                                                                () {
                                                              ref
                                                                  .read(tasksProvider.notifier)
                                                                  .restoreTask(deletedTask);
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      ScaffoldMessenger
                                                              .of(
                                                                  context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Error: $e'),
                                                          backgroundColor:
                                                              Colors
                                                                  .red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                                
                                                // Return whether delete was confirmed
                                                return confirmed == true;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          );
                        }

                        if (filteredTasks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  filter == TaskFilter.all
                                      ? 'No tasks yet. Add one above!'
                                      : 'No tasks match this filter.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: ListView.builder(
                            key: ValueKey(
                              '${filter.name}-${filteredTasks.length}-${query}',
                            ),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                                            return TaskListItem(
                                              key: ValueKey(task.id),
                                              task: task,
                                              onToggleComplete: () async {
                                                try {
                                                  await ref
                                                      .read(tasksProvider.notifier)
                                                      .toggleComplete(task.id);
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              onRename: (newTitle) async {
                                                try {
                                                  await ref
                                                      .read(
                                                          tasksProvider.notifier)
                                                      .renameTask(
                                                        task.id,
                                                        newTitle,
                                                      );
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error: $e'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              onDelete: () async {
                                  final confirmed =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: Text(
                                        'Are you sure you want to delete \"${task.title}\"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    final deletedTask = task;
                                    try {
                                      await ref
                                          .read(tasksProvider.notifier)
                                          .deleteTask(task.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Task deleted',
                                            ),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () {
                                                ref
                                                    .read(
                                                        tasksProvider
                                                            .notifier)
                                                    .restoreTask(
                                                        deletedTask);
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  
                                  // Return whether delete was confirmed
                                  return confirmed == true;
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(tasksProvider.notifier).loadTasks();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
