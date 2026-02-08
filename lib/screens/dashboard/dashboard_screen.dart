import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/attendance/widgets/attendance_history_section.dart';
import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import 'dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardViewModel viewModel;
  final AttendanceService attendanceService;

  const DashboardScreen({
    super.key,
    required this.viewModel,
    required this.attendanceService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071A2D), Color(0xFF0B2B4B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _TopRow(date: viewModel.today, week: viewModel.academicWeek),
              const SizedBox(height: 12),

              ValueListenableBuilder<List<AttendanceRecord>>(
                valueListenable: attendanceService.recordsListenable,
                builder: (context, records, __) {
                  final bool hasRecords = records.isNotEmpty;
                  final double attendance =
                      attendanceService.calculateAttendancePercentage();
                  final String attendanceText = hasRecords
                      ? '${attendance.toStringAsFixed(0)}%'
                      : 'N/A';
                  final bool showWarning =
                      hasRecords && attendance < 75;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showWarning)
                        const _WarningBanner(
                            text: 'ATTENDANCE WARNING: Below 75%'),
                      const SizedBox(height: 12),
                      _MetricTilesRow(
                        pendingCount: viewModel.pendingAssignmentsCount,
                        attendanceText: attendanceText,
                        showAttendanceWarning: showWarning,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: "Today's Academic Sessions",
                emptyText: "No sessions scheduled for today.",
                isEmpty: viewModel.todaysSessions.isEmpty,
                child: Column(
                  children: [
                    for (
                      int i = 0;
                      i < viewModel.todaysSessions.length;
                      i++
                    ) ...[
                      _SessionTile(session: viewModel.todaysSessions[i]),
                      if (i != viewModel.todaysSessions.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: "Assignments Due (Next 7 Days)",
                emptyText: "No assignments due soon.",
                isEmpty: viewModel.dueInNext7Days.isEmpty,
                child: Column(
                  children: [
                    for (
                      int i = 0;
                      i < viewModel.dueInNext7Days.length;
                      i++
                    ) ...[
                      _AssignmentTile(assignment: viewModel.dueInNext7Days[i]),
                      if (i != viewModel.dueInNext7Days.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _AttendanceHistoryCard(attendanceService: attendanceService),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  final DateTime date;
  final int week;

  const _TopRow({required this.date, required this.week});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            DateFormat('EEEE, d MMM yyyy').format(date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Week $week',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;
  const _WarningBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD84343),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTilesRow extends StatelessWidget {
  final int pendingCount;
  final String attendanceText;
  final bool showAttendanceWarning;

  const _MetricTilesRow({
    required this.pendingCount,
    required this.attendanceText,
    required this.showAttendanceWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Pending\nAssignments',
            value: '$pendingCount',
            icon: Icons.checklist_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: 'Attendance',
            value: attendanceText,
            icon: showAttendanceWarning
                ? Icons.warning_amber_rounded
                : Icons.percent,
            valueColor: showAttendanceWarning ? const Color(0xFFD84343) : null,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final Widget child;
  final bool isEmpty;

  const _SectionCard({
    required this.title,
    required this.emptyText,
    required this.child,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  emptyText,
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final DashboardSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final time = '${_fmt(session.startMinutes)} - ${_fmt(session.endMinutes)}';
    final subtitle = [
      session.type,
      time,
      if (session.location != null && session.location!.trim().isNotEmpty)
        session.location!,
    ].join(' • ');

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        session.title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      trailing: _AttendancePill(isPresent: session.isPresent),
    );
  }

  String _fmt(int m) {
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }
}

class _AssignmentTile extends StatelessWidget {
  final DashboardAssignment assignment;
  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final due = DateFormat('d MMM').format(assignment.dueDate);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        assignment.title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        '${assignment.courseName} • Due $due',
        style: const TextStyle(color: Colors.black54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black45),
    );
  }
}

class _AttendancePill extends StatelessWidget {
  final bool? isPresent;

  const _AttendancePill({required this.isPresent});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    if (isPresent == true) {
      label = 'Present';
      bg = const Color(0xFFE7F6EA);
      fg = const Color(0xFF1B7A2E);
    } else if (isPresent == false) {
      label = 'Absent';
      bg = const Color(0xFFFCE8E8);
      fg = const Color(0xFFB71C1C);
    } else {
      label = '—';
      bg = const Color(0xFFF2F2F2);
      fg = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  final AttendanceService attendanceService;

  const _AttendanceHistoryCard({required this.attendanceService});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance History',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            AttendanceHistorySection(
              attendanceService: attendanceService,
              title: '',
              excludeToday: true,
            ),
          ],
        ),
      ),
    );
  }
}
