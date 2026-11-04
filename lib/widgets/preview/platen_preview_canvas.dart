import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'platen_geometry_helper.dart';

/// Replicates the 3D Printer Pill + Paper Sheet & Platen Preview from DesktopMockup.js (lines 543–569)
class PlatenPreviewCanvas extends StatelessWidget {
  const PlatenPreviewCanvas({
    required this.paperPreset,
    required this.dpi,
    this.rotation = 0,
    this.customWidth = 210.0,
    this.customHeight = 297.0,
    this.fileNamePrefix = '',
    this.colorMode = 'color',
    this.format = 'png',
    super.key,
  });

  final String paperPreset;
  final int dpi;
  final int rotation;
  final double customWidth;
  final double customHeight;
  final String fileNamePrefix;
  final String colorMode;
  final String format;

  @override
  Widget build(BuildContext context) {
    final String effectivePreset = paperPreset == 'auto' ? 'a4' : paperPreset;
    final PlatenPaperDimensions resolved = PlatenGeometryHelper.resolveDimensions(
      effectivePreset,
      customWidth: customWidth,
      customHeight: customHeight,
    );

    final int effectiveDpi = dpi <= 0 ? 300 : dpi;
    final bool isExceedingPlaten =
        resolved.heightMm > PlatenGeometryHelper.platenHeightMm ||
            resolved.widthMm > PlatenGeometryHelper.platenWidthMm;

    final String captionText = fileNamePrefix.trim().isNotEmpty
        ? fileNamePrefix.trim().toUpperCase()
        : 'SCAN_BATCH_2026';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // 3D Printer Pill Capsule (260px x 58px, gradient #FFFFFF -> #D8D8D8)
        Container(
          width: 268,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFFFFFFF),
                Color(0xFFD8D8D8),
              ],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x59000000),
                offset: Offset(0, 12),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBBBBBB),
                    width: 1.5,
                  ),
                ),
              ),
              Text(
                isExceedingPlaten ? '2-PASS PLATEN' : 'OPTICAL PLATEN',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.neutralGraySevenHundred,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: DesignTokens.accentYellow,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: DesignTokens.accentYellow,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Paper Sheet emerging underneath (-10px overlap)
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              width: 232,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              decoration: const BoxDecoration(
                color: DesignTokens.pureWhite,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  // Pink/Tinted Platen Preview Frame (from DesktopMockup.js)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D1DC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: Transform.rotate(
                                angle: rotation * (math.pi / 180.0),
                                child: FractionallySizedBox(
                                  widthFactor: (resolved.widthMm /
                                          PlatenGeometryHelper.platenWidthMm)
                                      .clamp(0.42, 1.0),
                                  heightFactor: (resolved.heightMm /
                                          PlatenGeometryHelper.platenHeightMm)
                                      .clamp(0.42, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      gradient: colorMode == 'grayscale' ||
                                              colorMode == 'bw'
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: <Color>[
                                                Color(0xFF777777),
                                                Color(0xFF333333),
                                              ],
                                            )
                                          : const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: <Color>[
                                                Color(0xFF2EC4B6),
                                                Color(0xFFFF9F1C),
                                                Color(0xFFE71D36),
                                              ],
                                            ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.55),
                                            borderRadius: BorderRadius.circular(
                                              DesignTokens.radiusPill,
                                            ),
                                          ),
                                          child: Text(
                                            '${resolved.name.toUpperCase()} • ${dpi <= 0 ? "AUTO" : "$dpi"} DPI',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: DesignTokens.pureWhite,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$captionText.${format.toUpperCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.onyx,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Dimensions / Pixel Matrix Readout Slot
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '${resolved.pixelWidth(effectiveDpi)} × ${resolved.pixelHeight(effectiveDpi)} px',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.onyx,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${resolved.widthMm.toStringAsFixed(1)}×${resolved.heightMm.toStringAsFixed(1)} mm (${resolved.widthInches.toStringAsFixed(2)}"×${resolved.heightInches.toStringAsFixed(2)}")',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.neutralGraySevenHundred,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
