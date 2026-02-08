import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/assignment_repository.dart';
import '../../models/assignment.dart';

/// Screen for creating a new assignment or editing an existing one.
class AssignmentFormScreen extends StatefulWidget {
  const AssignmentFormScreen({
    super.key,
    required this.repository,
    this.existing,
  });

  final AssignmentRepository repository;
  final Assignment? existing;

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late DateTime _dueDate;
  AssignmentPriority? _priority;
  String? _titleError;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _courseController = TextEditingController(text: e?.courseName ?? '');
    _dueDate = e?.dueDate ?? DateTime.now();
    _priority = e?.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  bool _validate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Assignment title is required');
      return false;
    }
    setState(() => _titleError = null);
    return true;
  }

  void _save() {
    if (!_validate()) return;
    final title = _titleController.text.trim();
    final courseName = _courseController.text.trim();

    if (isEditing) {
      widget.repository.update(widget.existing!.copyWith(
        title: title,
        dueDate: _dueDate,
        courseName: courseName,
        priority: _priority,
      ));
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      widget.repository.add(Assignment(
        id: id,
        title: title,
        dueDate: _dueDate,
        courseName: courseName,
        priority: _priority,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Assignment title (required)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter assignment title',
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _titleError,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.warning),
                ),
              ),
              style: const TextStyle(color: AppColors.background),
              onChanged: (_) => setState(() => _titleError = null),
            ),
            const SizedBox(height: 20),
            Text(
              'Due date',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(_dueDate),
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Course name',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _courseController,
              decoration: InputDecoration(
                hintText: 'Enter course name',
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: AppColors.background),
            ),
            const SizedBox(height: 20),
            Text(
              'Priority level (optional)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AssignmentPriority?>(
              initialValue: _priority,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: AppColors.backgroundSecondary,
              hint: const Text('Select priority', style: TextStyle(color: AppColors.textSecondary)),
              items: [
                const DropdownMenuItem<AssignmentPriority?>(
                  value: null,
                  child: Text('None', style: TextStyle(color: AppColors.textPrimary)),
                ),
                ...AssignmentPriority.values.map(
                  (p) => DropdownMenuItem<AssignmentPriority?>(
                    value: p,
                    child: Text(p.displayLabel, style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _priority = value),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEditing ? 'Save changes' : 'Create assignment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
