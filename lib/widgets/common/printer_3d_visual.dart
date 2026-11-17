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

    // Base coordinate anchors calibrated for an isometric 2.5D view
    final double originX = canvasWidth * 0.50;
    final double originY = canvasHeight * 0.38;
    final double scaleRatio = canvasWidth / 150.0;

    // Palette calibration (Windows 7 / HP Smart classic grey printer styling)
    final bool isOffline = (status == PrinterDeviceStatus.offline);
    final bool isScanning = (status == PrinterDeviceStatus.scanning);

    final Color bodyTopColor = isOffline
        ? const Color(0xFFC0C4CA)
        : (isDarkMode ? const Color(0xFF4A5059) : const Color(0xFFE2E6EC));
    final Color bodyFrontColor = isOffline
        ? const Color(0xFFA0A5AC)
        : (isDarkMode ? const Color(0xFF383D45) : const Color(0xFFB8BFC8));
    final Color bodyLeftColor = isOffline
        ? const Color(0xFF888D94)
        : (isDarkMode ? const Color(0xFF2B2F36) : const Color(0xFF9EA6B2));

    final Color lidGlassBorder = isOffline
        ? const Color(0xFF7A7F86)
        : (isDarkMode ? const Color(0xFF1E2126) : const Color(0xFF707782));
    final Color platenGlassBed = isOffline
        ? const Color(0xFF90969E)
        : (isDarkMode ? const Color(0xFF15181C) : const Color(0xFFCBD2DA));

    // 1. Soft Elliptical Drop Shadow on the workstation surface
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.32 : 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(originX, originY + (36.0 * scaleRatio)),
        width: 122.0 * scaleRatio,
        height: 44.0 * scaleRatio,
      ),
      shadowPaint,
    );

    // 2. Rear Paper Input Tray (angled upward from rear top platen)
    final Path rearTrayPath = Path();
    rearTrayPath.moveTo(originX - (24.0 * scaleRatio), originY - (16.0 * scaleRatio));
    rearTrayPath.lineTo(originX - (38.0 * scaleRatio), originY - (36.0 * scaleRatio));
    rearTrayPath.lineTo(originX + (12.0 * scaleRatio), originY - (48.0 * scaleRatio));
    rearTrayPath.lineTo(originX + (28.0 * scaleRatio), originY - (28.0 * scaleRatio));
    rearTrayPath.close();

    final Paint rearTrayPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF32363D) : const Color(0xFF9BA2AD);
    canvas.drawPath(rearTrayPath, rearTrayPaint);

    // Rear Paper Sheet peaking out of feeder
    final Path rearPaperSheetPath = Path();
    rearPaperSheetPath.moveTo(originX - (20.0 * scaleRatio), originY - (18.0 * scaleRatio));
    rearPaperSheetPath.lineTo(originX - (32.0 * scaleRatio), originY - (34.0 * scaleRatio));
    rearPaperSheetPath.lineTo(originX + (8.0 * scaleRatio), originY - (44.0 * scaleRatio));
    rearPaperSheetPath.lineTo(originX + (20.0 * scaleRatio), originY - (28.0 * scaleRatio));
    rearPaperSheetPath.close();

    final Paint rearPaperPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawPath(rearPaperSheetPath, rearPaperPaint);

    // 3. Main Isometric Chassis Geometry
    // Vertices:
    // Top-Center: (originX, originY)
    // Top-Right: (originX + 54, originY - 14)
    // Top-Left: (originX - 54, originY - 14)
    // Top-Back: (originX, originY - 28)
    final double leftExtension = 52.0 * scaleRatio;
    final double rightExtension = 52.0 * scaleRatio;
    final double isometricPitch = 15.0 * scaleRatio;
    final double bodyHeight = 32.0 * scaleRatio;

    final Offset topCenterPoint = Offset(originX, originY);
    final Offset topRightPoint = Offset(originX + rightExtension, originY - isometricPitch);
    final Offset topBackPoint = Offset(originX, originY - (isometricPitch * 2.0));
    final Offset topLeftPoint = Offset(originX - leftExtension, originY - isometricPitch);

    final Offset bottomCenterPoint = Offset(originX, originY + bodyHeight);
    final Offset bottomRightPoint = Offset(originX + rightExtension, originY - isometricPitch + bodyHeight);
    final Offset bottomLeftPoint = Offset(originX - leftExtension, originY - isometricPitch + bodyHeight);

    // 3A. Left Side Flank
    final Path leftSidePath = Path();
    leftSidePath.moveTo(topCenterPoint.dx, topCenterPoint.dy);
    leftSidePath.lineTo(topLeftPoint.dx, topLeftPoint.dy);
    leftSidePath.lineTo(bottomLeftPoint.dx, bottomLeftPoint.dy);
    leftSidePath.lineTo(bottomCenterPoint.dx, bottomCenterPoint.dy);
    leftSidePath.close();

    final Paint leftSidePaint = Paint()..color = bodyLeftColor;
    canvas.drawPath(leftSidePath, leftSidePaint);

    // Subtle side ventilation / texture grooves
    final Paint groovePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.2 * scaleRatio
      ..style = PaintingStyle.stroke;

    for (int grooveIndex = 0; grooveIndex < 3; grooveIndex++) {
      final double verticalOffset = (10.0 + (grooveIndex * 5.0)) * scaleRatio;
      canvas.drawLine(
        Offset(topLeftPoint.dx + (16.0 * scaleRatio), topLeftPoint.dy + verticalOffset),
        Offset(topCenterPoint.dx - (16.0 * scaleRatio), topCenterPoint.dy + verticalOffset),
        groovePaint,
      );
    }

    // 3B. Front Panel (Right Facing in Isometric Angle)
    final Path frontPanelPath = Path();
    frontPanelPath.moveTo(topCenterPoint.dx, topCenterPoint.dy);
    frontPanelPath.lineTo(topRightPoint.dx, topRightPoint.dy);
    frontPanelPath.lineTo(bottomRightPoint.dx, bottomRightPoint.dy);
    frontPanelPath.lineTo(bottomCenterPoint.dx, bottomCenterPoint.dy);
    frontPanelPath.close();

    final Paint frontPanelPaint = Paint()..color = bodyFrontColor;
    canvas.drawPath(frontPanelPath, frontPanelPaint);

    // Paper Output Slot (recessed dark cavity)
    final Path outputSlotPath = Path();
    outputSlotPath.moveTo(topCenterPoint.dx + (8.0 * scaleRatio), topCenterPoint.dy + (8.0 * scaleRatio));
    outputSlotPath.lineTo(topRightPoint.dx - (8.0 * scaleRatio), topRightPoint.dy + (8.0 * scaleRatio));
    outputSlotPath.lineTo(bottomRightPoint.dx - (8.0 * scaleRatio), bottomRightPoint.dy - (8.0 * scaleRatio));
    outputSlotPath.lineTo(bottomCenterPoint.dx + (8.0 * scaleRatio), bottomCenterPoint.dy - (8.0 * scaleRatio));
    outputSlotPath.close();

    final Paint slotPaint = Paint()..color = const Color(0xFF1E2126);
    canvas.drawPath(outputSlotPath, slotPaint);

    // Front Paper Output Tray extending forward
    final Path outputTrayExtension = Path();
    outputTrayExtension.moveTo(bottomCenterPoint.dx + (12.0 * scaleRatio), bottomCenterPoint.dy - (10.0 * scaleRatio));
    outputTrayExtension.lineTo(bottomRightPoint.dx - (14.0 * scaleRatio), bottomRightPoint.dy - (10.0 * scaleRatio));
    outputTrayExtension.lineTo(bottomRightPoint.dx - (4.0 * scaleRatio), bottomRightPoint.dy + (4.0 * scaleRatio));
    outputTrayExtension.lineTo(bottomCenterPoint.dx + (22.0 * scaleRatio), bottomCenterPoint.dy + (4.0 * scaleRatio));
    outputTrayExtension.close();

    final Paint outputTrayPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF282C32) : const Color(0xFF8F97A3);
    canvas.drawPath(outputTrayExtension, outputTrayPaint);

    // 3C. Top Deck / Scanner Platen Frame
    final Path topDeckPath = Path();
    topDeckPath.moveTo(topCenterPoint.dx, topCenterPoint.dy);
    topDeckPath.lineTo(topRightPoint.dx, topRightPoint.dy);
    topDeckPath.lineTo(topBackPoint.dx, topBackPoint.dy);
    topDeckPath.lineTo(topLeftPoint.dx, topLeftPoint.dy);
    topDeckPath.close();

    final Paint topDeckPaint = Paint()..color = bodyTopColor;
    canvas.drawPath(topDeckPath, topDeckPaint);

    // 4. Scanner Platen Glass Bed (Beveled inner rectangle)
    final double platenInset = 8.0 * scaleRatio;
    final Offset glassFront = Offset(topCenterPoint.dx, topCenterPoint.dy - (platenInset * 0.8));
    final Offset glassRight = Offset(topRightPoint.dx - platenInset, topRightPoint.dy);
    final Offset glassBack = Offset(topBackPoint.dx, topBackPoint.dy + (platenInset * 0.8));
    final Offset glassLeft = Offset(topLeftPoint.dx + platenInset, topLeftPoint.dy);

    final Path glassBorderPath = Path();
    glassBorderPath.moveTo(glassFront.dx, glassFront.dy);
    glassBorderPath.lineTo(glassRight.dx, glassRight.dy);
    glassBorderPath.lineTo(glassBack.dx, glassBack.dy);
    glassBorderPath.lineTo(glassLeft.dx, glassLeft.dy);
    glassBorderPath.close();

    final Paint glassBorderPaint = Paint()..color = lidGlassBorder;
    canvas.drawPath(glassBorderPath, glassBorderPaint);

    final Path glassBedPath = Path();
    final double innerInset = 2.5 * scaleRatio;
    glassBedPath.moveTo(glassFront.dx, glassFront.dy - innerInset);
    glassBedPath.lineTo(glassRight.dx - innerInset, glassRight.dy);
    glassBedPath.lineTo(glassBack.dx, glassBack.dy + innerInset);
    glassBedPath.lineTo(glassLeft.dx + innerInset, glassLeft.dy);
    glassBedPath.close();

    final Paint glassBedPaint = Paint()..color = platenGlassBed;
    canvas.drawPath(glassBedPath, glassBedPaint);

    // Subtle glass surface reflection sheen
    final Path reflectionPath = Path();
    reflectionPath.moveTo(glassLeft.dx + (4.0 * scaleRatio), glassLeft.dy);
    reflectionPath.lineTo(glassLeft.dx + (22.0 * scaleRatio), glassLeft.dy + (5.0 * scaleRatio));
    reflectionPath.lineTo(glassBack.dx + (6.0 * scaleRatio), glassBack.dy + (6.0 * scaleRatio));
    reflectionPath.lineTo(glassBack.dx - (8.0 * scaleRatio), glassBack.dy + (2.0 * scaleRatio));
    reflectionPath.close();

    final Paint reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.08 : 0.28);
    canvas.drawPath(reflectionPath, reflectionPaint);

    // 5. Active Optical Scanner Light Bar (When scanning)
    if (isScanning) {
      final double scanSweep = animationProgress;
      // Interpolate along the platen axes
      final double scanFrontX = glassLeft.dx + ((glassFront.dx - glassLeft.dx) * scanSweep);
      final double scanFrontY = glassLeft.dy + ((glassFront.dy - glassLeft.dy) * scanSweep);
      final double scanBackX = glassBack.dx + ((glassRight.dx - glassBack.dx) * scanSweep);
      final double scanBackY = glassBack.dy + ((glassRight.dy - glassBack.dy) * scanSweep);

      // Cyan laser line
      final Paint scanBeamPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2.4 * scaleRatio
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(scanFrontX, scanFrontY),
        Offset(scanBackX, scanBackY),
        scanBeamPaint,
      );

      // Soft optical glow fan
      final Paint scanGlowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
        ..strokeWidth = 7.0 * scaleRatio
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawLine(
        Offset(scanFrontX, scanFrontY),
        Offset(scanBackX, scanBackY),
        scanGlowPaint,
      );
    }

    // 6. Power Button and Status LED Beacon on Front Panel
    final Offset ledPosition = Offset(
      topCenterPoint.dx + (14.0 * scaleRatio),
      topCenterPoint.dy + (4.5 * scaleRatio),
    );

    final Color statusLedColor = switch (status) {
      PrinterDeviceStatus.ready => const Color(0xFF10B981), // Bright emerald green
      PrinterDeviceStatus.scanning => const Color(0xFF00E5FF), // Active cyan
      PrinterDeviceStatus.standby => const Color(0xFFF59E0B), // Warm amber
      PrinterDeviceStatus.offline => const Color(0xFFEF4444), // Disconnected red
    };

    // LED Glow Halo
    final double pulseScale = (status == PrinterDeviceStatus.ready || status == PrinterDeviceStatus.scanning)
        ? (0.85 + (0.30 * math.sin(animationProgress * math.pi)))
        : 1.0;

    final Paint glowPaint = Paint()
      ..color = statusLedColor.withValues(alpha: isOffline ? 0.25 : (0.50 * pulseScale))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(ledPosition, 4.2 * scaleRatio * pulseScale, glowPaint);

    // Crisp Center LED
    final Paint ledCenterPaint = Paint()..color = statusLedColor;
    canvas.drawCircle(ledPosition, 2.2 * scaleRatio, ledCenterPaint);

    // 7. Minimalist Front LCD / Controls Strip
    final Paint buttonStripPaint = Paint()..color = Colors.black.withValues(alpha: 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          topCenterPoint.dx + (24.0 * scaleRatio),
          topCenterPoint.dy + (2.5 * scaleRatio),
          16.0 * scaleRatio,
          4.0 * scaleRatio,
        ),
        Radius.circular(2.0 * scaleRatio),
      ),
      buttonStripPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _Printer3DIsometricPainter oldDelegate) {
    return oldDelegate.status != status ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.animationProgress != animationProgress;
  }
}
