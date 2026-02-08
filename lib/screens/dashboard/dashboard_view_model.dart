import 'package:flutter/foundation.dart';

class DashboardAssignment {
  final String title;
  final DateTime dueDate;
  final String courseName;
  final bool isCompleted;

  DashboardAssignment({
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.isCompleted,
  });
}

class DashboardSession {
  final String title;
  final DateTime date; // date-only
  final int startMinutes; // minutes since midnight
  final int endMinutes;
  final String type; // Class, Mastery Session, Study Group, PSL Meeting
  final String? location;

  /// null = not recorded, true = present, false = absent
  final bool? isPresent;

  DashboardSession({
    required this.title,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.type,
    this.location,
    this.isPresent,
  });
}

class DashboardViewModel extends ChangeNotifier {
  final DateTime termStartDate;

  List<DashboardAssignment> _assignments = [];
  List<DashboardSession> _sessions = [];

  DashboardViewModel({required this.termStartDate});

  void setData({
    required List<DashboardAssignment> assignments,
    required List<DashboardSession> sessions,
  }) {
    _assignments = assignments;
    _sessions = sessions;
    notifyListeners();
  }

  DateTime get today => DateTime.now();

  int get academicWeek {
    final start = DateTime(
      termStartDate.year,
      termStartDate.month,
      termStartDate.day,
    );
    final now = DateTime(today.year, today.month, today.day);
    final diffDays = now.difference(start).inDays;
    return (diffDays ~/ 7) + 1;
  }

  List<DashboardSession> get todaysSessions {
    final d = DateTime(today.year, today.month, today.day);
    return _sessions.where((s) => _sameDay(s.date, d)).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  List<DashboardAssignment> get dueInNext7Days {
    final now = DateTime(today.year, today.month, today.day);
    final end = now.add(const Duration(days: 7));
    return _assignments
        .where((a) => !a.isCompleted)
        .where((a) => !a.dueDate.isBefore(now) && !a.dueDate.isAfter(end))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  int get pendingAssignmentsCount =>
      _assignments.where((a) => !a.isCompleted).length;

  double? get attendancePercent {
    final now = DateTime(today.year, today.month, today.day);
    final recorded = _sessions
        .where((s) => !s.date.isAfter(now))
        .where((s) => s.isPresent != null)
        .toList();

    if (recorded.isEmpty) return null;

    final present = recorded.where((s) => s.isPresent == true).length;
    return (present / recorded.length) * 100.0;
  }

  bool get attendanceWarning {
    final p = attendancePercent;
    return p != null && p < 75.0;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
