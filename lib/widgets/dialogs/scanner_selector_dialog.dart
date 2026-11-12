import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scanner_device_model.dart';
import '../../providers/app_state.dart';

class ScannerSelectorDialog extends StatelessWidget {
  const ScannerSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool isDark = state.isDarkMode;

    final Color backgroundColor =
        isDark ? DesignTokens.darkSurfaceOne : DesignTokens.pureWhite;
    final Color textColor = isDark ? DesignTokens.pureWhite : DesignTokens.onyx;
    final Color subtleColor = isDark
        ? DesignTokens.neutralGrayFourHundred
        : DesignTokens.neutralGraySevenHundred;
    final Color borderColor = isDark
        ? DesignTokens.darkSurfaceThree
        : DesignTokens.neutralGrayTwoHundred;

    final List<ScannerDeviceModel> scanners = state.availableScanners;
    final bool isDiscovering = state.isDiscoveringScanners;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: DesignTokens.shadowWorkstation,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header Row
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? DesignTokens.darkSurfaceFour
                            : DesignTokens.neutralGrayOneHundred,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sync_rounded,
                          color: isDark ? DesignTokens.accentYellow : DesignTokens.onyx,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Select Scanner',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Connects to available Wi-Fi and USB printers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? DesignTokens.darkSurfaceFour
                                : DesignTokens.neutralGrayOneHundred,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: subtleColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Scanners List or Empty State
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (scanners.isEmpty) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 32),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.print_disabled_rounded,
                                  size: 48,
                                  color: subtleColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No Scanners Found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Ensure your printer is turned on and connected to the same Wi-Fi network, or plugged in via USB.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtleColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...<Widget>[
                          for (final ScannerDeviceModel scanner in scanners) ...<Widget>[
                            _buildScannerCard(
                              context: context,
                              scanner: scanner,
                              isSelected: state.activeScanner?.id == scanner.id,
                              isDark: isDark,
                              textColor: textColor,
                              subtleColor: subtleColor,
                              onTap: () {
                                state.selectScanner(scanner);
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Action Bar: Scan for Printers Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          foregroundColor: subtleColor,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton.icon(
                          onPressed: isDiscovering
                              ? null
                              : () => state.discoverScanners(notify: true),
                          icon: isDiscovering
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DesignTokens.onyx,
                                  ),
                                )
                              : const Icon(Icons.sync_rounded, size: 16),
                          label: Text(
                            isDiscovering ? 'Searching...' : 'Scan for Printers',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.accentYellow,
                            foregroundColor: DesignTokens.onyx,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard({
    required BuildContext context,
    required ScannerDeviceModel scanner,
    required bool isSelected,
    required bool isDark,
    required Color textColor,
    required Color subtleColor,
    required VoidCallback onTap,
  }) {
    final bool isWifi = scanner.connectionType == ScannerConnectionType.wifi;
    final IconData transportIcon =
        isWifi ? Icons.wifi_rounded : Icons.usb_rounded;

    final Color cardBackground = isSelected
        ? (isDark
            ? DesignTokens.darkSurfaceThree
            : DesignTokens.accentYellow.withValues(alpha: 0.18))
        : (isDark ? DesignTokens.darkSurfaceTwo : DesignTokens.neutralGrayFifty);

    final Color cardBorderColor = isSelected
        ? DesignTokens.accentYellow
        : (isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayTwoHundred);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(DesignTokens.radiusCardInner),
            border: Border.all(
              color: cardBorderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              // Transport icon avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? DesignTokens.darkSurfaceFour
                      : DesignTokens.neutralGrayOneHundred,
                ),
                child: Center(
                  child: Icon(
                    transportIcon,
                    color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and pill badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      scanner.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        // Connection Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.darkSurfaceFour
                                : DesignTokens.neutralGrayTwoHundred,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            scanner.connectionLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Online dot
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scanner.isOnline
                                ? DesignTokens.statusOnlineGreen
                                : DesignTokens.statusErrorRed,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          scanner.isOnline ? 'Ready' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Selection checkmark
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: DesignTokens.statusOnlineGreen,
                  size: 22,
                )
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: subtleColor.withValues(alpha: 0.4),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
