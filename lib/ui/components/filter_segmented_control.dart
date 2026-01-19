import 'package:flutter/material.dart';
import '../../state/task_provider.dart';

class FilterSegmentedControl extends StatelessWidget {
  final TaskFilter activeFilter;
  final Function(TaskFilter) onFilterChanged;

  const FilterSegmentedControl({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context,
            label: 'All',
            filter: TaskFilter.all,
            isFirst: true,
            isLast: false,
          ),
          _buildSegment(
            context,
            label: 'Completed',
            filter: TaskFilter.completed,
            isFirst: false,
            isLast: false,
          ),
          _buildSegment(
            context,
            label: 'Pending',
            filter: TaskFilter.pending,
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
    required bool isFirst,
    required bool isLast,
  }) {
    final isActive = activeFilter == filter;
    
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFDBEAFE)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 8 : 0),
            bottomLeft: Radius.circular(isFirst ? 8 : 0),
            topRight: Radius.circular(isLast ? 8 : 0),
            bottomRight: Radius.circular(isLast ? 8 : 0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
