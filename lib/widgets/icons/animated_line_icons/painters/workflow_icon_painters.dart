import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Base painter helper that provides a configured stroke Paint.
Paint createLinePaint({
  required Color color,
  required double strokeWidth,
}) {
  return Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

/// Painter for the Custom Region / Crop icon with opposing corner brackets
/// gliding smoothly inward from outside coordinates and crossing into the authentic crop tool icon.
class CropLinePainter extends CustomPainter {
  const CropLinePainter({
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

    // Resting boundary coordinates for the central crop box
    final double leftCoordinate = width * 0.28;
    final double topCoordinate = height * 0.28;
    final double rightCoordinate = width * 0.72;
    final double bottomCoordinate = height * 0.72;

    // Stem extension past intersecting corners
    final double extensionLength = width * 0.16;

    // Kinematic offset: 0.0 at rest (default merged crop icon), pulls far apart on hover, and slams back to 0.0
    final double separationPulse = math.sin(animationProgress * math.pi);
    final double maxSeparation = width * 0.18;
    final double offsetMagnitude = separationPulse * maxSeparation;

    // 1. Top-Left Bracket:
    // Starts outward at (left - offset, top - offset).
    // Horizontal arm: goes from left - offset to (right + extensionLength - offset).
    // Vertical arm: goes from (top - extensionLength - offset) down to bottom - offset.
    final double topLeftX = leftCoordinate - offsetMagnitude;
    final double topLeftY = topCoordinate - offsetMagnitude;

    // Top horizontal arm extending past right coordinate
    canvas.drawLine(
      Offset(topLeftX, topLeftY),
      Offset(rightCoordinate + extensionLength - offsetMagnitude, topLeftY),
      linePaint,
    );

    // Left vertical arm extending above top coordinate
    canvas.drawLine(
      Offset(topLeftX, topCoordinate - extensionLength - offsetMagnitude),
      Offset(topLeftX, bottomCoordinate - offsetMagnitude),
      linePaint,
    );

    // 2. Bottom-Right Bracket:
    // Starts outward at (right + offset, bottom + offset).
    // Horizontal arm: goes from (left - extensionLength + offset) to right + offset.
    // Vertical arm: goes from top + offset down to (bottom + extensionLength + offset).
    final double bottomRightX = rightCoordinate + offsetMagnitude;
    final double bottomRightY = bottomCoordinate + offsetMagnitude;

    // Bottom horizontal arm extending past left coordinate
    canvas.drawLine(
      Offset(leftCoordinate - extensionLength + offsetMagnitude, bottomRightY),
      Offset(bottomRightX, bottomRightY),
      linePaint,
    );

    // Right vertical arm extending below bottom coordinate
    canvas.drawLine(
      Offset(bottomRightX, topCoordinate + offsetMagnitude),
      Offset(bottomRightX, bottomCoordinate + extensionLength + offsetMagnitude),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CropLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for the Flatbed Scanner icon with a sweeping optical beam.
class FlatbedLinePainter extends CustomPainter {
  const FlatbedLinePainter({
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

    // Scanner bed platen glass rectangle
    final Rect platenRect = Rect.fromLTRB(
      width * 0.14,
      height * 0.28,
      width * 0.86,
      height * 0.72,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(platenRect, Radius.circular(width * 0.08)),
      linePaint,
    );

    // Scanner lid top handle line
    final Path handlePath = Path()
      ..moveTo(width * 0.35, height * 0.20)
      ..lineTo(width * 0.65, height * 0.20);
    canvas.drawPath(handlePath, linePaint);

    // Sweeping optical scanner beam carriage line
    final double sweepStartX = width * 0.22;
    final double sweepEndX = width * 0.78;
    final double beamX = sweepStartX + (sweepEndX - sweepStartX) * animationProgress;

    final Paint beamPaint = createLinePaint(
      color: color.withValues(alpha: 0.4 + 0.6 * animationProgress),
      strokeWidth: strokeWidth * 1.2,
    );

    canvas.drawLine(
      Offset(beamX, height * 0.34),
      Offset(beamX, height * 0.66),
      beamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FlatbedLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for the Photo Scan icon with descending sun and drawing mountain peak.
class PhotoScanLinePainter extends CustomPainter {
  const PhotoScanLinePainter({
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

    // Photo outer frame
    final Rect frameRect = Rect.fromLTRB(
      width * 0.16,
      height * 0.18,
      width * 0.84,
      height * 0.82,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, Radius.circular(width * 0.08)),
      linePaint,
    );

    // Sun disc dot (descends gently into position on hover)
    final double sunY = height * 0.32 + (1.0 - animationProgress) * (-height * 0.08);
    canvas.drawCircle(
      Offset(width * 0.36, sunY),
      width * 0.06,
      linePaint,
    );

    // Mountain peak line path (draws progressively)
    final Path mountainPath = Path()
      ..moveTo(width * 0.24, height * 0.72)
      ..lineTo(width * 0.44, height * 0.50)
      ..lineTo(width * 0.60, height * 0.64)
      ..lineTo(width * 0.76, height * 0.48);

    canvas.drawPath(mountainPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant PhotoScanLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Booklet Batch icon with fanning left and right page wings.
class BookletBatchLinePainter extends CustomPainter {
  const BookletBatchLinePainter({
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
    final double centerX = width * 0.5;

    // Central spine axis line
    canvas.drawLine(
      Offset(centerX, height * 0.22),
      Offset(centerX, height * 0.78),
      linePaint,
    );

    // Fanning angle calculation (pages fan open smoothly)
    final double fanSpread = (1.0 - animationProgress) * 0.12;

    // Left page wing
    final Path leftPagePath = Path()
      ..moveTo(centerX, height * 0.22)
      ..quadraticBezierTo(
        width * (0.32 - fanSpread),
        height * 0.18,
        width * 0.16,
        height * (0.24 + fanSpread),
      )
      ..lineTo(width * 0.16, height * (0.74 + fanSpread))
      ..quadraticBezierTo(
        width * (0.32 - fanSpread),
        height * 0.70,
        centerX,
        height * 0.78,
      );
    canvas.drawPath(leftPagePath, linePaint);

    // Right page wing
    final Path rightPagePath = Path()
      ..moveTo(centerX, height * 0.22)
      ..quadraticBezierTo(
        width * (0.68 + fanSpread),
        height * 0.18,
        width * 0.84,
        height * (0.24 + fanSpread),
      )
      ..lineTo(width * 0.84, height * (0.74 + fanSpread))
      ..quadraticBezierTo(
        width * (0.68 + fanSpread),
        height * 0.70,
        centerX,
        height * 0.78,
      );
    canvas.drawPath(rightPagePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant BookletBatchLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Card Duplex icon with rear card sliding outward at an angle.
class CardDuplexLinePainter extends CustomPainter {
  const CardDuplexLinePainter({
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

    // Rear card offset: glides outward along +X and -Y
    final double rearOffsetX = animationProgress * (width * 0.14);
    final double rearOffsetY = -animationProgress * (height * 0.10);

    // Rear card outline
    final Rect rearCardRect = Rect.fromLTWH(
      width * 0.24 + rearOffsetX,
      height * 0.32 + rearOffsetY,
      width * 0.52,
      height * 0.38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rearCardRect, Radius.circular(width * 0.06)),
      createLinePaint(
        color: color.withValues(alpha: 0.4 + 0.6 * animationProgress),
        strokeWidth: strokeWidth,
      ),
    );

    // Front card outline
    final Rect frontCardRect = Rect.fromLTWH(
      width * 0.18,
      height * 0.36,
      width * 0.54,
      height * 0.40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontCardRect, Radius.circular(width * 0.06)),
      linePaint,
    );

    // Front card details (avatar dot and text line)
    canvas.drawCircle(
      Offset(width * 0.30, height * 0.52),
      width * 0.045,
      linePaint,
    );

    canvas.drawLine(
      Offset(width * 0.40, height * 0.49),
      Offset(width * 0.62, height * 0.49),
      linePaint,
    );

    canvas.drawLine(
      Offset(width * 0.40, height * 0.57),
      Offset(width * 0.54, height * 0.57),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CardDuplexLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Batch Card AI icon with 4 corner reticles locking inward.
class BatchAiLinePainter extends CustomPainter {
  const BatchAiLinePainter({
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

    // Reticle expansion offset
    final double spreadOffset = (1.0 - animationProgress) * (width * 0.09);
    final double bracketLength = width * 0.12;

    final double leftX = width * 0.18 - spreadOffset;
    final double topY = height * 0.20 - spreadOffset;
    final double rightX = width * 0.82 + spreadOffset;
    final double bottomY = height * 0.80 + spreadOffset;

    // 4 Corner brackets
    // Top-left
    final Path topLeft = Path()
      ..moveTo(leftX, topY + bracketLength)
      ..lineTo(leftX, topY)
      ..lineTo(leftX + bracketLength, topY);
    canvas.drawPath(topLeft, linePaint);

    // Top-right
    final Path topRight = Path()
      ..moveTo(rightX - bracketLength, topY)
      ..lineTo(rightX, topY)
      ..lineTo(rightX, topY + bracketLength);
    canvas.drawPath(topRight, linePaint);

    // Bottom-left
    final Path bottomLeft = Path()
      ..moveTo(leftX, bottomY - bracketLength)
      ..lineTo(leftX, bottomY)
      ..lineTo(leftX + bracketLength, bottomY);
    canvas.drawPath(bottomLeft, linePaint);

    // Bottom-right
    final Path bottomRight = Path()
      ..moveTo(rightX - bracketLength, bottomY)
      ..lineTo(rightX, bottomY)
      ..lineTo(rightX, bottomY - bracketLength);
    canvas.drawPath(bottomRight, linePaint);

    // Central card silhouette
    final Rect innerCardRect = Rect.fromLTWH(
      width * 0.30,
      height * 0.36,
      width * 0.40,
      height * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerCardRect, Radius.circular(width * 0.04)),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant BatchAiLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Compile PDF icon with downward arrow descending into tray.
class PdfLinePainter extends CustomPainter {
  const PdfLinePainter({
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

    // Paper tray / document frame
    final Path sheetPath = Path()
      ..moveTo(width * 0.22, height * 0.76)
      ..lineTo(width * 0.22, height * 0.22)
      ..lineTo(width * 0.58, height * 0.22)
      ..lineTo(width * 0.78, height * 0.42)
      ..lineTo(width * 0.78, height * 0.76)
      ..close();
    canvas.drawPath(sheetPath, linePaint);

    // Folded corner line
    final Path foldPath = Path()
      ..moveTo(width * 0.58, height * 0.22)
      ..lineTo(width * 0.58, height * 0.42)
      ..lineTo(width * 0.78, height * 0.42);
    canvas.drawPath(foldPath, linePaint);

    // Downward arrow: descends smoothly into position
    final double arrowTravelY = animationProgress * (height * 0.08);
    final double arrowTopY = height * 0.38 + arrowTravelY;
    final double arrowTipY = height * 0.62 + arrowTravelY;
    final double arrowCenterX = width * 0.48;

    final Path arrowPath = Path()
      ..moveTo(arrowCenterX, arrowTopY)
      ..lineTo(arrowCenterX, arrowTipY)
      ..moveTo(arrowCenterX - width * 0.09, arrowTipY - height * 0.07)
      ..lineTo(arrowCenterX, arrowTipY)
      ..lineTo(arrowCenterX + width * 0.09, arrowTipY - height * 0.07);
    canvas.drawPath(arrowPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant PdfLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Receipt Archive icon with paper feeding downward smoothly.
class ReceiptLinePainter extends CustomPainter {
  const ReceiptLinePainter({
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

    // Feed offset: feeds downward by 4px
    final double feedOffsetY = animationProgress * (height * 0.08);

    final double leftX = width * 0.26;
    final double rightX = width * 0.74;
    final double topY = height * 0.16 + feedOffsetY;
    final double bottomY = height * 0.74 + feedOffsetY;

    // Serrated bottom zig-zag
    final double segmentWidth = (rightX - leftX) / 4.0;
    final double toothDepth = height * 0.05;

    final Path receiptPath = Path()
      ..moveTo(leftX, topY)
      ..lineTo(rightX, topY)
      ..lineTo(rightX, bottomY);

    for (int toothIndex = 4; toothIndex > 0; toothIndex--) {
      final double targetX = leftX + (toothIndex - 0.5) * segmentWidth;
      final double endX = leftX + (toothIndex - 1.0) * segmentWidth;
      receiptPath.lineTo(targetX, bottomY - toothDepth);
      receiptPath.lineTo(endX, bottomY);
    }
    receiptPath.close();
    canvas.drawPath(receiptPath, linePaint);

    // Text bar lines inside receipt
    canvas.drawLine(
      Offset(leftX + width * 0.08, topY + height * 0.14),
      Offset(rightX - width * 0.08, topY + height * 0.14),
      linePaint,
    );
    canvas.drawLine(
      Offset(leftX + width * 0.08, topY + height * 0.26),
      Offset(rightX - width * 0.16, topY + height * 0.26),
      linePaint,
    );
    canvas.drawLine(
      Offset(leftX + width * 0.08, topY + height * 0.38),
      Offset(rightX - width * 0.10, topY + height * 0.38),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ReceiptLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Legal 2-Pass Stitch icon with two sheets sliding together.
class LegalStitchLinePainter extends CustomPainter {
  const LegalStitchLinePainter({
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

    // Slide distance towards center seam
    final double gapOffset = (1.0 - animationProgress) * (height * 0.08);

    final double leftX = width * 0.25;
    final double rightX = width * 0.75;
    final double seamY = height * 0.50;

    // Top half sheet
    final Path topSheet = Path()
      ..moveTo(leftX, seamY - gapOffset)
      ..lineTo(leftX, height * 0.18 - gapOffset)
      ..lineTo(rightX, height * 0.18 - gapOffset)
      ..lineTo(rightX, seamY - gapOffset);
    canvas.drawPath(topSheet, linePaint);

    // Bottom half sheet
    final Path bottomSheet = Path()
      ..moveTo(leftX, seamY + gapOffset)
      ..lineTo(leftX, height * 0.82 + gapOffset)
      ..lineTo(rightX, height * 0.82 + gapOffset)
      ..lineTo(rightX, seamY + gapOffset);
    canvas.drawPath(bottomSheet, linePaint);

    // Dashed center stitch seam
    final Paint dashedPaint = createLinePaint(
      color: color.withValues(alpha: 0.5 + 0.5 * animationProgress),
      strokeWidth: strokeWidth * 0.9,
    );

    const int dashSegments = 5;
    final double totalWidth = rightX - leftX;
    final double segmentSpan = totalWidth / (dashSegments * 2 - 1);

    for (int dashIndex = 0; dashIndex < dashSegments; dashIndex++) {
      final double startX = leftX + (dashIndex * 2) * segmentSpan;
      final double endX = startX + segmentSpan;
      canvas.drawLine(Offset(startX, seamY), Offset(endX, seamY), dashedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LegalStitchLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for High-Res Archive icon with spinning diamond optical star.
class HighResArchiveLinePainter extends CustomPainter {
  const HighResArchiveLinePainter({
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

    // Archive safe frame
    final Rect vaultRect = Rect.fromLTRB(
      width * 0.18,
      height * 0.20,
      width * 0.82,
      height * 0.80,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vaultRect, Radius.circular(width * 0.08)),
      linePaint,
    );

    // Central optical diamond star: scales slightly and rotates 45 degrees
    final double centerX = width * 0.50;
    final double centerY = height * 0.50;
    final double rotationAngle = animationProgress * (math.pi / 4.0);
    final double starRadius = width * (0.13 + 0.03 * animationProgress);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAngle);

    final Path starPath = Path()
      ..moveTo(0, -starRadius)
      ..quadraticBezierTo(0, 0, starRadius, 0)
      ..quadraticBezierTo(0, 0, 0, starRadius)
      ..quadraticBezierTo(0, 0, -starRadius, 0)
      ..quadraticBezierTo(0, 0, 0, -starRadius);
    canvas.drawPath(starPath, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HighResArchiveLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Grayscale / B&W Document icon with staggered drawing text lines.
class DocumentLinePainter extends CustomPainter {
  const DocumentLinePainter({
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

    // Document perimeter with dog-ear corner
    final Path documentPath = Path()
      ..moveTo(width * 0.22, height * 0.82)
      ..lineTo(width * 0.22, height * 0.18)
      ..lineTo(width * 0.58, height * 0.18)
      ..lineTo(width * 0.78, height * 0.38)
      ..lineTo(width * 0.78, height * 0.82)
      ..close();
    canvas.drawPath(documentPath, linePaint);

    // Staggered horizontal text lines
    final double startX = width * 0.32;
    final double maxLine1Width = width * 0.34;
    final double maxLine2Width = width * 0.30;
    final double maxLine3Width = width * 0.24;

    // Line 1: progress [0.0 -> 0.6]
    final double progressLine1 = (animationProgress / 0.6).clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(startX, height * 0.46),
      Offset(startX + maxLine1Width * (0.4 + 0.6 * progressLine1), height * 0.46),
      linePaint,
    );

    // Line 2: progress [0.2 -> 0.8]
    final double progressLine2 = ((animationProgress - 0.2) / 0.6).clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(startX, height * 0.58),
      Offset(startX + maxLine2Width * (0.4 + 0.6 * progressLine2), height * 0.58),
      linePaint,
    );

    // Line 3: progress [0.4 -> 1.0]
    final double progressLine3 = ((animationProgress - 0.4) / 0.6).clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(startX, height * 0.70),
      Offset(startX + maxLine3Width * (0.4 + 0.6 * progressLine3), height * 0.70),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant DocumentLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for Quick Preview icon with double-blink eyelid kinematics on hover.
class QuickPreviewLinePainter extends CustomPainter {
  const QuickPreviewLinePainter({
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

    final double leftX = width * 0.16;
    final double rightX = width * 0.84;
    final double centerY = height * 0.50;

    // Double-blink modulation: completes two quick blinks across animationProgress (0.0 -> 1.0)
    // cos(progress * 4 * pi) produces two dips to 0.0 at progress = 0.25 and 0.75
    final double cosineCycle = math.cos(animationProgress * 4.0 * math.pi);
    final double blinkFactor = (0.08 + 0.92 * math.pow(cosineCycle.abs(), 0.75)).clamp(0.06, 1.0);

    // Eyelid aperture expands to resting open height modulated by the double blink
    final double baseAperture = height * 0.26;
    final double effectiveAperture = baseAperture * blinkFactor;

    // Upper eyelid arc
    final Path upperLid = Path()
      ..moveTo(leftX, centerY)
      ..quadraticBezierTo(width * 0.50, centerY - effectiveAperture, rightX, centerY);
    canvas.drawPath(upperLid, linePaint);

    // Lower eyelid arc
    final Path lowerLid = Path()
      ..moveTo(leftX, centerY)
      ..quadraticBezierTo(width * 0.50, centerY + effectiveAperture, rightX, centerY);
    canvas.drawPath(lowerLid, linePaint);

    // Center pupil / iris circle scales with eyelid aperture
    final double pupilRadius = (width * 0.08) * blinkFactor;
    if (pupilRadius > 1.0) {
      canvas.drawCircle(
        Offset(width * 0.50, centerY),
        pupilRadius,
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QuickPreviewLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
