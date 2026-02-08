import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/academic_session.dart';
import '../providers/session_provider.dart';
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
  }

  @override
  void dispose() {
    _dashboardVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todaySessions = sessionProvider.sessions
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          return !d.isBefore(todayStart) && d.isBefore(todayEnd);
        })
        .map((s) => DashboardSession(
              title: s.title,
              date: s.date,
              startMinutes: s.startDateTime.hour * 60 + s.startDateTime.minute,
              endMinutes: s.endDateTime.hour * 60 + s.endDateTime.minute,
              type: AcademicSession.typeLabel(s.type),
              location: s.location,
              isPresent: s.attendance == AttendanceStatus.present
                  ? true
                  : s.attendance == AttendanceStatus.absent
                      ? false
                      : null,
            ))
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    _dashboardVM.setData(
      assignments: [],
      sessions: todaySessions,
    );

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
