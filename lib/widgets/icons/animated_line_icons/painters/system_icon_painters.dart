import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'workflow_icon_painters.dart';

/// Painter for Arrow Back navigation icon with leftward pulse and extending shaft.
class ArrowBackLinePainter extends CustomPainter {
  const ArrowBackLinePainter({
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
    final double centerY = height * 0.50;

    // Arrowhead shifts leftward on hover
    final double leftShift = animationProgress * (width * 0.12);
    final double tipX = width * 0.32 - leftShift;

    // Horizontal shaft
    final double shaftEndX = width * 0.76;
    canvas.drawLine(Offset(tipX, centerY), Offset(shaftEndX, centerY), linePaint);

    // Chevron wings
    final double wingLength = width * 0.22;
    final Path chevronPath = Path()
      ..moveTo(tipX + wingLength, centerY - wingLength)
      ..lineTo(tipX, centerY)
      ..lineTo(tipX + wingLength, centerY + wingLength);
    canvas.drawPath(chevronPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant ArrowBackLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Day/Night Theme Toggle icon with rotating core and expanding rays.
class ThemeToggleLinePainter extends CustomPainter {
  const ThemeToggleLinePainter({
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
    final double coreRadius = width * 0.22;

    // Core rotation angle on hover
    final double coreRotation = animationProgress * (math.pi / 4.0);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(coreRotation);

    // Sun core circle
    canvas.drawCircle(Offset.zero, coreRadius, linePaint);

    // 8 Radial rays extending outward on hover
    final double innerRayRadius = coreRadius + width * (0.07 + 0.04 * animationProgress);
    final double rayLength = width * 0.08;

    for (int rayIndex = 0; rayIndex < 8; rayIndex++) {
      final double angle = rayIndex * (math.pi / 4.0);
      final double startX = innerRayRadius * math.cos(angle);
      final double startY = innerRayRadius * math.sin(angle);
      final double endX = (innerRayRadius + rayLength) * math.cos(angle);
      final double endY = (innerRayRadius + rayLength) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ThemeToggleLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Switch Scanner icon with twin curved orbital arrows rotating 180 degrees.
class SwitchScannerLinePainter extends CustomPainter {
  const SwitchScannerLinePainter({
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
    final double orbitRadius = width * 0.30;

    // Rotation angle: 0 to 180 degrees (pi)
    final double rotationAngle = animationProgress * math.pi;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);

    final Rect orbitRect = Rect.fromCircle(center: Offset.zero, radius: orbitRadius);

    // Top arc
    canvas.drawArc(orbitRect, -math.pi * 0.85, math.pi * 0.70, false, linePaint);

    // Top arrowhead
    final double topTipX = orbitRadius * math.cos(-math.pi * 0.15);
    final double topTipY = orbitRadius * math.sin(-math.pi * 0.15);
    final Path topArrow = Path()
      ..moveTo(topTipX - width * 0.08, topTipY - height * 0.06)
      ..lineTo(topTipX, topTipY)
      ..lineTo(topTipX - width * 0.08, topTipY + height * 0.06);
    canvas.drawPath(topArrow, linePaint);

    // Bottom arc
    canvas.drawArc(orbitRect, math.pi * 0.15, math.pi * 0.70, false, linePaint);

    // Bottom arrowhead
    final double bottomTipX = orbitRadius * math.cos(math.pi * 0.85);
    final double bottomTipY = orbitRadius * math.sin(math.pi * 0.85);
    final Path bottomArrow = Path()
      ..moveTo(bottomTipX + width * 0.08, bottomTipY + height * 0.06)
      ..lineTo(bottomTipX, bottomTipY)
      ..lineTo(bottomTipX + width * 0.08, bottomTipY - height * 0.06);
    canvas.drawPath(bottomArrow, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SwitchScannerLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Close / Dismiss icon with diagonal strokes drawing outward from center.
class CloseLinePainter extends CustomPainter {
  const CloseLinePainter({
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

    // Diagonal length extends smoothly with animation
    final double maxSpan = width * 0.28;
    final double currentSpan = maxSpan * (0.80 + 0.20 * animationProgress);

    // Stroke 1: top-left to bottom-right
    canvas.drawLine(
      Offset(centerX - currentSpan, centerY - currentSpan),
      Offset(centerX + currentSpan, centerY + currentSpan),
      linePaint,
    );

    // Stroke 2: top-right to bottom-left
    canvas.drawLine(
      Offset(centerX + currentSpan, centerY - currentSpan),
      Offset(centerX - currentSpan, centerY + currentSpan),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CloseLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Settings / Gear icon with cog wheel rotating 60 degrees.
class SettingsLinePainter extends CustomPainter {
  const SettingsLinePainter({
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
    final double hubRadius = width * 0.16;
    final double rimRadius = width * 0.26;
    final double toothLength = width * 0.08;

    // Rotation angle: 0 to 60 degrees (pi / 3)
    final double rotationAngle = animationProgress * (math.pi / 3.0);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);

    // Center hub circle
    canvas.drawCircle(Offset.zero, hubRadius, linePaint);

    // 6 Cog teeth
    for (int toothIndex = 0; toothIndex < 6; toothIndex++) {
      final double angle = toothIndex * (math.pi / 3.0);
      final double startX = rimRadius * math.cos(angle);
      final double startY = rimRadius * math.sin(angle);
      final double endX = (rimRadius + toothLength) * math.cos(angle);
      final double endY = (rimRadius + toothLength) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SettingsLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Instructions / Manual icon with fanning pages.
class InstructionsLinePainter extends CustomPainter {
  const InstructionsLinePainter({
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

    // Central spine
    canvas.drawLine(
      Offset(centerX, height * 0.24),
      Offset(centerX, height * 0.76),
      linePaint,
    );

    final double pageFan = (1.0 - animationProgress) * 0.08;

    // Left page
    final Path leftPage = Path()
      ..moveTo(centerX, height * 0.24)
      ..quadraticBezierTo(width * (0.34 - pageFan), height * 0.20, width * 0.20, height * (0.26 + pageFan))
      ..lineTo(width * 0.20, height * (0.74 + pageFan))
      ..quadraticBezierTo(width * (0.34 - pageFan), height * 0.70, centerX, height * 0.76);
    canvas.drawPath(leftPage, linePaint);

    // Right page
    final Path rightPage = Path()
      ..moveTo(centerX, height * 0.24)
      ..quadraticBezierTo(width * (0.66 + pageFan), height * 0.20, width * 0.80, height * (0.26 + pageFan))
      ..lineTo(width * 0.80, height * (0.74 + pageFan))
      ..quadraticBezierTo(width * (0.66 + pageFan), height * 0.70, centerX, height * 0.76);
    canvas.drawPath(rightPage, linePaint);
  }

  @override
  bool shouldRepaint(covariant InstructionsLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Chevron Right icon with rightward pulsing arrow tip.
class ChevronRightLinePainter extends CustomPainter {
  const ChevronRightLinePainter({
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
    final double centerY = height * 0.50;

    // Shifts rightward on hover
    final double rightShift = animationProgress * (width * 0.12);
    final double tipX = width * 0.56 + rightShift;
    final double wingSpan = width * 0.18;

    final Path chevronPath = Path()
      ..moveTo(tipX - wingSpan, centerY - wingSpan)
      ..lineTo(tipX, centerY)
      ..lineTo(tipX - wingSpan, centerY + wingSpan);
    canvas.drawPath(chevronPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant ChevronRightLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Printer device status and view icon with emerging animated paper sheet.
class PrinterLinePainter extends CustomPainter {
  const PrinterLinePainter({
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

    // Paper sheet emerging upward from the chassis slot on hover
    final double paperLeft = width * 0.30;
    final double paperRight = width * 0.70;
    final double paperTop = height * (0.22 - 0.10 * animationProgress);
    final double slotTop = height * 0.44;

    final Path paperPath = Path()
      ..moveTo(paperLeft, slotTop)
      ..lineTo(paperLeft, paperTop)
      ..lineTo(paperRight, paperTop)
      ..lineTo(paperRight, slotTop);
    canvas.drawPath(paperPath, linePaint);

    // Document print text lines on paper sheet
    final double firstTextY = paperTop + height * 0.08;
    if (firstTextY < slotTop) {
      canvas.drawLine(
        Offset(paperLeft + width * 0.08, firstTextY),
        Offset(paperRight - width * 0.08, firstTextY),
        linePaint,
      );
    }

    // Printer chassis body
    final double bodyLeft = width * 0.16;
    final double bodyRight = width * 0.84;
    final double bodyTop = height * 0.44;
    final double bodyBottom = height * 0.76;
    final double cornerRadius = width * 0.08;

    final RRect chassisRectangle = RRect.fromRectAndRadius(
      Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, bodyBottom),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(chassisRectangle, linePaint);

    // Output tray slot line
    final double traySlotY = height * 0.62;
    canvas.drawLine(
      Offset(width * 0.26, traySlotY),
      Offset(width * 0.74, traySlotY),
      linePaint,
    );

    // Status LED dot on front panel
    final double statusLedCenterX = width * 0.74;
    final double statusLedCenterY = height * 0.52;
    final Paint ledPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(statusLedCenterX, statusLedCenterY),
      width * 0.04,
      ledPaint,
    );

    // Paper output bottom tray support
    canvas.drawLine(
      Offset(width * 0.28, bodyBottom),
      Offset(width * 0.28, height * 0.84),
      linePaint,
    );
    canvas.drawLine(
      Offset(width * 0.28, height * 0.84),
      Offset(width * 0.72, height * 0.84),
      linePaint,
    );
    canvas.drawLine(
      Offset(width * 0.72, height * 0.84),
      Offset(width * 0.72, bodyBottom),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PrinterLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Start Scan workflow action icon with rightward pulsing play arrow and optical scan beam.
class StartScanLinePainter extends CustomPainter {
  const StartScanLinePainter({
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
    final double centerY = height * 0.50;

    // Forward shift on hover
    final double forwardShift = animationProgress * (width * 0.08);

    // Play triangle vertices
    final double spineCoordinateX = width * 0.32 + forwardShift;
    final double tipCoordinateX = width * 0.68 + forwardShift;
    final double topCoordinateY = height * 0.26;
    final double bottomCoordinateY = height * 0.74;

    final Path playPath = Path()
      ..moveTo(spineCoordinateX, topCoordinateY)
      ..lineTo(tipCoordinateX, centerY)
      ..lineTo(spineCoordinateX, bottomCoordinateY)
      ..close();
    canvas.drawPath(playPath, linePaint);

    // Optical scanner sweep line moving across the play glyph on hover
    final double sweepCoordinateX = width * 0.20 + (width * 0.64) * animationProgress;
    final Paint beamPaint = Paint()
      ..color = color.withValues(alpha: (0.20 + 0.60 * animationProgress).clamp(0.0, 1.0))
      ..strokeWidth = strokeWidth * 0.85
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(sweepCoordinateX, height * 0.18),
      Offset(sweepCoordinateX, height * 0.82),
      beamPaint,
    );

    // Radiating radar/pulse arc in front of play tip
    if (animationProgress > 0.05) {
      final Paint pulsePaint = Paint()
        ..color = color.withValues(alpha: (1.0 - animationProgress).clamp(0.0, 1.0))
        ..strokeWidth = strokeWidth * 0.80
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final Rect pulseRectangle = Rect.fromCircle(
        center: Offset(tipCoordinateX - width * 0.04, centerY),
        radius: width * (0.10 + 0.16 * animationProgress),
      );
      canvas.drawArc(pulseRectangle, -math.pi * 0.36, math.pi * 0.72, false, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant StartScanLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
