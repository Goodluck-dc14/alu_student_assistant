/// Represents a single attendance record for an academic session.
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.sessionTitle,
    required this.sessionDate,
    required this.sessionType,
    required this.isPresent,
  });

  final String id;
  final String sessionTitle;
  final DateTime sessionDate;
  final String sessionType;
  final bool isPresent;

  AttendanceRecord copyWith({
    String? id,
    String? sessionTitle,
    DateTime? sessionDate,
    String? sessionType,
    bool? isPresent,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionType: sessionType ?? this.sessionType,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionTitle': sessionTitle,
      'sessionDate': sessionDate.toIso8601String(),
      'sessionType': sessionType,
      'isPresent': isPresent,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      sessionTitle: json['sessionTitle'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      sessionType: json['sessionType'] as String,
      isPresent: json['isPresent'] as bool,
    );
  }
}
