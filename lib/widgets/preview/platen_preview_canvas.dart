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
                      widthFactor: (resolved.widthMm /
                              PlatenGeometryHelper.platenWidthMm)
                          .clamp(0.38, 0.94),
                      heightFactor: (resolved.heightMm /
                              PlatenGeometryHelper.platenHeightMm)
                          .clamp(0.38, 0.94),
                      child: Container(
                        decoration: BoxDecoration(
                          color: DesignTokens.pureWhite,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              offset: const Offset(0, 6),
                              blurRadius: 18,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFDDDDDD),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    titlePaperName,
                                    style: const TextStyle(
                                      color: DesignTokens.onyx,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${resolved.widthMm.toStringAsFixed(0)} × ${resolved.heightMm.toStringAsFixed(0)} mm',
                                    style: const TextStyle(
                                      color: DesignTokens.neutralGrayEightHundred,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
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
}

class _PlatenGlassGridPainter extends CustomPainter {
  const _PlatenGlassGridPainter({required this.markerColor});

  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = markerColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double markerLength = 12.0;
    const double pad = 4.0;

    // Top-Left L-bracket
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + markerLength, pad), paint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + markerLength), paint);

    // Top-Right L-bracket
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - markerLength, pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + markerLength),
      paint,
    );

    // Bottom-Left L-bracket
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + markerLength, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - markerLength),
      paint,
    );

    // Bottom-Right L-bracket
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - markerLength, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - markerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlatenGlassGridPainter oldDelegate) =>
      oldDelegate.markerColor != markerColor;
}
