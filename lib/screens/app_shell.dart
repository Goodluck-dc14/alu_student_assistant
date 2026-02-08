import 'package:flutter/material.dart';

import '../services/attendance_service.dart';

// Dashboard
import 'dashboard/dashboard_screen.dart';
import 'dashboard/dashboard_view_model.dart';

// Existing screens (nested correctly)
import 'assignments/assignments_screen.dart';
import 'schedule/schedule_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.attendanceService});

  final AttendanceService attendanceService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final DashboardViewModel _dashboardVM;

  @override
  void initState() {
    super.initState();

    _dashboardVM = DashboardViewModel(
      termStartDate: DateTime(DateTime.now().year, 1, 15),
    );

    // TEMP dummy data for assignments & sessions.
    // Attendance will come from attendanceService (we’ll wire this next).
    _dashboardVM.setData(
      assignments: [
        DashboardAssignment(
          title: 'Group Project - Flutter App',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Mobile Development',
          isCompleted: false,
        ),
      ],
      sessions: [
        DashboardSession(
          title: 'Mastery Session',
          date: DateTime.now(),
          startMinutes: 9 * 60,
          endMinutes: 10 * 60 + 30,
          type: 'Mastery Session',
          location: 'Room B2',
          isPresent: null,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dashboardVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // Your dashboard tab
      DashboardScreen(
        viewModel: _dashboardVM,
        attendanceService:
            widget.attendanceService, // we’ll add this param below
      ),

      // Other tabs (can be placeholders for now)
      const AssignmentsScreen(),
      const ScheduleScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
