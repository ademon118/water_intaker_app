import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../app_tokens.dart';

/// Bottom-open arc progress gauge matching the Figma home design.
class ArcProgressGauge extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Widget centerChild;
  final String intakeText;
  final String goalText;

  const ArcProgressGauge({
    super.key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.centerChild,
    required this.intakeText,
    required this.goalText,
  });

  static const double _startAngle = 3 * math.pi / 4;
  static const double _sweepAngle = 3 * math.pi / 2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final intakeFontSize = size * 0.11;
    final goalFontSize = size * 0.055;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ArcProgressPainter(
                  progress: progress.clamp(0.0, 1.0),
                  strokeWidth: strokeWidth,
                  trackColor: trackColor,
                  progressColor: progressColor,
                  startAngle: _startAngle,
                  sweepAngle: _sweepAngle,
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.18),
                child: centerChild,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: size * 0.04,
                child: Text(
                  intakeText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.interBold(
                    intakeFontSize,
                    color: colors.onSurface,
                  ).copyWith(height: 1.0),
                ),
              ),
            ],
          ),
        ),
        Text(
          goalText,
          textAlign: TextAlign.center,
          style: AppTextStyles.interMedium(
            goalFontSize,
            color: colors.onSurfaceVariant,
          ).copyWith(height: 1.2),
        ),
      ],
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final double startAngle;
  final double sweepAngle;

  const _ArcProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);

    if (progress > 0.01) {
      final endAngle = startAngle + sweepAngle * progress;
      final dotRadius = math.max(3.5, strokeWidth * 0.1);
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        dotRadius,
        Paint()..color = const Color(0xFF2E2E2E),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
