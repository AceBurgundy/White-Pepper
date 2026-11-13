import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'workflow_icon_painters.dart';

/// Painter for the Layout / Paper Presets peapod tool icon.
class LayoutLinePainter extends CustomPainter {
  const LayoutLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;

    // Sheet expands slightly on hover
    final double expansion = animationProgress * (width * 0.04);
    final Rect sheetRect = Rect.fromLTRB(
      width * 0.22 - expansion,
      height * 0.18 - expansion,
      width * 0.78 + expansion,
      height * 0.82 + expansion,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(sheetRect, Radius.circular(width * 0.08)),
      linePaint,
    );

    // Margins / layout guide lines inside sheet
    final double leftMargin = sheetRect.left + (sheetRect.width * 0.22);
    final double rightMargin = sheetRect.right - (sheetRect.width * 0.22);

    canvas.drawLine(
      Offset(leftMargin, sheetRect.top + sheetRect.height * 0.32),
      Offset(rightMargin, sheetRect.top + sheetRect.height * 0.32),
      linePaint,
    );
    canvas.drawLine(
      Offset(leftMargin, sheetRect.top + sheetRect.height * 0.50),
      Offset(rightMargin, sheetRect.top + sheetRect.height * 0.50),
      linePaint,
    );
    canvas.drawLine(
      Offset(leftMargin, sheetRect.top + sheetRect.height * 0.68),
      Offset(sheetRect.left + sheetRect.width * 0.50, sheetRect.top + sheetRect.height * 0.68),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant LayoutLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Tune / DPI Resolution tool icon with opposing vertical slider knobs.
class TuneLinePainter extends CustomPainter {
  const TuneLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;

    final double trackTopY = height * 0.20;
    final double trackBottomY = height * 0.80;

    // Left track: knob moves upward on hover
    final double leftTrackX = width * 0.35;
    canvas.drawLine(Offset(leftTrackX, trackTopY), Offset(leftTrackX, trackBottomY), linePaint);

    final double leftKnobTravelY = -animationProgress * (height * 0.16);
    final double leftKnobY = height * 0.55 + leftKnobTravelY;
    canvas.drawCircle(Offset(leftTrackX, leftKnobY), width * 0.08, linePaint);

    // Right track: knob moves downward on hover
    final double rightTrackX = width * 0.65;
    canvas.drawLine(Offset(rightTrackX, trackTopY), Offset(rightTrackX, trackBottomY), linePaint);

    final double rightKnobTravelY = animationProgress * (height * 0.16);
    final double rightKnobY = height * 0.45 + rightKnobTravelY;
    canvas.drawCircle(Offset(rightTrackX, rightKnobY), width * 0.08, linePaint);
  }

  @override
  bool shouldRepaint(covariant TuneLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Scan Timer tool icon with clock needle sweeping through an arc.
class TimerLinePainter extends CustomPainter {
  const TimerLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;
    final double centerX = width * 0.50;
    final double centerY = height * 0.54;
    final double clockRadius = width * 0.32;

    // Stopwatch top button stem and crown
    canvas.drawLine(
      Offset(centerX, height * 0.14),
      Offset(centerX, height * 0.22),
      linePaint,
    );
    canvas.drawLine(
      Offset(centerX - width * 0.08, height * 0.14),
      Offset(centerX + width * 0.08, height * 0.14),
      linePaint,
    );

    // Stopwatch circle bezel
    canvas.drawCircle(Offset(centerX, centerY), clockRadius, linePaint);

    // Clock needle sweeps from 0° (12 o'clock) to 55° clockwise on hover
    final double sweepAngle = -math.pi / 2.0 + animationProgress * (math.pi * 0.35);
    final double needleLength = clockRadius * 0.68;
    final double tipX = centerX + needleLength * math.cos(sweepAngle);
    final double tipY = centerY + needleLength * math.sin(sweepAngle);

    canvas.drawLine(Offset(centerX, centerY), Offset(tipX, tipY), linePaint);
    canvas.drawCircle(Offset(centerX, centerY), width * 0.035, linePaint);
  }

  @override
  bool shouldRepaint(covariant TimerLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Rotate tool icon with circular arrow rotating clockwise.
class RotateLinePainter extends CustomPainter {
  const RotateLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;
    final double centerX = width * 0.50;
    final double centerY = height * 0.50;
    final double arcRadius = width * 0.30;

    // Rotation angle: 0 to 90 degrees (pi / 2)
    final double rotationAngle = animationProgress * (math.pi / 2.0);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);

    // 270-degree circular arc
    final Rect arcRect = Rect.fromCircle(center: Offset.zero, radius: arcRadius);
    canvas.drawArc(arcRect, -math.pi * 0.40, math.pi * 1.50, false, linePaint);

    // Arrowhead at the end of the arc
    final double arrowTipX = arcRadius * math.cos(-math.pi * 0.40);
    final double arrowTipY = arcRadius * math.sin(-math.pi * 0.40);

    final Path arrowhead = Path()
      ..moveTo(arrowTipX - width * 0.08, arrowTipY)
      ..lineTo(arrowTipX, arrowTipY)
      ..lineTo(arrowTipX, arrowTipY - height * 0.08);
    canvas.drawPath(arrowhead, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RotateLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Contrast & Brightness tool icon with rotating aperture and extending ray pips.
class ContrastLinePainter extends CustomPainter {
  const ContrastLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;
    final double centerX = width * 0.50;
    final double centerY = height * 0.50;
    final double discRadius = width * 0.26;

    // Disc rotation angle on hover
    final double discRotation = animationProgress * (math.pi / 6.0);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(discRotation);

    // Center circular aperture split into halves
    canvas.drawCircle(Offset.zero, discRadius, linePaint);
    canvas.drawLine(Offset(0, -discRadius), Offset(0, discRadius), linePaint);

    // Filled / shaded half
    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.35 + 0.25 * animationProgress)
      ..style = PaintingStyle.fill;

    final Path halfPath = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: discRadius), -math.pi / 2, math.pi)
      ..close();
    canvas.drawPath(halfPath, fillPaint);

    // 4 radial ray pips that extend outward
    final double raySpread = discRadius + (width * (0.07 + 0.06 * animationProgress));
    final double rayLength = width * 0.06;

    for (int rayIndex = 0; rayIndex < 4; rayIndex++) {
      final double angle = (rayIndex * math.pi / 2.0) + (math.pi / 4.0);
      final double startX = raySpread * math.cos(angle);
      final double startY = raySpread * math.sin(angle);
      final double endX = (raySpread + rayLength) * math.cos(angle);
      final double endY = (raySpread + rayLength) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ContrastLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Title / File Name tool icon with typing cursor bar translating horizontally.
class TitleLinePainter extends CustomPainter {
  const TitleLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.animationProgress,
  });

  final Color color;
  final double strokeWidth;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = createLinePaint(
      color: color,
      strokeWidth: strokeWidth,
    );

    final double width = size.width;
    final double height = size.height;

    // Letter 'T' outline
    final double horizontalBarY = height * 0.28;
    final double stemX = width * 0.42;

    // Top horizontal crossbar of T
    canvas.drawLine(
      Offset(width * 0.22, horizontalBarY),
      Offset(width * 0.62, horizontalBarY),
      linePaint,
    );

    // Vertical stem of T
    canvas.drawLine(
      Offset(stemX, horizontalBarY),
      Offset(stemX, height * 0.74),
      linePaint,
    );

    // Typing cursor bar: slides horizontally from right of T and blinks
    final double cursorStartX = width * 0.68;
    final double cursorTravelX = animationProgress * (width * 0.10);
    final double cursorX = cursorStartX + cursorTravelX;

    final Paint cursorPaint = createLinePaint(
      color: color.withValues(alpha: 0.4 + 0.6 * ((animationProgress * 3.0) % 1.0)),
      strokeWidth: strokeWidth * 1.2,
    );

    canvas.drawLine(
      Offset(cursorX, height * 0.26),
      Offset(cursorX, height * 0.76),
      cursorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TitleLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
