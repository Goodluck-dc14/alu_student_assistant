import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/attendance_record.dart';
import '../../../../services/attendance_service.dart';

/// Red banner shown when attendance falls below 75%.
/// Only visible when there is at least one attendance record.
class AttendanceWarningBanner extends StatelessWidget {
  const AttendanceWarningBanner({
    super.key,
    required this.attendanceService,
    this.message = 'AT RISK WARNING',
  });

  final AttendanceService attendanceService;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AttendanceRecord>>(
      valueListenable: attendanceService.recordsListenable,
      builder: (context, records, __) {
        if (records.isEmpty || !attendanceService.isBelowThreshold) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
