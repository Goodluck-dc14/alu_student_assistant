import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/assignment.dart';

/// A card displaying one assignment with check (complete), delete, and tap-to-edit.
class AssignmentListItem extends StatelessWidget {
  const AssignmentListItem({
    super.key,
    required this.assignment,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTap,
  });

  final Assignment assignment;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  static String _formatDueDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Due ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: assignment.isCompleted,
                onChanged: (_) => onToggleComplete(),
                activeColor: AppColors.accent,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.accent;
                  }
                  return AppColors.textSecondary.withOpacity(0.3);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            decoration: assignment.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDueDate(assignment.dueDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (assignment.courseName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        assignment.courseName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                    if (assignment.priority != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          assignment.priority!.displayLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: AppColors.warning,
                tooltip: 'Remove assignment',
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
