import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';
import '../../models/scan_configuration_model.dart';

/// Dark #2D2D2D parameter adjustment drawer matching DesktopMockup.js lines 591–620.
class PeaPodDrawer extends StatelessWidget {
  const PeaPodDrawer({
    required this.selectedTool,
    required this.config,
    required this.onConfigChanged,
    super.key,
  });

  final PeaPodToolType selectedTool;
  final ScanConfigurationModel config;
  final ValueChanged<ScanConfigurationModel> onConfigChanged;

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.accentYellow
              : DesignTokens.darkSurfaceFive,
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          border: Border.all(
            color: isSelected
                ? DesignTokens.accentYellow
                : DesignTokens.darkSurfaceSix,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? DesignTokens.onyx : DesignTokens.pureWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader({
    required String title,
    required String badgeValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDDDDDD),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: DesignTokens.accentYellow,
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
          child: Text(
            badgeValue,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: DesignTokens.onyx,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYellowSlider({
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: DesignTokens.accentYellow,
        inactiveTrackColor: DesignTokens.neutralGrayNineHundred,
        thumbColor: DesignTokens.accentYellow,
        overlayColor: DesignTokens.accentYellow.withValues(alpha: 0.16),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLayoutControls() {
    if (config.workflowType == WorkflowType.compilePdf) {
      const List<String> pdfPresets = <String>[
        'auto',
        'a4',
        'letter',
        'legal',
        'a5',
        'b5',
        'photo-4x6',
        'id-card',
        'full',
      ];
      const List<String> fitModes = <String>[
        'contain',
        'fill',
        'stretch',
        'original',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            title: 'Virtual Paper Size & Fit Mode (--paper-size / --fit-mode)',
            badgeValue: '${config.paperSize.toUpperCase()} • ${config.fitMode.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: pdfPresets.map((String preset) {
              return _buildChip(
                label: preset.toUpperCase(),
                isSelected: config.paperSize == preset,
                onTap: () {
                  config.paperSize = preset;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fit Mode (--fit-mode)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrayFiveHundred,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: fitModes.map((String mode) {
              return _buildChip(
                label: mode.toUpperCase(),
                isSelected: config.fitMode == mode,
                onTap: () {
                  config.fitMode = mode;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
        ],
      );
    }

    const List<String> paperPresets = <String>[
      'a4',
      'letter',
      'legal',
      'a5',
      'a6',
      'b5',
      'executive',
      'statement',
      'photo-4x6',
      'photo-5x7',
      'index-3x5',
      'id-card',
      'receipt-half',
      'full',
      'custom',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Platen Paper Size Preset (--paper-size)',
          badgeValue: config.paperSize.toUpperCase(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: paperPresets.map((String preset) {
            return _buildChip(
              label: preset.toUpperCase(),
              isSelected: config.paperSize == preset,
              onTap: () {
                config.paperSize = preset;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
        if (config.paperSize == 'custom') ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Width: ${config.customWidth.toStringAsFixed(0)} ${config.units}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.customWidth,
                      min: 20,
                      max: 216,
                      onChanged: (double v) {
                        config.customWidth = v;
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Height: ${config.customHeight.toStringAsFixed(0)} ${config.units}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.customHeight,
                      min: 20,
                      max: 297,
                      onChanged: (double v) {
                        config.customHeight = v;
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTuneControls() {
    if (config.workflowType == WorkflowType.compilePdf) {
      const List<int> pdfDpiOptions = <int>[0, 150, 300, 600, 1200];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            title: 'PDF Resolution (--resolution)',
            badgeValue: config.dpi == 0 ? 'AUTO (METADATA)' : '${config.dpi} DPI',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pdfDpiOptions.map((int val) {
              return _buildChip(
                label: val == 0 ? 'AUTO (EMBEDDED DPI)' : '$val DPI',
                isSelected: config.dpi == val,
                onTap: () {
                  config.dpi = val;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
        ],
      );
    }

    const List<int> dpis = <int>[75, 100, 200, 300, 600, 1200];
    final int currentIdx = dpis.indexOf(config.dpi).clamp(0, dpis.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Optical Scan Resolution (--dpi)',
          badgeValue: '${config.dpi} DPI',
        ),
        const SizedBox(height: 8),
        _buildYellowSlider(
          value: currentIdx.toDouble(),
          min: 0,
          max: (dpis.length - 1).toDouble(),
          divisions: dpis.length - 1,
          onChanged: (double indexValue) {
            config.dpi = dpis[indexValue.round()];
            onConfigChanged(config);
          },
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dpis.map((int dpiValue) {
            return _buildChip(
              label: '$dpiValue DPI',
              isSelected: config.dpi == dpiValue,
              onTap: () {
                config.dpi = dpiValue;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRotateControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Post-Scan Clockwise Rotation (--rotate)',
          badgeValue: '${config.rotation}°',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: const <int>[0, 90, 180, 270].map((int deg) {
            return _buildChip(
              label: '$deg°',
              isSelected: config.rotation == deg,
              onTap: () {
                config.rotation = deg;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContrastControls() {
    final bool supportsToneSliders = config.workflowType == WorkflowType.flatbed ||
        config.workflowType == WorkflowType.photoScan ||
        config.workflowType == WorkflowType.receiptArchive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Color Mode & Exposure (--color-mode)',
          badgeValue: config.colorMode.toUpperCase(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: const <String>['color', 'grayscale', 'bw'].map((String mode) {
            return _buildChip(
              label: mode.toUpperCase(),
              isSelected: config.colorMode == mode,
              onTap: () {
                config.colorMode = mode;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
        if (supportsToneSliders) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Brightness (--brightness): ${config.brightness}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.brightness.toDouble(),
                      min: -100,
                      max: 100,
                      onChanged: (double val) {
                        config.brightness = val.round();
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Contrast (--contrast): ${config.contrast}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.contrast.toDouble(),
                      min: -100,
                      max: 100,
                      onChanged: (double val) {
                        config.contrast = val.round();
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCropControls() {
    // Card-specific geometry controls
    if (config.workflowType == WorkflowType.cardDuplex ||
        config.workflowType == WorkflowType.batchCardDeskew) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            title: 'ID-1 Card Vision Geometry',
            badgeValue:
                'Inset ${config.safetyInsetMm.toStringAsFixed(1)}mm • R${config.cornerRadiusMm.toStringAsFixed(1)}mm',
          ),
          const SizedBox(height: 10),
          if (config.workflowType == WorkflowType.cardDuplex) ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _buildChip(
                  label: 'DUPLEX (FRONT + BACK)',
                  isSelected: config.cardDuplexTwoSided,
                  onTap: () {
                    config.cardDuplexTwoSided = true;
                    onConfigChanged(config);
                  },
                ),
                _buildChip(
                  label: 'SINGLE SIDE ONLY',
                  isSelected: !config.cardDuplexTwoSided,
                  onTap: () {
                    config.cardDuplexTwoSided = false;
                    onConfigChanged(config);
                  },
                ),
                _buildChip(
                  label: config.noDeskew ? 'RAW 5x5" (--no-deskew)' : 'AUTO CV DESKEW',
                  isSelected: !config.noDeskew,
                  onTap: () {
                    config.noDeskew = !config.noDeskew;
                    onConfigChanged(config);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            children: const <String>['transparent', 'white', 'black'].map((String bg) {
              return _buildChip(
                label: 'BG: ${bg.toUpperCase()}',
                isSelected: config.cardBackground == bg,
                onTap: () {
                  config.cardBackground = bg;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Safety Inset: ${config.safetyInsetMm.toStringAsFixed(1)} mm',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.safetyInsetMm,
                      min: 0.0,
                      max: 3.0,
                      divisions: 30,
                      onChanged: (double v) {
                        config.safetyInsetMm = double.parse(v.toStringAsFixed(1));
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Corner Radius: ${config.cornerRadiusMm.toStringAsFixed(2)} mm',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.cornerRadiusMm,
                      min: 0.0,
                      max: 6.0,
                      divisions: 60,
                      onChanged: (double v) {
                        config.cornerRadiusMm = double.parse(v.toStringAsFixed(2));
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Booklet interval & max-scans controls
    if (config.workflowType == WorkflowType.bookletBatch) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            title: 'Booklet Batch Timing (--interval / --max-scans)',
            badgeValue:
                '${config.intervalSeconds}s • ${config.maxScans == 0 ? "UNLIMITED" : "${config.maxScans} SPREADS"}',
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Countdown Interval: ${config.intervalSeconds}s',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.intervalSeconds.toDouble(),
                      min: 2,
                      max: 45,
                      divisions: 43,
                      onChanged: (double v) {
                        config.intervalSeconds = v.round();
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Max Spreads (0=Unlimited): ${config.maxScans}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.neutralGrayFourHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      value: config.maxScans.toDouble(),
                      min: 0,
                      max: 40,
                      divisions: 40,
                      onChanged: (double v) {
                        config.maxScans = v.round();
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Compile PDF margin bleed control
    if (config.workflowType == WorkflowType.compilePdf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            title: 'Page Margin Bleed (--margin-mm)',
            badgeValue: '${config.marginMm.toStringAsFixed(1)} mm',
          ),
          const SizedBox(height: 8),
          _buildYellowSlider(
            value: config.marginMm,
            min: 0.0,
            max: 25.0,
            divisions: 50,
            onChanged: (double v) {
              config.marginMm = double.parse(v.toStringAsFixed(1));
              onConfigChanged(config);
            },
          ),
        ],
      );
    }

    // Standard auto-crop whitespace toggle
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Automatic Whitespace Trimming (--auto-crop)',
          badgeValue: config.autoCrop ? 'ENABLED' : 'OFF',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: <Widget>[
            _buildChip(
              label: 'FULL REGION (NO AUTO-CROP)',
              isSelected: !config.autoCrop,
              onTap: () {
                config.autoCrop = false;
                onConfigChanged(config);
              },
            ),
            _buildChip(
              label: 'TRIM BORDERS (--auto-crop)',
              isSelected: config.autoCrop,
              onTap: () {
                config.autoCrop = true;
                onConfigChanged(config);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleControls() {
    final List<String> allowedFormats;
    switch (config.workflowType) {
      case WorkflowType.legalStitch:
        allowedFormats = const <String>['pdf', 'png'];
      case WorkflowType.cardDuplex:
      case WorkflowType.batchCardDeskew:
        allowedFormats = const <String>['png', 'jpg', 'tiff', 'bmp'];
      case WorkflowType.compilePdf:
        allowedFormats = const <String>['pdf'];
      case WorkflowType.flatbed:
      case WorkflowType.bookletBatch:
      case WorkflowType.receiptArchive:
      case WorkflowType.photoScan:
        allowedFormats = const <String>['pdf', 'png', 'jpg', 'tiff', 'bmp'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          title: 'Output Format & Filename Prefix (--format / --prefix)',
          badgeValue: '.${config.format.toUpperCase()}',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allowedFormats.map((String fmt) {
            return _buildChip(
              label: fmt.toUpperCase(),
              isSelected: config.format == fmt,
              onTap: () {
                config.format = fmt;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: TextEditingController(text: config.fileNamePrefix)
                  ..selection = TextSelection.collapsed(
                    offset: config.fileNamePrefix.length,
                  ),
                onChanged: (String val) {
                  config.fileNamePrefix = val;
                  onConfigChanged(config);
                },
                style: const TextStyle(
                  fontSize: 13,
                  color: DesignTokens.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Filename Prefix (--prefix / --name)',
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.neutralGrayFiveHundred,
                  ),
                  hintText: 'e.g. SCAN_BATCH_2026 or National_ID',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGraySixHundred,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: DesignTokens.onyx,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: DesignTokens.darkSurfaceSix,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: DesignTokens.accentYellow,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: config.outputDirectory)
                  ..selection = TextSelection.collapsed(
                    offset: config.outputDirectory.length,
                  ),
                onChanged: (String val) {
                  config.outputDirectory = val;
                  onConfigChanged(config);
                },
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignTokens.pureWhite,
                  fontFamily: 'Consolas',
                ),
                decoration: InputDecoration(
                  labelText: 'Target Directory (--output-dir)',
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.neutralGrayFiveHundred,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: DesignTokens.onyx,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: DesignTokens.darkSurfaceSix,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: DesignTokens.accentYellow,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: DesignTokens.darkSurfaceTwo,
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: DesignTokens.darkSurfaceSix),
      ),
      child: switch (selectedTool) {
        PeaPodToolType.layout => _buildLayoutControls(),
        PeaPodToolType.tune => _buildTuneControls(),
        PeaPodToolType.rotate => _buildRotateControls(),
        PeaPodToolType.contrast => _buildContrastControls(),
        PeaPodToolType.crop => _buildCropControls(),
        PeaPodToolType.title => _buildTitleControls(),
      },
    );
  }
}
