import 'package:flutter/foundation.dart';
import '../core/constants/attendance_constants.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_record.dart';

/// Service for attendance calculations and threshold checks.
class AttendanceService {
  AttendanceService(this._repository);

  final AttendanceRepository _repository;

  /// Current attendance percentage (0-100). Returns 0 if no records.
  double get attendancePercentage {
    final records = _repository.getAllRecords();
    if (records.isEmpty) return 0;
    final present = records.where((r) => r.isPresent).length;
    return (present / records.length) * 100;
  }

  /// True when attendance is below the threshold (75%).
  bool get isBelowThreshold {
    final records = _repository.getAllRecords();
    return records.isNotEmpty &&
        attendancePercentage < AttendanceConstants.attendanceThreshold;
  }

  /// Attendance history sorted by date (newest first).
  List<AttendanceRecord> get history {
    final records = List<AttendanceRecord>.from(_repository.getAllRecords());
    records.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return records;
  }

  /// Attendance history excluding today (for dashboard to avoid duplicating "Today's Sessions").
  List<AttendanceRecord> get historyExcludingToday {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return history
        .where((r) => r.sessionDate.isBefore(todayStart))
        .toList();
  }

  /// The repository's listenable for reactive UI updates.
  ValueListenable<List<AttendanceRecord>> get recordsListenable =>
      _repository.recordsListenable;

  /// Backward-compatible helper used by UI screens/widgets.
  /// Returns a non-null percentage (0-100).
  double calculateAttendancePercentage() => attendancePercentage;
}
