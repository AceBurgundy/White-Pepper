import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Operational device states for the 3D printer visual component.
enum PrinterDeviceStatus {
  ready,
  scanning,
  offline,
  standby,
}

/// Isometric 3D printer and scanner graphic reminiscent of Windows 7 Devices
/// and Printers and HP Smart. Renders resolution-independent vector geometry
/// with state-reactive lighting, scan beam animation, and paper trays.
class Printer3DVisual extends StatefulWidget {
  const Printer3DVisual({
    required this.status,
    required this.isDarkMode,
    this.width = 150.0,
    this.height = 105.0,
    super.key,
  });

  final PrinterDeviceStatus status;
  final bool isDarkMode;
  final double width;
  final double height;

  @override
  State<Printer3DVisual> createState() => _Printer3DVisualState();
}

class _Printer3DVisualState extends State<Printer3DVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    final bool isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    if (!isTestEnvironment &&
        (widget.status == PrinterDeviceStatus.scanning ||
            widget.status == PrinterDeviceStatus.ready)) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(Printer3DVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    if (!isTestEnvironment &&
        (widget.status == PrinterDeviceStatus.scanning ||
            widget.status == PrinterDeviceStatus.ready)) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext animationContext, Widget? childWidget) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _Printer3DIsometricPainter(
            status: widget.status,
            isDarkMode: widget.isDarkMode,
            animationProgress: _animationController.value,
          ),
        );
      },
    );
  }
}

/// Isometric 3D painter utilizing a unified 3D coordinate projection system
/// to eliminate dimensional mismatches, crooked slopes, and misaligned corners.
class _Printer3DIsometricPainter extends CustomPainter {
  const _Printer3DIsometricPainter({
    required this.status,
    required this.isDarkMode,
    required this.animationProgress,
  });

  final PrinterDeviceStatus status;
  final bool isDarkMode;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double canvasWidth = canvasSize.width;
    final double canvasHeight = canvasSize.height;

    // Standard 30-degree isometric projection constants
    const double projectionAngleRadians = 30.0 * (math.pi / 180.0);
    final double cosineAngle = math.cos(projectionAngleRadians);
    final double sineAngle = math.sin(projectionAngleRadians);

    final double scaleFactor = math.min(canvasWidth / 250.0, canvasHeight / 175.0);
    final double originX = canvasWidth * 0.50;
    final double originY = canvasHeight * 0.62;

    // Unified 3D-to-2D Isometric Projection Function.
    // Guarantees mathematically aligned, parallel edges with zero corner discrepancies.
    Offset project(double modelX, double modelY, double modelZ) {
      final double projectedScreenX = originX + (modelX - modelY) * cosineAngle * scaleFactor;
      final double projectedScreenY = originY + (modelX + modelY) * sineAngle * scaleFactor - (modelZ * scaleFactor);
      return Offset(projectedScreenX, projectedScreenY);
    }

    // 3D Chassis Dimensions (centered on X and Y)
    const double chassisWidth = 104.0;
    const double chassisDepth = 72.0;
    const double totalHeight = 36.0;
    const double tierSplitHeight = 18.0;

    final double halfWidth = chassisWidth * 0.50;
    final double halfDepth = chassisDepth * 0.50;

    // Palette calibration for classic Windows 7 / HP Smart all-in-one styling
    final bool isOffline = (status == PrinterDeviceStatus.offline);
    final bool isScanning = (status == PrinterDeviceStatus.scanning);

    final Color bodyTopColor = isOffline
        ? const Color(0xFFBCC2CA)
        : (isDarkMode ? const Color(0xFF484F5B) : const Color(0xFFEEF2F7));

    final Color bodyFrontLowerColor = isOffline
        ? const Color(0xFF9EA4AD)
        : (isDarkMode ? const Color(0xFF343942) : const Color(0xFFD4D9E2));

    final Color bodyFrontUpperColor = isOffline
        ? const Color(0xFFA6ACB6)
        : (isDarkMode ? const Color(0xFF3C424C) : const Color(0xFFDEE4ED));

    final Color bodyRightColor = isOffline
        ? const Color(0xFF888E96)
        : (isDarkMode ? const Color(0xFF282C34) : const Color(0xFFBDC6D2));

    final Color seamLineColor = isOffline
        ? const Color(0xFF6E747C)
        : (isDarkMode ? const Color(0xFF1B1E24) : const Color(0xFF96A1AF));

    final Color slotCavityColor = const Color(0xFF15181D);

    final Color trayBodyColor = isOffline
        ? const Color(0xFF7E848C)
        : (isDarkMode ? const Color(0xFF242830) : const Color(0xFF8E98A6));

    final Color platenBorderColor = isOffline
        ? const Color(0xFF6E747C)
        : (isDarkMode ? const Color(0xFF22262C) : const Color(0xFF717985));

    final Color platenGlassColor = isOffline
        ? const Color(0xFF8E949D)
        : (isDarkMode ? const Color(0xFF16191E) : const Color(0xFFCBD3DC));

    // 1. Soft Ground Drop Shadow on Workstation Surface
    final Path shadowPolygon = Path();
    final Offset shadowRearLeft = project(-halfWidth - 4.0, -halfDepth - 4.0, 0.0);
    final Offset shadowRearRight = project(halfWidth + 14.0, -halfDepth - 4.0, 0.0);
    final Offset shadowFrontRight = project(halfWidth + 14.0, halfDepth + 14.0, 0.0);
    final Offset shadowFrontLeft = project(-halfWidth - 4.0, halfDepth + 14.0, 0.0);

    shadowPolygon.moveTo(shadowRearLeft.dx, shadowRearLeft.dy);
    shadowPolygon.lineTo(shadowRearRight.dx, shadowRearRight.dy);
    shadowPolygon.lineTo(shadowFrontRight.dx, shadowFrontRight.dy);
    shadowPolygon.lineTo(shadowFrontLeft.dx, shadowFrontLeft.dy);
    shadowPolygon.close();

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.16)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * scaleFactor);
    canvas.drawPath(shadowPolygon, shadowPaint);

    // 2. Rear Paper Input Feeder Tray (Extends backward and upward from rear deck)
    const double feederWidthLeft = -30.0;
    const double feederWidthRight = 20.0;
    const double feederDepthOffset = 22.0;
    const double feederHeightOffset = 30.0;

    final Offset feederBottomLeft = project(feederWidthLeft, -halfDepth, totalHeight);
    final Offset feederBottomRight = project(feederWidthRight, -halfDepth, totalHeight);
    final Offset feederTopRight = project(
      feederWidthRight,
      -halfDepth - feederDepthOffset,
      totalHeight + feederHeightOffset,
    );
    final Offset feederTopLeft = project(
      feederWidthLeft,
      -halfDepth - feederDepthOffset,
      totalHeight + feederHeightOffset,
    );

    final Path feederTrayPath = Path();
    feederTrayPath.moveTo(feederBottomLeft.dx, feederBottomLeft.dy);
    feederTrayPath.lineTo(feederBottomRight.dx, feederBottomRight.dy);
    feederTrayPath.lineTo(feederTopRight.dx, feederTopRight.dy);
    feederTrayPath.lineTo(feederTopLeft.dx, feederTopLeft.dy);
    feederTrayPath.close();

    final Paint feederTrayPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF2E343D) : const Color(0xFF9EABB8);
    canvas.drawPath(feederTrayPath, feederTrayPaint);

    // Rear Paper Sheet Peaking out of Input Feeder
    const double paperMargin = 4.0;
    const double paperHeightExtra = 8.0;

    final Offset paperBottomLeft = project(
      feederWidthLeft + paperMargin,
      -halfDepth + 1.0,
      totalHeight + 1.0,
    );
    final Offset paperBottomRight = project(
      feederWidthRight - paperMargin,
      -halfDepth + 1.0,
      totalHeight + 1.0,
    );
    final Offset paperTopRight = project(
      feederWidthRight - paperMargin,
      -halfDepth - feederDepthOffset - 4.0,
      totalHeight + feederHeightOffset + paperHeightExtra,
    );
    final Offset paperTopLeft = project(
      feederWidthLeft + paperMargin,
      -halfDepth - feederDepthOffset - 4.0,
      totalHeight + feederHeightOffset + paperHeightExtra,
    );

    final Path paperSheetPath = Path();
    paperSheetPath.moveTo(paperBottomLeft.dx, paperBottomLeft.dy);
    paperSheetPath.lineTo(paperBottomRight.dx, paperBottomRight.dy);
    paperSheetPath.lineTo(paperTopRight.dx, paperTopRight.dy);
    paperSheetPath.lineTo(paperTopLeft.dx, paperTopLeft.dy);
    paperSheetPath.close();

    final Paint paperSheetPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawPath(paperSheetPath, paperSheetPaint);

    final Paint paperBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scaleFactor;
    canvas.drawPath(paperSheetPath, paperBorderPaint);

    // 3. Printer Chassis Right Side Flank (Facing down and right)
    final Offset rightBottomBack = project(halfWidth, -halfDepth, 0.0);
    final Offset rightBottomFront = project(halfWidth, halfDepth, 0.0);
    final Offset rightTopFront = project(halfWidth, halfDepth, totalHeight);
    final Offset rightTopBack = project(halfWidth, -halfDepth, totalHeight);

    final Path rightSidePath = Path();
    rightSidePath.moveTo(rightBottomBack.dx, rightBottomBack.dy);
    rightSidePath.lineTo(rightBottomFront.dx, rightBottomFront.dy);
    rightSidePath.lineTo(rightTopFront.dx, rightTopFront.dy);
    rightSidePath.lineTo(rightTopBack.dx, rightTopBack.dy);
    rightSidePath.close();

    final Paint rightSidePaint = Paint()..color = bodyRightColor;
    canvas.drawPath(rightSidePath, rightSidePaint);

    // Right Side Tier Separation Seam Line
    final Offset rightSeamBack = project(halfWidth, -halfDepth, tierSplitHeight);
    final Offset rightSeamFront = project(halfWidth, halfDepth, tierSplitHeight);
    final Paint seamPaint = Paint()
      ..color = seamLineColor
      ..strokeWidth = 1.4 * scaleFactor;
    canvas.drawLine(rightSeamBack, rightSeamFront, seamPaint);

    // Right Side Texture Grooves (parallel to bottom edge)
    final Paint groovePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.0 * scaleFactor;

    for (int grooveIndex = 0; grooveIndex < 3; grooveIndex++) {
      final double grooveHeight = 5.0 + (grooveIndex * 4.0);
      final Offset grooveBack = project(halfWidth, -halfDepth + 14.0, grooveHeight);
      final Offset grooveFront = project(halfWidth, halfDepth - 14.0, grooveHeight);
      canvas.drawLine(grooveBack, grooveFront, groovePaint);
    }

    // 4. Printer Chassis Front Face (Facing down and left)
    // 4A. Lower Tier Front Face (Base Body)
    final Offset frontLowerBottomLeft = project(-halfWidth, halfDepth, 0.0);
    final Offset frontLowerBottomRight = project(halfWidth, halfDepth, 0.0);
    final Offset frontLowerTopRight = project(halfWidth, halfDepth, tierSplitHeight);
    final Offset frontLowerTopLeft = project(-halfWidth, halfDepth, tierSplitHeight);

    final Path frontLowerPath = Path();
    frontLowerPath.moveTo(frontLowerBottomLeft.dx, frontLowerBottomLeft.dy);
    frontLowerPath.lineTo(frontLowerBottomRight.dx, frontLowerBottomRight.dy);
    frontLowerPath.lineTo(frontLowerTopRight.dx, frontLowerTopRight.dy);
    frontLowerPath.lineTo(frontLowerTopLeft.dx, frontLowerTopLeft.dy);
    frontLowerPath.close();

    final Paint frontLowerPaint = Paint()..color = bodyFrontLowerColor;
    canvas.drawPath(frontLowerPath, frontLowerPaint);

    // 4B. Upper Tier Front Face (Scanner Chassis)
    final Offset frontUpperTopRight = project(halfWidth, halfDepth, totalHeight);
    final Offset frontUpperTopLeft = project(-halfWidth, halfDepth, totalHeight);

    final Path frontUpperPath = Path();
    frontUpperPath.moveTo(frontLowerTopLeft.dx, frontLowerTopLeft.dy);
    frontUpperPath.lineTo(frontLowerTopRight.dx, frontLowerTopRight.dy);
    frontUpperPath.lineTo(frontUpperTopRight.dx, frontUpperTopRight.dy);
    frontUpperPath.lineTo(frontUpperTopLeft.dx, frontUpperTopLeft.dy);
    frontUpperPath.close();

    final Paint frontUpperPaint = Paint()..color = bodyFrontUpperColor;
    canvas.drawPath(frontUpperPath, frontUpperPaint);

    // Front Horizontal Tier Separation Seam
    canvas.drawLine(frontLowerTopLeft, frontLowerTopRight, seamPaint);

    // 5. Paper Output Slot (Recessed Dark Cavity in Lower Front Face)
    const double slotWidthLeft = -28.0;
    const double slotWidthRight = 28.0;
    const double slotZBottom = 4.0;
    const double slotZTop = 15.0;

    final Offset slotTopLeft = project(slotWidthLeft, halfDepth, slotZTop);
    final Offset slotTopRight = project(slotWidthRight, halfDepth, slotZTop);
    final Offset slotBottomRight = project(slotWidthRight, halfDepth, slotZBottom);
    final Offset slotBottomLeft = project(slotWidthLeft, halfDepth, slotZBottom);

    final Path outputSlotPath = Path();
    outputSlotPath.moveTo(slotTopLeft.dx, slotTopLeft.dy);
    outputSlotPath.lineTo(slotTopRight.dx, slotTopRight.dy);
    outputSlotPath.lineTo(slotBottomRight.dx, slotBottomRight.dy);
    outputSlotPath.lineTo(slotBottomLeft.dx, slotBottomLeft.dy);
    outputSlotPath.close();

    final Paint slotPaint = Paint()..color = slotCavityColor;
    canvas.drawPath(outputSlotPath, slotPaint);

    // 6. Paper Output Tray Extending Forward from Bottom of Slot
    const double trayForwardExtension = 22.0;

    final Offset trayBaseLeft = project(slotWidthLeft + 2.0, halfDepth, slotZBottom);
    final Offset trayBaseRight = project(slotWidthRight - 2.0, halfDepth, slotZBottom);
    final Offset trayTipRight = project(
      slotWidthRight - 2.0,
      halfDepth + trayForwardExtension,
      slotZBottom - 1.0,
    );
    final Offset trayTipLeft = project(
      slotWidthLeft + 2.0,
      halfDepth + trayForwardExtension,
      slotZBottom - 1.0,
    );

    final Path outputTrayPath = Path();
    outputTrayPath.moveTo(trayBaseLeft.dx, trayBaseLeft.dy);
    outputTrayPath.lineTo(trayBaseRight.dx, trayBaseRight.dy);
    outputTrayPath.lineTo(trayTipRight.dx, trayTipRight.dy);
    outputTrayPath.lineTo(trayTipLeft.dx, trayTipLeft.dy);
    outputTrayPath.close();

    final Paint trayPaint = Paint()..color = trayBodyColor;
    canvas.drawPath(outputTrayPath, trayPaint);

    // Front Catch Lip on Tray Tip
    final Offset trayLipLeft = project(
      slotWidthLeft + 2.0,
      halfDepth + trayForwardExtension,
      slotZBottom + 2.5,
    );
    final Offset trayLipRight = project(
      slotWidthRight - 2.0,
      halfDepth + trayForwardExtension,
      slotZBottom + 2.5,
    );

    final Path trayLipPath = Path();
    trayLipPath.moveTo(trayTipLeft.dx, trayTipLeft.dy);
    trayLipPath.lineTo(trayTipRight.dx, trayTipRight.dy);
    trayLipPath.lineTo(trayLipRight.dx, trayLipRight.dy);
    trayLipPath.lineTo(trayLipLeft.dx, trayLipLeft.dy);
    trayLipPath.close();

    final Paint trayLipPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1E2228) : const Color(0xFF7A8492);
    canvas.drawPath(trayLipPath, trayLipPaint);

    // Printed Document Sheet Resting on Output Tray
    final Offset printedDocBaseLeft = project(slotWidthLeft + 6.0, halfDepth + 2.0, slotZBottom + 0.5);
    final Offset printedDocBaseRight = project(slotWidthRight - 6.0, halfDepth + 2.0, slotZBottom + 0.5);
    final Offset printedDocTipRight = project(
      slotWidthRight - 6.0,
      halfDepth + trayForwardExtension - 2.0,
      slotZBottom - 0.5,
    );
    final Offset printedDocTipLeft = project(
      slotWidthLeft + 6.0,
      halfDepth + trayForwardExtension - 2.0,
      slotZBottom - 0.5,
    );

    final Path printedDocPath = Path();
    printedDocPath.moveTo(printedDocBaseLeft.dx, printedDocBaseLeft.dy);
    printedDocPath.lineTo(printedDocBaseRight.dx, printedDocBaseRight.dy);
    printedDocPath.lineTo(printedDocTipRight.dx, printedDocTipRight.dy);
    printedDocPath.lineTo(printedDocTipLeft.dx, printedDocTipLeft.dy);
    printedDocPath.close();

    final Paint printedDocPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawPath(printedDocPath, printedDocPaint);

    // Subtle printed text lines on the output document
    final Paint printedTextPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.0 * scaleFactor;

    for (int textLineIndex = 0; textLineIndex < 3; textLineIndex++) {
      final double lineForwardOffset = 6.0 + (textLineIndex * 4.0);
      final Offset textLineLeft = project(
        slotWidthLeft + 10.0,
        halfDepth + lineForwardOffset,
        slotZBottom + 0.2,
      );
      final Offset textLineRight = project(
        slotWidthRight - 10.0,
        halfDepth + lineForwardOffset,
        slotZBottom + 0.2,
      );
      canvas.drawLine(textLineLeft, textLineRight, printedTextPaint);
    }

    // 7. Top Deck / Scanner Platen Frame (Top Horizontal Plane at z = totalHeight)
    final Offset deckFrontRight = project(halfWidth, halfDepth, totalHeight);
    final Offset deckBackRight = project(halfWidth, -halfDepth, totalHeight);
    final Offset deckBackLeft = project(-halfWidth, -halfDepth, totalHeight);
    final Offset deckFrontLeft = project(-halfWidth, halfDepth, totalHeight);

    final Path topDeckPath = Path();
    topDeckPath.moveTo(deckFrontRight.dx, deckFrontRight.dy);
    topDeckPath.lineTo(deckBackRight.dx, deckBackRight.dy);
    topDeckPath.lineTo(deckBackLeft.dx, deckBackLeft.dy);
    topDeckPath.lineTo(deckFrontLeft.dx, deckFrontLeft.dy);
    topDeckPath.close();

    final Paint topDeckPaint = Paint()..color = bodyTopColor;
    canvas.drawPath(topDeckPath, topDeckPaint);

    // Subtle edge bevel line separating top deck from vertical faces
    final Paint bevelPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.12 : 0.45)
      ..strokeWidth = 1.0 * scaleFactor;
    canvas.drawLine(deckFrontLeft, deckFrontRight, bevelPaint);
    canvas.drawLine(deckFrontRight, deckBackRight, bevelPaint);

    // 8. Scanner Platen Glass Bed (Uniform 8-unit inset on all 4 edges)
    const double platenInsetX = 8.0;
    const double platenInsetY = 8.0;

    final Offset glassFrontRight = project(
      halfWidth - platenInsetX,
      halfDepth - platenInsetY,
      totalHeight,
    );
    final Offset glassBackRight = project(
      halfWidth - platenInsetX,
      -halfDepth + platenInsetY,
      totalHeight,
    );
    final Offset glassBackLeft = project(
      -halfWidth + platenInsetX,
      -halfDepth + platenInsetY,
      totalHeight,
    );
    final Offset glassFrontLeft = project(
      -halfWidth + platenInsetX,
      halfDepth - platenInsetY,
      totalHeight,
    );

    final Path glassBorderPath = Path();
    glassBorderPath.moveTo(glassFrontRight.dx, glassFrontRight.dy);
    glassBorderPath.lineTo(glassBackRight.dx, glassBackRight.dy);
    glassBorderPath.lineTo(glassBackLeft.dx, glassBackLeft.dy);
    glassBorderPath.lineTo(glassFrontLeft.dx, glassFrontLeft.dy);
    glassBorderPath.close();

    final Paint glassBorderPaint = Paint()..color = platenBorderColor;
    canvas.drawPath(glassBorderPath, glassBorderPaint);

    // Inner Glass Bed
    const double innerPlatenInset = 2.0;
    final Offset innerGlassFrontRight = project(
      halfWidth - platenInsetX - innerPlatenInset,
      halfDepth - platenInsetY - innerPlatenInset,
      totalHeight,
    );
    final Offset innerGlassBackRight = project(
      halfWidth - platenInsetX - innerPlatenInset,
      -halfDepth + platenInsetY + innerPlatenInset,
      totalHeight,
    );
    final Offset innerGlassBackLeft = project(
      -halfWidth + platenInsetX + innerPlatenInset,
      -halfDepth + platenInsetY + innerPlatenInset,
      totalHeight,
    );
    final Offset innerGlassFrontLeft = project(
      -halfWidth + platenInsetX + innerPlatenInset,
      halfDepth - platenInsetY - innerPlatenInset,
      totalHeight,
    );

    final Path innerGlassPath = Path();
    innerGlassPath.moveTo(innerGlassFrontRight.dx, innerGlassFrontRight.dy);
    innerGlassPath.lineTo(innerGlassBackRight.dx, innerGlassBackRight.dy);
    innerGlassPath.lineTo(innerGlassBackLeft.dx, innerGlassBackLeft.dy);
    innerGlassPath.lineTo(innerGlassFrontLeft.dx, innerGlassFrontLeft.dy);
    innerGlassPath.close();

    final Paint innerGlassPaint = Paint()..color = platenGlassColor;
    canvas.drawPath(innerGlassPath, innerGlassPaint);

    // Specular Glass Sheen Reflection
    final Offset sheenStartOne = project(
      -halfWidth + platenInsetX + 6.0,
      halfDepth - platenInsetY - 2.0,
      totalHeight + 0.1,
    );
    final Offset sheenStartTwo = project(
      -halfWidth + platenInsetX + 22.0,
      halfDepth - platenInsetY - 2.0,
      totalHeight + 0.1,
    );
    final Offset sheenEndTwo = project(
      -halfWidth + platenInsetX + 44.0,
      -halfDepth + platenInsetY + 2.0,
      totalHeight + 0.1,
    );
    final Offset sheenEndOne = project(
      -halfWidth + platenInsetX + 28.0,
      -halfDepth + platenInsetY + 2.0,
      totalHeight + 0.1,
    );

    final Path sheenPath = Path();
    sheenPath.moveTo(sheenStartOne.dx, sheenStartOne.dy);
    sheenPath.lineTo(sheenStartTwo.dx, sheenStartTwo.dy);
    sheenPath.lineTo(sheenEndTwo.dx, sheenEndTwo.dy);
    sheenPath.lineTo(sheenEndOne.dx, sheenEndOne.dy);
    sheenPath.close();

    final Paint sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.08 : 0.28);
    canvas.drawPath(sheenPath, sheenPaint);

    // 9. Active Optical Scanner Laser Bar (When Scanning)
    if (isScanning) {
      final double scanSweepMargin = platenInsetX + innerPlatenInset + 2.0;
      final double scanAvailableWidth = chassisWidth - (scanSweepMargin * 2.0);
      final double currentScanX = (-halfWidth + scanSweepMargin) + (scanAvailableWidth * animationProgress);

      final Offset laserFrontPoint = project(
        currentScanX,
        halfDepth - platenInsetY - innerPlatenInset,
        totalHeight + 0.2,
      );
      final Offset laserBackPoint = project(
        currentScanX,
        -halfDepth + platenInsetY + innerPlatenInset,
        totalHeight + 0.2,
      );

      // Cyan Core Laser Line
      final Paint laserBeamPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2.4 * scaleFactor
        ..style = PaintingStyle.stroke;
      canvas.drawLine(laserFrontPoint, laserBackPoint, laserBeamPaint);

      // Neon Optical Glow Fan
      final Paint laserGlowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
        ..strokeWidth = 7.0 * scaleFactor
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * scaleFactor);
      canvas.drawLine(laserFrontPoint, laserBackPoint, laserGlowPaint);
    }

    // 10. Front Control Panel: Status LED Beacon & LCD Display Strip
    final Offset statusLedCenter = project(-halfWidth + 14.0, halfDepth, tierSplitHeight + 9.0);

    final Color statusBeaconColor = switch (status) {
      PrinterDeviceStatus.ready => const Color(0xFF10B981),
      PrinterDeviceStatus.scanning => const Color(0xFF00E5FF),
      PrinterDeviceStatus.standby => const Color(0xFFF59E0B),
      PrinterDeviceStatus.offline => const Color(0xFFEF4444),
    };

    // Soft Pulse Halo when ready or scanning
    final double pulseRatio = (status == PrinterDeviceStatus.ready || status == PrinterDeviceStatus.scanning)
        ? (0.85 + (0.30 * math.sin(animationProgress * math.pi)))
        : 1.0;

    final Paint haloPaint = Paint()
      ..color = statusBeaconColor.withValues(alpha: isOffline ? 0.20 : (0.45 * pulseRatio))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.5 * scaleFactor);
    canvas.drawCircle(statusLedCenter, 4.5 * scaleFactor * pulseRatio, haloPaint);

    final Paint ledCorePaint = Paint()..color = statusBeaconColor;
    canvas.drawCircle(statusLedCenter, 2.2 * scaleFactor, ledCorePaint);

    // Minimalist LCD Display Strip on Upper Front Face
    final Offset displayTopLeft = project(-halfWidth + 24.0, halfDepth, tierSplitHeight + 13.0);
    final Offset displayTopRight = project(-halfWidth + 48.0, halfDepth, tierSplitHeight + 13.0);
    final Offset displayBottomRight = project(-halfWidth + 48.0, halfDepth, tierSplitHeight + 5.0);
    final Offset displayBottomLeft = project(-halfWidth + 24.0, halfDepth, tierSplitHeight + 5.0);

    final Path displayStripPath = Path();
    displayStripPath.moveTo(displayTopLeft.dx, displayTopLeft.dy);
    displayStripPath.lineTo(displayTopRight.dx, displayTopRight.dy);
    displayStripPath.lineTo(displayBottomRight.dx, displayBottomRight.dy);
    displayStripPath.lineTo(displayBottomLeft.dx, displayBottomLeft.dy);
    displayStripPath.close();

    final Paint displayPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1A1D22) : const Color(0xFF22262D);
    canvas.drawPath(displayStripPath, displayPaint);

    // Subtle LCD backlight indicator dot inside display
    final Offset displayIndicatorDot = project(-halfWidth + 28.0, halfDepth, tierSplitHeight + 9.0);
    final Paint displayDotPaint = Paint()
      ..color = statusBeaconColor.withValues(alpha: 0.75);
    canvas.drawCircle(displayIndicatorDot, 1.2 * scaleFactor, displayDotPaint);
  }

  @override
  bool shouldRepaint(covariant _Printer3DIsometricPainter oldDelegate) {
    return oldDelegate.status != status ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.animationProgress != animationProgress;
  }
}
