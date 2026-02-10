import 'package:flutter/material.dart';

import '../services/attendance_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/dashboard_view_model.dart';
import 'assignments/assignments_screen.dart';
import 'schedule/schedule_screen.dart';

class RootShell extends StatefulWidget {
  final DashboardViewModel dashboardViewModel;
  final AttendanceService attendanceService;

  const RootShell({
    super.key,
    required this.dashboardViewModel,
    required this.attendanceService,
  });

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(
        viewModel: widget.dashboardViewModel,
        attendanceService: widget.attendanceService,
      ),
      const AssignmentsScreen(),
      const ScheduleScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
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
