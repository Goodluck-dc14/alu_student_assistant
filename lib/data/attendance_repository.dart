import 'package:flutter/foundation.dart';

import '../models/attendance_record.dart';

/// Interface for attendance data storage.
abstract class AttendanceRepository {
  /// Adds a new attendance record.
  void addRecord(AttendanceRecord record);

  /// Updates an existing record by id.
  void updateRecord(AttendanceRecord record);

  /// Returns all attendance records.
  List<AttendanceRecord> getAllRecords();

  /// Removes a record by id.
  void removeRecord(String id);

  /// Listenable that emits the current list whenever it changes.
  ValueListenable<List<AttendanceRecord>> get recordsListenable;
}

/// In-memory implementation of [AttendanceRepository].
/// Data is maintained during the current session only.
class InMemoryAttendanceRepository implements AttendanceRepository {
  InMemoryAttendanceRepository({List<AttendanceRecord>? initialRecords}) {
    if (initialRecords != null) {
      _records.addAll(initialRecords);
    }
    _emit();
  }

  final List<AttendanceRecord> _records = [];
  final ValueNotifier<List<AttendanceRecord>> _notifier =
      ValueNotifier<List<AttendanceRecord>>([]);

  @override
  void addRecord(AttendanceRecord record) {
    if (_records.any((r) => r.id == record.id)) return;
    _records.add(record);
    _emit();
  }

  @override
  void updateRecord(AttendanceRecord record) {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      _records[index] = record;
      _emit();
    }
  }

  @override
  List<AttendanceRecord> getAllRecords() {
    return List.unmodifiable(_records);
  }

  @override
  void removeRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    _emit();
  }

  @override
  ValueListenable<List<AttendanceRecord>> get recordsListenable => _notifier;

  void _emit() {
    _notifier.value = List<AttendanceRecord>.from(_records);
  }
}
