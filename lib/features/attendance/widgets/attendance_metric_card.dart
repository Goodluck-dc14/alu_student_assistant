import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/attendance_record.dart';
import '../../../../services/attendance_service.dart';

/// Displays the current attendance percentage in a card.
/// Uses red background when below threshold, neutral when above.
class AttendanceMetricCard extends StatelessWidget {
  const AttendanceMetricCard({
    super.key,
    required this.attendanceService,
    this.label = 'Attendance',
  });

  final AttendanceService attendanceService;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AttendanceRecord>>(
      valueListenable: attendanceService.recordsListenable,
      builder: (context, records, __) {
        final bool hasRecords = records.isNotEmpty;
        final String valueText = hasRecords
            ? '${attendanceService.attendancePercentage.toStringAsFixed(0)}%'
            : 'N/A';
        final bool isAtRisk =
            hasRecords && attendanceService.isBelowThreshold;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isAtRisk ? AppColors.warning.withOpacity(0.2) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: isAtRisk ? Border.all(color: AppColors.warning, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isAtRisk ? AppColors.warning : AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isAtRisk ? AppColors.warningDark : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
