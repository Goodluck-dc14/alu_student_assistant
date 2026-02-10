import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/attendance_repository.dart';
import 'models/attendance_record.dart';
import 'services/attendance_service.dart';

import 'screens/login_screen.dart';
import 'screens/root_shell.dart';
import 'screens/dashboard/dashboard_view_model.dart';

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
  const ALUStudentAssistantApp({super.key, required this.attendanceService});

  final AttendanceService attendanceService;

  @override
  Widget build(BuildContext context) {
    // Create the dashboard VM once so RootShell can reuse it
    final dashboardVM = DashboardViewModel(
      termStartDate: DateTime(DateTime.now().year, 1, 15),
    );

    return MaterialApp(
      title: 'ALU Student Assistant',
      theme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),

        // Main app shell (bottom nav with 3 tabs)
        '/app': (context) => RootShell(
          dashboardViewModel: dashboardVM,
          attendanceService: attendanceService,
        ),
      },
    );
  }
}
