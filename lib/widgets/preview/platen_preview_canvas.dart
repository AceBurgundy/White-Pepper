// DPI = Dots Per Inch
// RGB = Red Green Blue
// CMYK = Cyan Magenta Yellow Key
// B&W = Black and White

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'platen_geometry_helper.dart';

/// Minimalized Optical Platen Preview Canvas with widened glass bed & corner markers.
class PlatenPreviewCanvas extends StatelessWidget {
  const PlatenPreviewCanvas({
    required this.paperPreset,
    required this.dpi,
    this.rotation = 0,
    this.customWidth = 210.0,
    this.customHeight = 297.0,
    this.units = 'mm',
    this.fileNamePrefix = '',
    this.colorMode = 'color',
    this.format = 'png',
    this.isDarkMode = false,
    this.autoCrop = false,
    this.marginMm = 0.0,
    this.brightness = 0,
    this.contrast = 0,
    super.key,
  });

  final String paperPreset;
  final int dpi;
  final int rotation;
  final double customWidth;
  final double customHeight;
  final String units;
  final String fileNamePrefix;
  final String colorMode;
  final String format;
  final bool isDarkMode;
  final bool autoCrop;
  final double marginMm;
  final int brightness;
  final int contrast;

  /// Formats paper preset tokens in Title Case (Capital First Letter Every Word).
  static String formatPaperTitle(String raw) {
    if (raw.isEmpty) return '';
    final List<String> parts = raw.split(RegExp(r'[-_ ]+'));
    return parts.map((String part) {
      if (part.isEmpty) return '';
      final String lower = part.toLowerCase();
      if (lower == 'bw') return 'B&W';
      if (lower == 'id') return 'ID';
      if (lower == 'pdf') return 'PDF';
      if (lower == 'dpi') return 'DPI';
      if (RegExp(r'^[ab]\d+$', caseSensitive: false).hasMatch(part)) {
        return part.toUpperCase();
      }
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final String effectivePreset = paperPreset == 'auto' ? 'a4' : paperPreset;
    final PlatenPaperDimensions resolved = PlatenGeometryHelper.resolveDimensions(
      effectivePreset,
      customWidth: customWidth,
      customHeight: customHeight,
      units: units,
    );

    final int effectiveDpi = dpi <= 0 ? 300 : dpi;
    final String titlePaperName = formatPaperTitle(resolved.name);

    final Color glassSurfaceColor = isDarkMode
        ? const Color(0xFF1E1E22)
        : const Color(0xFFF4F4F6);
    final Color glassBorderColor = isDarkMode
        ? const Color(0xFF333338)
        : const Color(0xFFDDDDDF);
    final Color markerColor = isDarkMode
        ? const Color(0xFF55555C)
        : const Color(0xFFAAAAAF);
    final Color textColor = isDarkMode
        ? DesignTokens.pureWhite
        : DesignTokens.onyx;
    final Color subtextColor = isDarkMode
        ? DesignTokens.neutralGrayFiveHundred
        : DesignTokens.neutralGraySevenHundred;

    final Color paperSurfaceColor = switch (colorMode) {
      'bw' => Colors.white,
      'grayscale' => const Color(0xFFE8E9EC),
      _ => DesignTokens.pureWhite,
    };
    final Color paperBorderColor = switch (colorMode) {
      'bw' => Colors.black,
      'grayscale' => const Color(0xFFBCBCC0),
      _ => const Color(0xFFDDDDDD),
    };
    final Color paperTextColor = switch (colorMode) {
      'bw' => Colors.black,
      'grayscale' => const Color(0xFF222226),
      _ => DesignTokens.onyx,
    };
    final Color paperSubtextColor = switch (colorMode) {
      'bw' => const Color(0xFF111111),
      'grayscale' => const Color(0xFF55555A),
      _ => DesignTokens.neutralGrayEightHundred,
    };

    final double baseWidthFactor = effectivePreset == 'full'
        ? 0.92
        : ((resolved.widthMm / PlatenGeometryHelper.platenWidthMm) * 0.92).clamp(0.24, 0.92);
    final double baseHeightFactor = effectivePreset == 'full'
        ? 0.92
        : ((resolved.heightMm / 328.0) * 0.92).clamp(0.24, 0.92);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: glassSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorderColor, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          // Minimal Top Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: DesignTokens.statusOnlineGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OPTICAL PLATEN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? DesignTokens.darkSurfaceFour
                      : DesignTokens.neutralGrayOneHundred,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                ),
                child: Text(
                  '$effectiveDpi DPI',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Central Platen Glass Bed with Corner Markers and Proportional Paper Sheet
          Expanded(
            child: Stack(
              children: <Widget>[
                // Corner Alignment Markers
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PlatenGlassGridPainter(markerColor: markerColor),
                  ),
                ),

                // Proportional Sheet
                Center(
                  child: Transform.rotate(
                    angle: rotation * (math.pi / 180.0),
                    child: FractionallySizedBox(
                      widthFactor: baseWidthFactor,
                      heightFactor: baseHeightFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: paperSurfaceColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              offset: const Offset(0, 6),
                              blurRadius: 18,
                            ),
                          ],
                          border: Border.all(
                            color: paperBorderColor,
                            width: colorMode == 'bw' ? 1.5 : 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(
                            children: <Widget>[
                              // 1. DPI Checkered Density Pattern
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _PaperDpiCheckeredPainter(
                                    dpi: effectiveDpi,
                                    colorMode: colorMode,
                                  ),
                                ),
                              ),

                              // 2. Crop Margins & Inset Boundary
                              if (autoCrop || marginMm > 0.0)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _PaperCropMarginsPainter(
                                      marginMm: marginMm,
                                      autoCrop: autoCrop,
                                      colorMode: colorMode,
                                    ),
                                  ),
                                ),

                              // 3. Central Document Content with Color Mode Swatches
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          titlePaperName,
                                          style: TextStyle(
                                            color: paperTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${resolved.widthMm.toStringAsFixed(0)} × ${resolved.heightMm.toStringAsFixed(0)} mm',
                                          style: TextStyle(
                                            color: paperSubtextColor,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      _buildColorModeStrip(colorMode),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Minimal Resolution & Dimensions Footnote
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  '${resolved.pixelWidth(effectiveDpi)} × ${resolved.pixelHeight(effectiveDpi)} px',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${resolved.widthInches.toStringAsFixed(2)}" × ${resolved.heightInches.toStringAsFixed(2)}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorModeStrip(String mode) {
    final List<Color> swatchColors = switch (mode) {
      'bw' => const <Color>[
          Colors.black,
          Colors.white,
          Colors.black,
          Colors.white,
        ],
      'grayscale' => const <Color>[
          Color(0xFF222222),
          Color(0xFF666666),
          Color(0xFFAAAAAA),
          Color(0xFFE0E0E0),
        ],
      _ => const <Color>[
          DesignTokens.inkCyan,
          DesignTokens.inkMagenta,
          DesignTokens.inkYellow,
          DesignTokens.onyx,
        ],
    };

    final String modeBadgeText = switch (mode) {
      'bw' => '1-BIT B&W',
      'grayscale' => 'GRAYSCALE',
      _ => 'RGB COLOR',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: swatchColors.map((Color swatchColor) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 12,
              height: 5,
              decoration: BoxDecoration(
                color: swatchColor,
                borderRadius: BorderRadius.circular(1.5),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 3),
        Text(
          modeBadgeText,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

/// Painter rendering real-time DPI checkered boxes across the paper sheet.
class _PaperDpiCheckeredPainter extends CustomPainter {
  const _PaperDpiCheckeredPainter({
    required this.dpi,
    required this.colorMode,
  });

  final int dpi;
  final String colorMode;

  @override
  void paint(Canvas canvas, Size size) {
    // Cell size inversely proportional to DPI (higher DPI = more/smaller boxes)
    final double cellSize = (2400.0 / dpi.clamp(75, 1200)).clamp(3.0, 24.0);

    final double width = size.width;
    final double height = size.height;

    final Paint checkeredPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = switch (colorMode) {
        'bw' => Colors.black.withValues(alpha: 0.09),
        'grayscale' => const Color(0xFF000000).withValues(alpha: 0.05),
        _ => const Color(0xFF000000).withValues(alpha: 0.035),
      };

    final int columnCount = (width / cellSize).ceil();
    final int rowCount = (height / cellSize).ceil();

    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
        if ((columnIndex + rowIndex) % 2 == 1) {
          final double squareLeft = columnIndex * cellSize;
          final double squareTop = rowIndex * cellSize;
          final double squareRight = math.min(squareLeft + cellSize, width);
          final double squareBottom = math.min(squareTop + cellSize, height);
          canvas.drawRect(
            Rect.fromLTRB(squareLeft, squareTop, squareRight, squareBottom),
            checkeredPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperDpiCheckeredPainter oldDelegate) {
    return oldDelegate.dpi != dpi || oldDelegate.colorMode != colorMode;
  }
}

/// Painter rendering visual margin lines and corner crop brackets.
class _PaperCropMarginsPainter extends CustomPainter {
  const _PaperCropMarginsPainter({
    required this.marginMm,
    required this.autoCrop,
    required this.colorMode,
  });

  final double marginMm;
  final bool autoCrop;
  final String colorMode;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double visualInset = (marginMm > 0.0)
        ? (marginMm * 2.2).clamp(6.0, 28.0)
        : (autoCrop ? 12.0 : 0.0);

    if (visualInset <= 0.0) return;

    final Color cropColor = switch (colorMode) {
      'bw' => Colors.black,
      'grayscale' => const Color(0xFF444444),
      _ => autoCrop ? const Color(0xFF10B981) : const Color(0xFF0284C7),
    };

    final Paint boundaryPaint = Paint()
      ..color = cropColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw dashed crop boundary lines
    const double dashLength = 5.0;
    const double dashSpacing = 4.0;

    double currentCoordinateX = visualInset;
    while (currentCoordinateX < width - visualInset) {
      final double endCoordinateX = math.min(currentCoordinateX + dashLength, width - visualInset);
      canvas.drawLine(
        Offset(currentCoordinateX, visualInset),
        Offset(endCoordinateX, visualInset),
        boundaryPaint,
      );
      canvas.drawLine(
        Offset(currentCoordinateX, height - visualInset),
        Offset(endCoordinateX, height - visualInset),
        boundaryPaint,
      );
      currentCoordinateX += dashLength + dashSpacing;
    }

    double currentCoordinateY = visualInset;
    while (currentCoordinateY < height - visualInset) {
      final double endCoordinateY = math.min(currentCoordinateY + dashLength, height - visualInset);
      canvas.drawLine(
        Offset(visualInset, currentCoordinateY),
        Offset(visualInset, endCoordinateY),
        boundaryPaint,
      );
      canvas.drawLine(
        Offset(width - visualInset, currentCoordinateY),
        Offset(width - visualInset, endCoordinateY),
        boundaryPaint,
      );
      currentCoordinateY += dashLength + dashSpacing;
    }

    // Corner L crop marks
    const double tickLength = 7.0;
    final Paint tickPaint = Paint()
      ..color = cropColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Top-left corner
    canvas.drawLine(
      Offset(visualInset - 2, visualInset),
      Offset(visualInset + tickLength, visualInset),
      tickPaint,
    );
    canvas.drawLine(
      Offset(visualInset, visualInset - 2),
      Offset(visualInset, visualInset + tickLength),
      tickPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(width - visualInset + 2, visualInset),
      Offset(width - visualInset - tickLength, visualInset),
      tickPaint,
    );
    canvas.drawLine(
      Offset(width - visualInset, visualInset - 2),
      Offset(width - visualInset, visualInset + tickLength),
      tickPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(visualInset - 2, height - visualInset),
      Offset(visualInset + tickLength, height - visualInset),
      tickPaint,
    );
    canvas.drawLine(
      Offset(visualInset, height - visualInset + 2),
      Offset(visualInset, height - visualInset - tickLength),
      tickPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(width - visualInset + 2, height - visualInset),
      Offset(width - visualInset - tickLength, height - visualInset),
      tickPaint,
    );
    canvas.drawLine(
      Offset(width - visualInset, height - visualInset + 2),
      Offset(width - visualInset, height - visualInset - tickLength),
      tickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PaperCropMarginsPainter oldDelegate) {
    return oldDelegate.marginMm != marginMm ||
        oldDelegate.autoCrop != autoCrop ||
        oldDelegate.colorMode != colorMode;
  }
}

class _PlatenGlassGridPainter extends CustomPainter {
  const _PlatenGlassGridPainter({required this.markerColor});

  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint markerPaint = Paint()
      ..color = markerColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double markerLength = 12.0;
    const double paddingOffset = 4.0;

    // Top-Left L-bracket
    canvas.drawLine(
      const Offset(paddingOffset, paddingOffset),
      const Offset(paddingOffset + markerLength, paddingOffset),
      markerPaint,
    );
    canvas.drawLine(
      const Offset(paddingOffset, paddingOffset),
      const Offset(paddingOffset, paddingOffset + markerLength),
      markerPaint,
    );

    // Top-Right L-bracket
    canvas.drawLine(
      Offset(size.width - paddingOffset, paddingOffset),
      Offset(size.width - paddingOffset - markerLength, paddingOffset),
      markerPaint,
    );
    canvas.drawLine(
      Offset(size.width - paddingOffset, paddingOffset),
      Offset(size.width - paddingOffset, paddingOffset + markerLength),
      markerPaint,
    );

    // Bottom-Left L-bracket
    canvas.drawLine(
      Offset(paddingOffset, size.height - paddingOffset),
      Offset(paddingOffset + markerLength, size.height - paddingOffset),
      markerPaint,
    );
    canvas.drawLine(
      Offset(paddingOffset, size.height - paddingOffset),
      Offset(paddingOffset, size.height - paddingOffset - markerLength),
      markerPaint,
    );

    // Bottom-Right L-bracket
    canvas.drawLine(
      Offset(size.width - paddingOffset, size.height - paddingOffset),
      Offset(size.width - paddingOffset - markerLength, size.height - paddingOffset),
      markerPaint,
    );
    canvas.drawLine(
      Offset(size.width - paddingOffset, size.height - paddingOffset),
      Offset(size.width - paddingOffset, size.height - paddingOffset - markerLength),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlatenGlassGridPainter oldDelegate) =>
      oldDelegate.markerColor != markerColor;
}
