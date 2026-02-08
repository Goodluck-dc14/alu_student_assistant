/// Priority level for an assignment (optional field).
enum AssignmentPriority {
  high,
  medium,
  low;

  String get displayLabel {
    switch (this) {
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.low:
        return 'Low';
    }
  }

  static AssignmentPriority? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'high':
        return AssignmentPriority.high;
      case 'medium':
        return AssignmentPriority.medium;
      case 'low':
        return AssignmentPriority.low;
      default:
        return null;
    }
  }
}

/// Represents a single assignment for the Assignment Management System.
class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final AssignmentPriority? priority;
  final bool isCompleted;

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    AssignmentPriority? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority?.name,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      courseName: json['courseName'] as String,
      priority: AssignmentPriority.fromString(json['priority'] as String?),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
