import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';

class TaskListItem extends StatefulWidget {
  final Task task;
  final Future<void> Function() onToggleComplete;
  final Future<bool> Function() onDelete; // Returns true if delete was confirmed
  final Future<void> Function(String) onRename;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  bool _isRemoving = false;
  bool _isEditing = false;
  late final TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _editController = TextEditingController(text: widget.task.title);
    _editFocusNode.addListener(() {
      // If user taps outside the text field while editing, cancel edit
      if (!_editFocusNode.hasFocus && _isEditing) {
        _cancelEdit();
      }
    });

    // Play entrance animation when the item appears
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (_isRemoving) return;
    // Call onDelete which shows the confirmation dialog
    final confirmed = await widget.onDelete();
    // Only animate collapse if delete was actually confirmed
    if (confirmed && mounted) {
      setState(() => _isRemoving = true);
      await _controller.reverse();
    }
  }

  Future<void> _handleToggle() async {
    await widget.onToggleComplete();
  }

  Future<void> _saveEdit() async {
    final newTitle = _editController.text.trim();
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await widget.onRename(newTitle);
    if (mounted) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _editController.text = widget.task.title;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    final formattedDate = dateFormat.format(widget.task.createdAt);

    return SizeTransition(
      sizeFactor: _scaleAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: widget.task.completed,
                  onChanged: (_) => _handleToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        Focus(
                          focusNode: _editFocusNode,
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey ==
                                    LogicalKeyboardKey.escape) {
                              _cancelEdit();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: _editController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _saveEdit(),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEditing = true;
                              _editController.text = widget.task.title;
                            });
                          },
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: widget.task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.task.completed
                                  ? Colors.grey[600]?.withValues(alpha: 0.7)
                                  : Colors.grey[900],
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: widget.task.completed ? 0.8 : 1.0,
                              child: Text(widget.task.title),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _DeleteButton(onDelete: _handleDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final Future<void> Function() onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await widget.onDelete();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFFCA5A5)
                : (_isHovered
                    ? const Color(0xFFFEE2E2)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered || _isPressed
                  ? const Color(0xFFFCA5A5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 20,
          ),
        ),
      ),
    );
  }
}
