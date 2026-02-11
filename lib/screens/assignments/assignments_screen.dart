import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgTop = const Color(0xFF071A2D);
    final bgBottom = const Color(0xFF0B2B4B);

    return Scaffold(
      backgroundColor: bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Assignments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SummaryHeader(
                pendingCount: _pendingCount,
                total: _assignments.length,
              ),
              const SizedBox(height: 12),

              if (_assignments.isEmpty)
                _EmptyState(onAdd: () => _openAddEditSheet())
              else
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Assignments',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),

                        for (int i = 0; i < _assignments.length; i++) ...[
                          _AssignmentTile(
                            assignment: _assignments[i],
                            onToggleCompleted: (val) =>
                                _toggleCompleted(_assignments[i], val),
                            onEdit: () =>
                                _openAddEditSheet(existing: _assignments[i]),
                            onDelete: () => _deleteAssignment(_assignments[i]),
                          ),
                          if (i != _assignments.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int pendingCount;
  final int total;

  const _SummaryHeader({required this.pendingCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.checklist_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pending: $pendingCount • Total: $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 40, color: Colors.black54),
            const SizedBox(height: 10),
            const Text(
              'No assignments yet.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create one to start tracking deadlines and priorities.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final _Assignment assignment;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentTile({
    required this.assignment,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dueText = DateFormat('EEE, d MMM').format(assignment.dueDate);
    final priorityChip = _PriorityChip(priority: assignment.priority);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: assignment.isCompleted,
        onChanged: (v) => onToggleCompleted(v ?? false),
      ),
      title: Text(
        assignment.title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          decoration: assignment.isCompleted
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      subtitle: Text(
        '${assignment.courseName} • Due $dueText',
        style: const TextStyle(color: Colors.black54),
      ),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          priorityChip,
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AssignmentFormSheet extends StatefulWidget {
  final _Assignment? existing;

  const _AssignmentFormSheet({required this.existing});

  @override
  State<_AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<_AssignmentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _courseCtrl;

  DateTime? _dueDate;
  _Priority _priority = _Priority.medium;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _courseCtrl = TextEditingController(
      text: widget.existing?.courseName ?? '',
    );
    _dueDate = widget.existing?.dueDate;
    _priority = widget.existing?.priority ?? _Priority.medium;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _dueDate = picked);
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }

    final isEdit = widget.existing != null;

    final assignment = _Assignment(
      id: isEdit
          ? widget.existing!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      courseName: _courseCtrl.text.trim().isEmpty
          ? '—'
          : _courseCtrl.text.trim(),
      dueDate: _dueDate!,
      priority: _priority,
      isCompleted: widget.existing?.isCompleted ?? false,
    );

    Navigator.pop(context, assignment);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B2B4B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null
                          ? 'New Assignment'
                          : 'Edit Assignment',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Assignment title *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required.'
                      : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _courseCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Course name'),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _dueDate == null
                              ? 'Pick due date *'
                              : DateFormat('EEE, d MMM yyyy').format(_dueDate!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<_Priority>(
                        initialValue: _priority,
                        decoration: _fieldDecoration(''),
                        dropdownColor: const Color(0xFF0B2B4B),
                        items: const [
                          DropdownMenuItem(
                            value: _Priority.high,
                            child: Text('High'),
                          ),
                          DropdownMenuItem(
                            value: _Priority.medium,
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: _Priority.low,
                            child: Text('Low'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _Priority.medium),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.existing == null ? 'Create' : 'Save Changes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final _Priority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;

    switch (priority) {
      case _Priority.high:
        label = 'High';
        bg = const Color(0xFFFCE8E8);
        fg = const Color(0xFFB71C1C);
        break;
      case _Priority.medium:
        label = 'Medium';
        bg = const Color(0xFFFFF4E5);
        fg = const Color(0xFFB26A00);
        break;
      case _Priority.low:
        label = 'Low';
        bg = const Color(0xFFE7F6EA);
        fg = const Color(0xFF1B7A2E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

enum _Priority { high, medium, low }

class _Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final _Priority priority;
  final bool isCompleted;

  const _Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.priority,
    required this.isCompleted,
  });

  _Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    _Priority? priority,
    bool? isCompleted,
  }) {
    return _Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
