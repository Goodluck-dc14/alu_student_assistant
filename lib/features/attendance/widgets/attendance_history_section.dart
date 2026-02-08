import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/attendance_record.dart';
import '../../../../services/attendance_service.dart';

/// Displays a list of attendance history (session title, date, Present/Absent).
class AttendanceHistorySection extends StatelessWidget {
  const AttendanceHistorySection({
    super.key,
    required this.attendanceService,
    this.title = 'Attendance History',
    this.maxItems,
    this.excludeToday = false,
  });

  final AttendanceService attendanceService;
  final String title;
  final int? maxItems;

  /// When true, only past sessions are shown (avoids duplicating "Today's Sessions" on dashboard).
  final bool excludeToday;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AttendanceRecord>>(
      valueListenable: attendanceService.recordsListenable,
      builder: (context, records, __) {
        final history = excludeToday
            ? attendanceService.historyExcludingToday
            : attendanceService.history;
        final displayList =
            maxItems != null ? history.take(maxItems!).toList() : history;

        if (displayList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = displayList[index];
                return _AttendanceHistoryTile(record: record);
              },
            ),
          ],
        );
      },
    );
  }
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month - 1];
}

class _AttendanceHistoryTile extends StatelessWidget {
  const _AttendanceHistoryTile({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final d = record.sessionDate;
    final dateStr = '${_monthName(d.month)} ${d.day}, ${d.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.sessionTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.sessionType} - $dateStr',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: record.isPresent
                  ? Colors.green.withOpacity(0.2)
                  : AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.isPresent ? 'Present' : 'Absent',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: record.isPresent ? Colors.green.shade800 : AppColors.warningDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
