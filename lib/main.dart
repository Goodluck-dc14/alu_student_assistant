import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/attendance_repository.dart';
import 'features/attendance/widgets/attendance_history_section.dart';
import 'features/attendance/widgets/attendance_metric_card.dart';
import 'features/attendance/widgets/attendance_warning_banner.dart';
import 'models/attendance_record.dart';
import 'services/attendance_service.dart';
// Ensure this file exists in lib/screens/
import 'screens/login_screen.dart'; 

void main() {
  final repository = InMemoryAttendanceRepository(
    initialRecords: _mockAttendanceRecords(),
  );
  final attendanceService = AttendanceService(repository);

  runApp(ALUStudentAssistantApp(attendanceService: attendanceService));
}

List<AttendanceRecord> _mockAttendanceRecords() {
  final now = DateTime.now();
  return [
    AttendanceRecord(
      id: '1',
      sessionTitle: 'Introduction to Linux',
      sessionDate: now.subtract(const Duration(days: 1)),
      sessionType: 'Class',
      isPresent: true,
    ),
    AttendanceRecord(
      id: '2',
      sessionTitle: 'Python Programming',
      sessionDate: now.subtract(const Duration(days: 2)),
      sessionType: 'Class',
      isPresent: true,
    ),
  ];
}

class ALUStudentAssistantApp extends StatelessWidget {
  const ALUStudentAssistantApp({
    super.key,
    required this.attendanceService,
  });

  final AttendanceService attendanceService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Student Assistant',
      theme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        // Points to your new Login Screen
        '/': (context) => const LoginScreen(),
        // Points to the team's Dashboard class below
        '/dashboard': (context) => AttendanceDemoScreen(attendanceService: attendanceService),
      },
    );
  }
}

class AttendanceDemoScreen extends StatelessWidget {
  const AttendanceDemoScreen({
    super.key,
    required this.attendanceService,
  });

  final AttendanceService attendanceService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AttendanceWarningBanner(attendanceService: attendanceService),
            const SizedBox(height: 16),
            AttendanceMetricCard(attendanceService: attendanceService),
            const SizedBox(height: 24),
            AttendanceHistorySection(attendanceService: attendanceService),
          ],
        ),
      ),
    );
  }
}