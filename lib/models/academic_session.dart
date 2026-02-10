enum SessionType { classType, masterySession, studyGroup, pslMeeting }
enum AttendanceStatus { unset, present, absent }

class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? location;
  final SessionType type;
  final AttendanceStatus attendance;

  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startDateTime,
    required this.endDateTime,
    this.location,
    required this.type,
    this.attendance = AttendanceStatus.unset,
  });

  AcademicSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    SessionType? type,
    AttendanceStatus? attendance,
  }) {
    return AcademicSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      type: type ?? this.type,
      attendance: attendance ?? this.attendance,
    );
  }

  static String typeLabel(SessionType type) {
    switch (type) {
      case SessionType.classType:
        return 'Class';
      case SessionType.masterySession:
        return 'Mastery Session';
      case SessionType.studyGroup:
        return 'Study Group';
      case SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }
}

