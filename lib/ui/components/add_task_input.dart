import 'package:flutter/material.dart';

class AddTaskInput extends StatefulWidget {
  final Function(String) onAdd;

  const AddTaskInput({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddTaskInput> createState() => _AddTaskInputState();
}

class _AddTaskInputState extends State<AddTaskInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  void _handleAdd() {
    final title = _controller.text.trim();
    
    if (title.isEmpty) {
      setState(() {
        _errorText = 'Task title cannot be empty';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    widget.onAdd(title);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasError
                        ? Colors.red
                        : (_focusNode.hasFocus
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFE2E8F0)),
                    width: hasError || _focusNode.hasFocus ? 2 : 1,
                  ),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _handleAdd(),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: ElevatedButton(
                onPressed: _handleAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
