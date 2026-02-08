import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/assignment_repository.dart';
import '../../models/assignment.dart';
import 'assignment_form_screen.dart';
import 'widgets/assignment_list_item.dart';

/// Filter for the assignment list.
enum AssignmentFilter {
  all,
  pending,
  completed,
}

/// Assignments tab: list sorted by due date, create, complete, remove, edit.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({
    super.key,
    required this.repository,
  });

  final AssignmentRepository repository;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  AssignmentFilter _filter = AssignmentFilter.all;

  List<Assignment> _filtered(List<Assignment> list) {
    switch (_filter) {
      case AssignmentFilter.all:
        return list;
      case AssignmentFilter.pending:
        return list.where((a) => !a.isCompleted).toList();
      case AssignmentFilter.completed:
        return list.where((a) => a.isCompleted).toList();
    }
  }

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AssignmentFormScreen(repository: widget.repository),
      ),
    );
  }

  void _openEdit(Assignment assignment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AssignmentFormScreen(
          repository: widget.repository,
          existing: assignment,
        ),
      ),
    );
  }

  void _toggleComplete(Assignment assignment) {
    widget.repository.update(
      assignment.copyWith(isCompleted: !assignment.isCompleted),
    );
  }

  void _remove(Assignment assignment) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Remove assignment', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remove "${assignment.title}" from the list?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              widget.repository.remove(assignment.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Assignments'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == AssignmentFilter.all,
                  onTap: () => setState(() => _filter = AssignmentFilter.all),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Pending',
                  selected: _filter == AssignmentFilter.pending,
                  onTap: () => setState(() => _filter = AssignmentFilter.pending),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Completed',
                  selected: _filter == AssignmentFilter.completed,
                  onTap: () => setState(() => _filter = AssignmentFilter.completed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _openCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create Assignment'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<List<Assignment>>(
              valueListenable: widget.repository.assignmentsListenable,
              builder: (context, list, _) {
                final filtered = _filtered(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _filter == AssignmentFilter.all
                          ? 'No assignments yet. Tap Create Assignment to add one.'
                          : 'No ${_filter.name} assignments.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final assignment = filtered[index];
                    return AssignmentListItem(
                      assignment: assignment,
                      onToggleComplete: () => _toggleComplete(assignment),
                      onDelete: () => _remove(assignment),
                      onTap: () => _openEdit(assignment),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          color: selected ? AppColors.accent : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
