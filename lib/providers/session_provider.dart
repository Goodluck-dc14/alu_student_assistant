import 'package:flutter/foundation.dart';

import '../data/attendance_repository.dart';
import '../models/academic_session.dart';
import '../models/attendance_record.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({AttendanceRepository? attendanceRepository})
      : _attendanceRepository = attendanceRepository;

  final List<AcademicSession> _sessions = [];
  final AttendanceRepository? _attendanceRepository;

  List<AcademicSession> get sessions {
    final copy = [..._sessions];
    copy.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return copy;
  }

  void addSession(AcademicSession session) {
    _sessions.add(session);
    _syncSessionToAttendance(session);
    notifyListeners();
  }

  void updateSession(String id, AcademicSession updated) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _sessions[index] = updated;
    _syncSessionToAttendance(updated);
    notifyListeners();
  }

  void removeSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    _attendanceRepository?.removeRecord(id);
    notifyListeners();
  }

  void setAttendance(String id, AttendanceStatus status) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(attendance: status);
    final session = _sessions[index];
    if (status == AttendanceStatus.unset) {
      _attendanceRepository?.removeRecord(id);
    } else {
      _upsertAttendanceRecord(
          session, isPresent: status == AttendanceStatus.present);
    }
    notifyListeners();
  }

  void _syncSessionToAttendance(AcademicSession session) {
    // Unset or absent = count as missed (isPresent: false). Present = isPresent: true.
    final isPresent = session.attendance == AttendanceStatus.present;
    _upsertAttendanceRecord(session, isPresent: isPresent);
  }

  void _upsertAttendanceRecord(AcademicSession session, {required bool isPresent}) {
    final repo = _attendanceRepository;
    if (repo == null) return;
    final record = AttendanceRecord(
      id: session.id,
      sessionTitle: session.title,
      sessionDate: session.date,
      sessionType: AcademicSession.typeLabel(session.type),
      isPresent: isPresent,
    );
    final exists = repo.getAllRecords().any((r) => r.id == session.id);
    if (exists) {
      repo.updateRecord(record);
    } else {
      repo.addRecord(record);
    }
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

