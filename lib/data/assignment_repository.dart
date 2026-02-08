import 'package:flutter/foundation.dart';

import '../models/assignment.dart';

/// Interface for assignment data storage.
abstract class AssignmentRepository {
  /// Adds a new assignment.
  void add(Assignment assignment);

  /// Updates an existing assignment by id.
  void update(Assignment assignment);

  /// Removes an assignment by id.
  void remove(String id);

  /// Returns all assignments sorted by due date (earliest first).
  List<Assignment> getAll();

  /// Listenable that emits the current list whenever it changes.
  ValueListenable<List<Assignment>> get assignmentsListenable;
}

/// In-memory implementation of [AssignmentRepository].
/// Data is maintained during the current session only.
class InMemoryAssignmentRepository implements AssignmentRepository {
  InMemoryAssignmentRepository({List<Assignment>? initialAssignments}) {
    if (initialAssignments != null) {
      _assignments.addAll(initialAssignments);
    }
    _emit();
  }

  final List<Assignment> _assignments = [];
  final ValueNotifier<List<Assignment>> _notifier =
      ValueNotifier<List<Assignment>>([]);

  List<Assignment> _sorted(List<Assignment> list) {
    final copy = List<Assignment>.from(list);
    copy.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return copy;
  }

  @override
  void add(Assignment assignment) {
    if (_assignments.any((a) => a.id == assignment.id)) return;
    _assignments.add(assignment);
    _emit();
  }

  @override
  void update(Assignment assignment) {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index >= 0) {
      _assignments[index] = assignment;
      _emit();
    }
  }

  @override
  void remove(String id) {
    _assignments.removeWhere((a) => a.id == id);
    _emit();
  }

  @override
  List<Assignment> getAll() {
    return _sorted(List.unmodifiable(_assignments));
  }

  @override
  ValueListenable<List<Assignment>> get assignmentsListenable => _notifier;

  void _emit() {
    _notifier.value = _sorted(List.unmodifiable(_assignments));
  }
}
