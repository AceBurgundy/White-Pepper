import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';
import '../../models/scan_configuration_model.dart';

/// Parameter adjustment drawer without enclosing background container (sibling of PeaPod).
class PeaPodDrawer extends StatefulWidget {
  const PeaPodDrawer({
    required this.selectedTool,
    required this.config,
    required this.onConfigChanged,
    this.isDarkMode = false,
    super.key,
  });

  final PeaPodToolType selectedTool;
  final ScanConfigurationModel config;
  final ValueChanged<ScanConfigurationModel> onConfigChanged;
  final bool isDarkMode;

  /// Formats raw preset tokens into Title Case (Capital First Letter Every Word).
  static String formatPresetTitle(String raw) {
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
  State<PeaPodDrawer> createState() => _PeaPodDrawerState();
}

class _PeaPodDrawerState extends State<PeaPodDrawer> {
  late final TextEditingController _prefixController;
  late final TextEditingController _outputDirectoryController;

  ScanConfigurationModel get config => widget.config;
  ValueChanged<ScanConfigurationModel> get onConfigChanged =>
      widget.onConfigChanged;
  PeaPodToolType get selectedTool => widget.selectedTool;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController(text: widget.config.fileNamePrefix);
    _outputDirectoryController = TextEditingController(text: widget.config.outputDirectory);
  }

  @override
  void didUpdateWidget(covariant PeaPodDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.fileNamePrefix != _prefixController.text) {
      _prefixController.value = TextEditingValue(
        text: widget.config.fileNamePrefix,
        selection: TextSelection.collapsed(
          offset: widget.config.fileNamePrefix.length,
        ),
      );
    }
    if (widget.config.outputDirectory != _outputDirectoryController.text) {
      _outputDirectoryController.value = TextEditingValue(
        text: widget.config.outputDirectory,
        selection: TextSelection.collapsed(
          offset: widget.config.outputDirectory.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _outputDirectoryController.dispose();
    super.dispose();
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.accentYellow
              : (isDark ? DesignTokens.darkSurfaceFive : DesignTokens.pureWhite),
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          border: Border.all(
            color: isSelected
                ? DesignTokens.accentYellow
                : (isDark ? DesignTokens.darkSurfaceSix : DesignTokens.neutralGrayThreeHundred),
          ),
          boxShadow: !isDark && !isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? DesignTokens.onyx
                : (isDark ? DesignTokens.pureWhite : DesignTokens.onyx),
          ),
        ),
      ),
    );
  }

  String _resolveHeaderTooltip(String sectionTitle) {
    return switch (sectionTitle) {
      'Multi-Page Scan Timer' =>
        'Automatically triggers subsequent scans after a countdown interval, allowing hands-free document feeds.',
      'Paper Size & Presets' || 'Scanner Paper Size' =>
        'Standardized document dimensions and flatbed platen coverage presets.',
      'Document Page Size & Fit Mode' =>
        'Target PDF sheet dimensions and how scans are scaled or stretched onto the page.',
      'ID Card Sizing & Preset' =>
        'Pre-calibrated bounding profiles for standard driver licenses, national IDs, and badges.',
      'Duplex Card Placement' =>
        'Configures front and back side registration alignment on the scanner platen glass.',
      'Booklet Splitter Orientation' =>
        'Splits folded booklet scans along the centerline vertically or horizontally into ordered pages.',
      'Legal Dual-Pass Stitcher' =>
        'Merges two overlapping scans into an aligned, seamless 14-inch legal document.',
      'Optical DPI Resolution' =>
        'Hardware optical sensor sampling density. Higher DPI captures finer detail at larger file sizes.',
      'Color Mode & Tone' =>
        'Select 24-bit full color, 8-bit grayscale, or 1-bit high-contrast black & white.',
      'Brightness Adjustment' =>
        'Lightens or darkens raw optical sensor exposures to correct under- or over-exposed media.',
      'Contrast Adjustment' =>
        'Accentuates separation between light backgrounds and dark text to maximize legibility.',
      'Scan Dimensions & Units' =>
        'Custom width, height, and offset margins in inches or millimeters.',
      'Hardware Rotation' =>
        'Applies 90°, 180°, or 270° clockwise hardware rotation directly at capture time.',
      'Fit Mode' =>
        'Determines how scanned pages are framed and scaled on the output virtual sheet.',
      'File Name' =>
        'Custom base name for the saved scan. Leave empty to use standard automated naming.',
      'PDF Document Name' =>
        'Custom base name for the compiled multi-page PDF document.',
      'Output File Name' =>
        'Specify a custom name for the saved file. Leave empty to use auto-generated naming.',
      _ => 'Configure settings and parameters for this scan workflow.',
    };
  }

  Widget _buildInfoIcon({
    required String tooltip,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 100),
      showDuration: const Duration(seconds: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurfaceSix : DesignTokens.onyx,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      textStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: DesignTokens.pureWhite,
        height: 1.3,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? DesignTokens.darkSurfaceFour
                : DesignTokens.pureWhite,
            border: Border.all(
              color: isDark
                  ? DesignTokens.neutralGraySixHundred
                  : DesignTokens.neutralGrayThreeHundred,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              'i',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                color: isDark
                    ? DesignTokens.neutralGrayThreeHundred
                    : DesignTokens.neutralGraySevenHundred,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader({
    required String title,
    required String badgeValue,
    required bool isDark,
    String? tooltip,
  }) {
    final String resolvedTooltip = tooltip ?? _resolveHeaderTooltip(title);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFDDDDDD) : DesignTokens.onyx,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildInfoIcon(
                tooltip: resolvedTooltip,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: DesignTokens.accentYellow,
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
          child: Text(
            badgeValue,
            style: const TextStyle(
              fontSize: 11.5,
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
    required bool isDark,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SliderTheme(
        data: SliderThemeData(
          mouseCursor: const WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
          trackHeight: 6,
          activeTrackColor: DesignTokens.accentYellow,
          inactiveTrackColor: isDark
              ? DesignTokens.neutralGrayNineHundred
              : DesignTokens.neutralGrayThreeHundred,
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
      ),
    );
  }

  Widget _buildLayoutControls(bool isDark) {
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
      const List<String> exportFormats = <String>[
        'pdf',
        'png',
        'jpg',
        'tiff',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Batch Output Format',
            badgeValue: '.${config.format.toUpperCase()}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exportFormats.map((String formatOption) {
              return _buildChip(
                isDark: isDark,
                label: formatOption.toUpperCase(),
                isSelected: config.format.toLowerCase() == formatOption,
                onTap: () {
                  config.format = formatOption;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Document Page Size & Fit Mode',
            badgeValue:
                '${PeaPodDrawer.formatPresetTitle(config.paperSize)} • ${PeaPodDrawer.formatPresetTitle(config.fitMode)}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: pdfPresets.map((String preset) {
              return _buildChip(
                isDark: isDark,
                label: PeaPodDrawer.formatPresetTitle(preset),
                isSelected: config.paperSize == preset,
                onTap: () {
                  config.paperSize = preset;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                'Fit Mode',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DesignTokens.neutralGrayFiveHundred
                      : DesignTokens.neutralGrayEightHundred,
                ),
              ),
              const SizedBox(width: 6),
              _buildInfoIcon(
                tooltip: _resolveHeaderTooltip('Fit Mode'),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: fitModes.map((String mode) {
              return _buildChip(
                isDark: isDark,
                label: PeaPodDrawer.formatPresetTitle(mode),
                isSelected: config.fitMode == mode,
                onTap: () {
                  config.fitMode = mode;
                  onConfigChanged(config);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Text(
                'Batch Output Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DesignTokens.neutralGrayFourHundred
                      : DesignTokens.neutralGrayEightHundred,
                ),
              ),
              const SizedBox(width: 6),
              _buildInfoIcon(
                tooltip: _resolveHeaderTooltip('PDF Document Name'),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _prefixController,
            onChanged: (String value) {
              config.fileNamePrefix = value;
              onConfigChanged(config);
            },
            style: TextStyle(
              fontSize: 13,
              color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Scanned_Batch or Tax_Invoices',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: DesignTokens.neutralGraySixHundred,
              ),
              suffixText: '.${config.format.toLowerCase()}',
              suffixStyle: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? DesignTokens.accentYellow : DesignTokens.onyx,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              filled: true,
              fillColor: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? DesignTokens.darkSurfaceSix
                      : DesignTokens.neutralGrayThreeHundred,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: DesignTokens.accentYellow,
                  width: 1.8,
                ),
              ),
            ),
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

    final String basicPresetLabel = (config.colorMode == 'bw' || config.colorMode == 'grayscale')
        ? 'Black & White'
        : (config.dpi >= 600 ? 'High Quality' : 'Quick Scan');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (config.workflowType == WorkflowType.flatbed) ...<Widget>[
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Basic Scan Preset',
            badgeValue: basicPresetLabel,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _buildChip(
                isDark: isDark,
                label: 'High Quality (600 DPI)',
                isSelected: config.dpi >= 600 && config.colorMode == 'color',
                onTap: () {
                  config.dpi = 600;
                  config.colorMode = 'color';
                  config.contrast = 0;
                  onConfigChanged(config);
                },
              ),
              _buildChip(
                isDark: isDark,
                label: 'Black & White (300 DPI)',
                isSelected: config.colorMode == 'bw' || config.colorMode == 'grayscale',
                onTap: () {
                  config.dpi = 300;
                  config.colorMode = 'bw';
                  config.contrast = 20;
                  onConfigChanged(config);
                },
              ),
              _buildChip(
                isDark: isDark,
                label: 'Quick Scan (300 DPI)',
                isSelected: config.dpi == 300 && config.colorMode == 'color',
                onTap: () {
                  config.dpi = 300;
                  config.colorMode = 'color';
                  config.contrast = 0;
                  onConfigChanged(config);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildDrawerHeader(
          isDark: isDark,
          title: 'Scanner Paper Size',
          badgeValue: PeaPodDrawer.formatPresetTitle(config.paperSize),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: paperPresets.map((String preset) {
            return _buildChip(
              isDark: isDark,
              label: PeaPodDrawer.formatPresetTitle(preset),
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
                      'Width: ${config.units == 'in' ? config.customWidth.toStringAsFixed(1) : config.customWidth.toStringAsFixed(0)} ${config.units}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.customWidth,
                      min: config.units == 'in' ? 1.0 : 20.0,
                      max: config.units == 'in' ? 8.5 : 216.0,
                      onChanged: (double sliderValue) {
                        config.customWidth = sliderValue;
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
                      'Height: ${config.units == 'in' ? config.customHeight.toStringAsFixed(1) : config.customHeight.toStringAsFixed(0)} ${config.units}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.customHeight,
                      min: config.units == 'in' ? 1.0 : 20.0,
                      max: config.units == 'in' ? 11.7 : 297.0,
                      onChanged: (double sliderValue) {
                        config.customHeight = sliderValue;
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Left Offset: ${config.units == 'in' ? config.offsetX.toStringAsFixed(1) : config.offsetX.toStringAsFixed(0)} ${config.units}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.offsetX,
                      min: 0.0,
                      max: config.units == 'in' ? 6.0 : 150.0,
                      onChanged: (double sliderValue) {
                        config.offsetX = sliderValue;
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
                      'Top Offset: ${config.units == 'in' ? config.offsetY.toStringAsFixed(1) : config.offsetY.toStringAsFixed(0)} ${config.units}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.offsetY,
                      min: 0.0,
                      max: config.units == 'in' ? 9.0 : 200.0,
                      onChanged: (double sliderValue) {
                        config.offsetY = sliderValue;
                        onConfigChanged(config);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        _buildFileNameSection(isDark),
      ],
    );
  }

  Widget _buildFileNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Text(
              'File Name',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DesignTokens.neutralGrayFourHundred
                    : DesignTokens.neutralGrayEightHundred,
              ),
            ),
            const SizedBox(width: 6),
            _buildInfoIcon(
              tooltip: _resolveHeaderTooltip('File Name'),
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _prefixController,
          onChanged: (String value) {
            config.fileNamePrefix = value;
            onConfigChanged(config);
          },
          style: TextStyle(
            fontSize: 13,
            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Scanned_Document or Receipt_01',
            hintStyle: const TextStyle(
              fontSize: 12,
              color: DesignTokens.neutralGraySixHundred,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? DesignTokens.darkSurfaceSix
                    : DesignTokens.neutralGrayThreeHundred,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: DesignTokens.accentYellow,
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTuneControls(bool isDark) {
    if (config.workflowType == WorkflowType.compilePdf) {
      const List<int> pdfDpiOptions = <int>[75, 100, 200, 300, 600, 1200];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Scan Resolution (DPI)',
            badgeValue: '${config.dpi <= 0 ? 300 : config.dpi} DPI',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pdfDpiOptions.map((int optionDpi) {
              return _buildChip(
                isDark: isDark,
                label: '$optionDpi DPI',
                isSelected: (config.dpi <= 0 ? 300 : config.dpi) == optionDpi,
                onTap: () {
                  config.dpi = optionDpi;
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
          isDark: isDark,
          title: 'Scan Resolution (DPI)',
          badgeValue: '${config.dpi} DPI',
        ),
        const SizedBox(height: 8),
        _buildYellowSlider(
          isDark: isDark,
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
              isDark: isDark,
              label: '$dpiValue DPI',
              isSelected: config.dpi == dpiValue,
              onTap: () {
                config.dpi = dpiValue;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
        if (config.workflowType == WorkflowType.cardDuplex ||
            config.workflowType == WorkflowType.legalStitch)
          _buildFileNameSection(isDark),
      ],
    );
  }

  Widget _buildRotateControls(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          isDark: isDark,
          title: 'Page Orientation & Rotation',
          badgeValue: '${config.rotation}°',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: const <int>[0, 90, 180, 270].map((int deg) {
            return _buildChip(
              isDark: isDark,
              label: '$deg°',
              isSelected: config.rotation == deg,
              onTap: () {
                config.rotation = deg;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
        if (config.workflowType == WorkflowType.cardDuplex ||
            config.workflowType == WorkflowType.legalStitch)
          _buildFileNameSection(isDark),
      ],
    );
  }

  Widget _buildContrastControls(bool isDark) {
    final bool supportsToneSliders = (config.workflowType == WorkflowType.flatbed ||
        config.workflowType == WorkflowType.customPlaten);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          isDark: isDark,
          title: 'Color Mode & Exposure',
          badgeValue: PeaPodDrawer.formatPresetTitle(config.colorMode),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children:
              const <String>['color', 'grayscale', 'bw'].map((String mode) {
            return _buildChip(
              isDark: isDark,
              label: PeaPodDrawer.formatPresetTitle(mode),
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
                      'Brightness: ${config.brightness}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
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
                      'Contrast: ${config.contrast}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
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

  Widget _buildCropControls(bool isDark) {
    if (config.workflowType == WorkflowType.cardDuplex) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Card Alignment & Geometry',
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
                  isDark: isDark,
                  label: 'Duplex (Front + Back)',
                  isSelected: config.cardDuplexTwoSided,
                  onTap: () {
                    config.cardDuplexTwoSided = true;
                    onConfigChanged(config);
                  },
                ),
                _buildChip(
                  isDark: isDark,
                  label: 'Single Side Only',
                  isSelected: !config.cardDuplexTwoSided,
                  onTap: () {
                    config.cardDuplexTwoSided = false;
                    onConfigChanged(config);
                  },
                ),
                _buildChip(
                  isDark: isDark,
                  label: config.noDeskew
                      ? 'Manual 4×4" Region'
                      : 'Auto Deskew & Straighten',
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
            children: const <String>['transparent', 'white', 'black']
                .map((String bg) {
              return _buildChip(
                isDark: isDark,
                label: 'Background: ${PeaPodDrawer.formatPresetTitle(bg)}',
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
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.safetyInsetMm,
                      min: 0.0,
                      max: 3.0,
                      divisions: 30,
                      onChanged: (double value) {
                        config.safetyInsetMm = double.parse(value.toStringAsFixed(1));
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
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DesignTokens.neutralGrayFourHundred
                            : DesignTokens.neutralGrayEightHundred,
                      ),
                    ),
                    _buildYellowSlider(
                      isDark: isDark,
                      value: config.cornerRadiusMm,
                      min: 0.0,
                      max: 6.0,
                      divisions: 60,
                      onChanged: (double value) {
                        config.cornerRadiusMm = double.parse(value.toStringAsFixed(2));
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

    if (config.workflowType == WorkflowType.compilePdf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDrawerHeader(
            isDark: isDark,
            title: 'Page Margin Bleed',
            badgeValue: '${config.marginMm.toStringAsFixed(1)} mm',
          ),
          const SizedBox(height: 8),
          _buildYellowSlider(
            isDark: isDark,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          isDark: isDark,
          title: 'Automatic Border Trimming',
          badgeValue: config.autoCrop ? 'Enabled' : 'Off',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: <Widget>[
            _buildChip(
              isDark: isDark,
              label: 'Full Region (No Auto-Crop)',
              isSelected: !config.autoCrop,
              onTap: () {
                config.autoCrop = false;
                onConfigChanged(config);
              },
            ),
            _buildChip(
              isDark: isDark,
              label: 'Trim Borders',
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

  Widget _buildTitleControls(bool isDark) {
    final List<String> allowedFormats;
    switch (config.workflowType) {
      case WorkflowType.legalStitch:
        allowedFormats = const <String>['pdf', 'png'];
      case WorkflowType.cardDuplex:
        allowedFormats = const <String>['png', 'jpg', 'tiff', 'bmp'];
      case WorkflowType.compilePdf:
        allowedFormats = const <String>['pdf', 'png', 'jpg', 'tiff'];
      case WorkflowType.flatbed:
      case WorkflowType.customPlaten:
        allowedFormats = const <String>['pdf', 'png', 'jpg', 'tiff', 'bmp'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          isDark: isDark,
          title: 'Output File & Storage',
          badgeValue: '.${config.format.toUpperCase()}',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allowedFormats.map((String formatName) {
            return _buildChip(
              isDark: isDark,
              label: formatName.toUpperCase(),
              isSelected: config.format == formatName,
              onTap: () {
                config.format = formatName;
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
                controller: _prefixController,
                onChanged: (String value) {
                  config.fileNamePrefix = value;
                  onConfigChanged(config);
                },
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Filename Prefix',
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? DesignTokens.neutralGrayFiveHundred
                        : DesignTokens.neutralGrayEightHundred,
                  ),
                  hintText: 'e.g. Scan_Document or National_ID',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGraySixHundred,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? DesignTokens.darkSurfaceSix
                          : DesignTokens.neutralGrayThreeHundred,
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
                controller: _outputDirectoryController,
                onChanged: (String value) {
                  config.outputDirectory = value;
                  onConfigChanged(config);
                },
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                ),
                decoration: InputDecoration(
                  labelText: 'Save Location Folder',
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? DesignTokens.neutralGrayFiveHundred
                        : DesignTokens.neutralGrayEightHundred,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? DesignTokens.darkSurfaceSix
                          : DesignTokens.neutralGrayThreeHundred,
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

  Widget _buildTimerControls(bool isDark) {
    final String timerTitle = config.workflowType == WorkflowType.cardDuplex
        ? 'Card Flip Countdown Timer'
        : 'Multi-Page Scan Timer';
    const List<int> cadenceIntervalOptions = <int>[0, 3, 5, 8, 10, 15, 20, 30];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDrawerHeader(
          isDark: isDark,
          title: timerTitle,
          badgeValue: config.intervalSeconds == 0
              ? 'Manual Trigger'
              : '${config.intervalSeconds}s Interval',
        ),
        const SizedBox(height: 8),
        _buildYellowSlider(
          isDark: isDark,
          value: config.intervalSeconds.toDouble().clamp(0.0, 30.0),
          min: 0.0,
          max: 30.0,
          divisions: 30,
          onChanged: (double sliderValue) {
            config.intervalSeconds = sliderValue.round();
            onConfigChanged(config);
          },
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cadenceIntervalOptions.map((int intervalValue) {
            return _buildChip(
              isDark: isDark,
              label: intervalValue == 0
                  ? 'Manual Trigger'
                  : '$intervalValue Seconds',
              isSelected: config.intervalSeconds == intervalValue,
              onTap: () {
                config.intervalSeconds = intervalValue;
                onConfigChanged(config);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: switch (selectedTool) {
        PeaPodToolType.layout => _buildLayoutControls(isDark),
        PeaPodToolType.tune => _buildTuneControls(isDark),
        PeaPodToolType.timer => _buildTimerControls(isDark),
        PeaPodToolType.rotate => _buildRotateControls(isDark),
        PeaPodToolType.contrast => _buildContrastControls(isDark),
        PeaPodToolType.crop => _buildCropControls(isDark),
        PeaPodToolType.title => _buildTitleControls(isDark),
      },
    );
  }
}
