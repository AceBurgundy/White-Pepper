import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../providers/app_state.dart';
import 'scanner_selector_dialog.dart';

class HardwareConnectDialog extends StatefulWidget {
  const HardwareConnectDialog({super.key});

  @override
  State<HardwareConnectDialog> createState() => _HardwareConnectDialogState();
}

class _HardwareConnectDialogState extends State<HardwareConnectDialog> {
  bool _isProbing = false;

  Future<void> _handleProbe() async {
    setState(() => _isProbing = true);
    await context.read<AppState>().runDiagnostics();
    if (mounted) {
      setState(() => _isProbing = false);
    }
  }

  Widget _build3DPrinterIcon() {
    return Container(
      width: 120,
      height: 94,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(55),
          topRight: Radius.circular(55),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFF0F0F0),
            Color(0xFFD0D0D0),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x28000000),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC0C0C0),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8E8E8),
              border: Border.all(
                color: const Color(0xFFB5B5B5),
                width: 2.0,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x18000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.print_rounded,
                color: DesignTokens.neutralGraySevenHundred,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: DesignTokens.statusOnlineGreen,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: DesignTokens.statusOnlineGreen,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkChannel({
    required String label,
    required double percentage,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: <Widget>[
        Container(
          width: 16,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayTwoHundred,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 16,
            height: 48 * percentage,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
          ),
        ),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: isDark ? DesignTokens.neutralGrayFiveHundred : DesignTokens.neutralGraySevenHundred,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required String title,
    required String subtitle,
    required bool isSuccess,
    required bool isPending,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurfaceTwo : DesignTokens.neutralGrayFifty,
        borderRadius: BorderRadius.circular(DesignTokens.radiusModuleContainer),
        border: Border.all(
          color: isSuccess
              ? DesignTokens.statusOnlineGreen.withValues(alpha: 0.4)
              : (isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayTwoHundred),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPending
                  ? DesignTokens.neutralGrayTwoHundred
                  : (isSuccess
                      ? DesignTokens.statusOnlineGreen
                      : DesignTokens.statusErrorRed),
            ),
            child: Icon(
              isPending
                  ? Icons.hourglass_empty_rounded
                  : (isSuccess ? Icons.check_rounded : Icons.close_rounded),
              color: DesignTokens.pureWhite,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? DesignTokens.neutralGrayFourHundred : DesignTokens.neutralGraySevenHundred,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool isDark = state.isDarkMode;

    final Color dialogBackgroundColor = isDark ? DesignTokens.darkSurfaceOne : DesignTokens.pureWhite;
    final Color textColor = isDark ? DesignTokens.pureWhite : DesignTokens.onyx;
    final Color subtleColor = isDark ? DesignTokens.neutralGrayFourHundred : DesignTokens.neutralGraySevenHundred;

    final List<Map<String, Object>> channels = <Map<String, Object>>[
      <String, Object>{'label': 'C', 'percentage': 0.85, 'color': DesignTokens.inkCyan},
      <String, Object>{'label': 'M', 'percentage': 0.72, 'color': DesignTokens.inkMagenta},
      <String, Object>{'label': 'Y', 'percentage': 0.92, 'color': DesignTokens.inkYellow},
      <String, Object>{'label': 'K', 'percentage': 0.64, 'color': isDark ? DesignTokens.pureWhite : DesignTokens.onyx},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: dialogBackgroundColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
          boxShadow: DesignTokens.shadowWorkstation,
          border: Border.all(
            color: isDark ? DesignTokens.darkSurfaceThree : DesignTokens.neutralGrayTwoHundred,
          ),
        ),
        child: SingleChildScrollView(
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
                            Icons.print_rounded,
                            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Printer Details & Diagnostics',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: subtleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Printer Name and Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          state.scannerModel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.isScannerOnline ? 'Ready for high-speed scanning' : 'Scanner is offline or sleeping',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: subtleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayOneHundred,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: state.isScannerOnline
                                ? DesignTokens.statusOnlineGreen
                                : DesignTokens.accentYellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isScannerOnline ? 'Online' : 'Standby',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Centered 3D Grey Printer Icon + Ink Channel Bars
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? DesignTokens.darkSurfaceTwo : DesignTokens.neutralGrayFifty,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusCardInner),
                  border: Border.all(
                    color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayTwoHundred,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // Centered 3D Grey Printer Icon
                    _build3DPrinterIcon(),

                    // Ink Level Bars
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'INK LEVELS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: subtleColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: channels.map((Map<String, Object> channel) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildInkChannel(
                                label: channel['label']! as String,
                                percentage: channel['percentage']! as double,
                                color: channel['color']! as Color,
                                isDark: isDark,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hardware Diagnostics Section Header
              Text(
                'HARDWARE DIAGNOSTICS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: subtleColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              _buildCheckItem(
                title: 'Wireless Network Scanner',
                subtitle: state.isScannerOnline
                    ? 'Connected via wireless network'
                    : 'Searching for wireless network scanners...',
                isSuccess: state.isScannerOnline,
                isPending: _isProbing,
                isDark: isDark,
              ),
              _buildCheckItem(
                title: 'Direct USB Connection',
                subtitle: 'Local device scanner ready',
                isSuccess: true,
                isPending: _isProbing,
                isDark: isDark,
              ),
              _buildCheckItem(
                title: 'System Scanner Driver',
                subtitle: 'Operating system scanner service ready',
                isSuccess: true,
                isPending: _isProbing,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog<void>(
                          context: context,
                          builder: (_) => const ScannerSelectorDialog(),
                        );
                      },
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: const Text(
                        'Switch Scanner',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                        side: BorderSide(
                          color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.neutralGrayThreeHundred,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProbing ? null : _handleProbe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentYellow,
                        foregroundColor: DesignTokens.onyx,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                        ),
                        elevation: 0,
                      ),
                      child: _isProbing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.onyx),
                              ),
                            )
                          : const Text(
                              'Check Scanner',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
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
    );
  }
}
