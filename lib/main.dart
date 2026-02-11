import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/attendance_repository.dart';
import 'providers/session_provider.dart';
import 'services/attendance_service.dart';
import 'screens/login_screen.dart';
import 'screens/root_shell.dart';

void main() {
  final repository = InMemoryAttendanceRepository(initialRecords: []);
  final attendanceService = AttendanceService(repository);

  runApp(ALUStudentAssistantApp(
    attendanceService: attendanceService,
    attendanceRepository: repository,
  ));
}

class ALUStudentAssistantApp extends StatelessWidget {
  const ALUStudentAssistantApp({
    super.key,
    required this.attendanceService,
    required this.attendanceRepository,
  });

  final AttendanceService attendanceService;
  final AttendanceRepository attendanceRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(attendanceRepository: attendanceRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALU Student Assistant',
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/dashboard': (context) =>
              RootShell(attendanceService: attendanceService),
        },
      ),
    );
  }
}

class AttendanceDemoScreen extends StatelessWidget {
  const AttendanceDemoScreen({super.key, required this.attendanceService});

  final AttendanceService attendanceService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
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

