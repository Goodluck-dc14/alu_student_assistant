import 'package:flutter/material.dart';

import '../services/attendance_service.dart';

import 'dashboard/dashboard_screen.dart';
import 'dashboard/dashboard_view_model.dart';
import 'assignments/assignments_screen.dart';
import 'schedule_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.attendanceService});

  final AttendanceService attendanceService;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final DashboardViewModel _dashboardVM;

  @override
  void initState() {
    super.initState();

    _dashboardVM = DashboardViewModel(
      termStartDate: DateTime(DateTime.now().year, 1, 15),
    );

    // TEMP dummy data for assignments & sessions (replace later with real data)
    _dashboardVM.setData(
      assignments: [
        DashboardAssignment(
          title: 'Assignment 1',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          courseName: 'Mobile Dev (Flutter)',
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
          isPresent: true,
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
      DashboardScreen(
        viewModel: _dashboardVM,
        attendanceService: widget.attendanceService,
      ),
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
