// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../theme/color_theme.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.of(context).palette;

    return GestureDetector(
      onTap: onTap,
      child: GlassBlurContainer(
        type: GlassType.normal,
        borderRadius: BorderRadius.circular(24),
        addShadow: true,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusIcon(isCompleted: task.isCompleted, palette: palette),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? Colors.grey.withOpacity(0.6)
                                : const Color(0xFF374151),
                          ),
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _DateTimeRow(
                            dueDate: task.dueDate,
                            reminderTime: task.reminderTime,
                            palette: palette),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Línea gradiente inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                  gradient: palette.buttonGradient,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isCompleted;
  final AppColorPalette palette;
  const _StatusIcon({required this.isCompleted, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isCompleted
              ? const LinearGradient(
                  colors: [AppTheme.emerald400, AppTheme.teal400])
              : null,
          color: isCompleted ? null : Colors.white.withOpacity(0.25),
          border: isCompleted
              ? null
              : Border.all(color: palette.light.withOpacity(0.5), width: 2),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                      color: AppTheme.emerald400.withOpacity(0.4),
                      blurRadius: 8)
                ]
              : null,
        ),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? Colors.white : palette.light,
          size: 18,
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final String dueDate;
  final String? reminderTime;
  final AppColorPalette palette;
  const _DateTimeRow(
      {required this.dueDate, this.reminderTime, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today, size: 14, color: palette.light),
          const SizedBox(width: 4),
          Text(dueDate,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ]),
        if (reminderTime != null)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.access_time, size: 14, color: palette.secondary),
            const SizedBox(width: 4),
            Text(reminderTime!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ]),
      ],
    );
  }
}
