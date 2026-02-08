import 'package:flutter/foundation.dart';
import '../models/academic_session.dart';

class SessionProvider extends ChangeNotifier {
  final List<AcademicSession> _sessions = [];

  List<AcademicSession> get sessions {
    final copy = [..._sessions];
    copy.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return copy;
  }

  void addSession(AcademicSession session) {
    _sessions.add(session);
    notifyListeners();
  }

  void updateSession(String id, AcademicSession updated) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _sessions[index] = updated;
    notifyListeners();
  }

  void removeSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setAttendance(String id, AttendanceStatus status) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(attendance: status);
    notifyListeners();
  }

  List<AcademicSession> weeklySessions(DateTime anchorDate) {
    final weekStart = _startOfWeek(anchorDate);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final list = _sessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return !d.isBefore(weekStart) && d.isBefore(weekEnd);
    }).toList();

    list.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return list;
  }

  DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: diff));
  }
}

