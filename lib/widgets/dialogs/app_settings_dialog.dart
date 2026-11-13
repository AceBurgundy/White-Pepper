import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../providers/app_state.dart';
import '../icons/animated_line_icons/animated_line_icons.dart';

class AppSettingsDialog extends StatefulWidget {
  const AppSettingsDialog({super.key});

  @override
  State<AppSettingsDialog> createState() => _AppSettingsDialogState();
}

class _AppSettingsDialogState extends State<AppSettingsDialog> {
  late final TextEditingController _directoryController;

  @override
  void initState() {
    super.initState();
    _directoryController = TextEditingController(
      text: context.read<AppState>().config.outputDirectory,
    );
  }

  @override
  void dispose() {
    _directoryController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildToggleChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.accentYellow
              : (isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayOneHundred),
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? DesignTokens.onyx
                : (isDark ? DesignTokens.pureWhite : DesignTokens.onyx),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool isDark = state.isDarkMode;

    final Color cardBackgroundColor = isDark ? DesignTokens.darkSurfaceOne : DesignTokens.pureWhite;
    final Color textColor = isDark ? DesignTokens.pureWhite : DesignTokens.onyx;
    final Color subtleColor = isDark ? DesignTokens.neutralGrayFourHundred : DesignTokens.neutralGraySevenHundred;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
          boxShadow: DesignTokens.shadowWorkstation,
          border: Border.all(
            color: isDark ? DesignTokens.darkSurfaceThree : DesignTokens.neutralGrayTwoHundred,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayOneHundred,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Application Settings',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DialogCloseButton(
                  onTap: () => Navigator.of(context).pop(),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Theme Mode Selection
            _buildSectionHeader('APPLICATION THEME', subtleColor),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _buildToggleChip(
                  label: 'All-Day (Light)',
                  isSelected: !state.isDarkMode,
                  onTap: () => state.setDarkMode(false),
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildToggleChip(
                  label: 'Night Mode (Dark)',
                  isSelected: state.isDarkMode,
                  onTap: () => state.setDarkMode(true),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Units Selection
            _buildSectionHeader('MEASUREMENT UNITS', subtleColor),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _buildToggleChip(
                  label: 'Millimeters (mm)',
                  isSelected: state.config.units == 'mm',
                  onTap: () {
                    if (state.config.units == 'in') {
                      state.config.customWidth = (state.config.customWidth * 25.4).clamp(20.0, 216.0);
                      state.config.customHeight = (state.config.customHeight * 25.4).clamp(20.0, 297.0);
                      state.config.offsetX = (state.config.offsetX * 25.4).clamp(0.0, 150.0);
                      state.config.offsetY = (state.config.offsetY * 25.4).clamp(0.0, 200.0);
                    }
                    state.config.units = 'mm';
                    state.updateConfig(state.config);
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildToggleChip(
                  label: 'Inches (in)',
                  isSelected: state.config.units == 'in',
                  onTap: () {
                    if (state.config.units == 'mm') {
                      state.config.customWidth = (state.config.customWidth / 25.4).clamp(1.0, 8.5);
                      state.config.customHeight = (state.config.customHeight / 25.4).clamp(1.0, 11.7);
                      state.config.offsetX = (state.config.offsetX / 25.4).clamp(0.0, 6.0);
                      state.config.offsetY = (state.config.offsetY / 25.4).clamp(0.0, 9.0);
                    }
                    state.config.units = 'in';
                    state.updateConfig(state.config);
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Default DPI
            _buildSectionHeader('DEFAULT SCAN QUALITY', subtleColor),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <int>[75, 100, 200, 300, 600, 1200].map((int dpi) {
                return _buildToggleChip(
                  label: '$dpi DPI',
                  isSelected: state.config.dpi == dpi,
                  onTap: () {
                    state.config.dpi = dpi;
                    state.updateConfig(state.config);
                  },
                  isDark: isDark,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Default Output Folder
            _buildSectionHeader('DEFAULT SAVE FOLDER', subtleColor),
            const SizedBox(height: 10),
            TextField(
              controller: _directoryController,
              onChanged: (String value) {
                state.config.outputDirectory = value;
                state.updateConfig(state.config);
              },
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark ? DesignTokens.darkSurfaceTwo : DesignTokens.neutralGrayFifty,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayThreeHundred,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: DesignTokens.accentYellow,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Done Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.accentYellow,
                  foregroundColor: DesignTokens.onyx,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
