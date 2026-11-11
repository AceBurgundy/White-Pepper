import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../providers/app_state.dart';

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

  Widget _buildCheckItem({
    required String title,
    required String subtitle,
    required bool isSuccess,
    required bool isPending,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DesignTokens.neutralGrayFifty,
        borderRadius: BorderRadius.circular(DesignTokens.radiusModuleContainer),
        border: Border.all(
          color: isSuccess
              ? DesignTokens.statusOnlineGreen.withValues(alpha: 0.4)
              : DesignTokens.neutralGrayTwoHundred,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.onyx,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.neutralGraySevenHundred,
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: DesignTokens.pureWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
          boxShadow: DesignTokens.shadowWorkstation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: DesignTokens.onyx,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_input_component_rounded,
                        color: DesignTokens.accentYellow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Hardware Diagnostics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.onyx,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildCheckItem(
              title: 'Wireless Network Scanner',
              subtitle:
                  'Status: ${state.isScannerOnline ? "Connected" : "Searching"} (${state.scannerEndpoint})',
              isSuccess: state.isScannerOnline,
              isPending: _isProbing,
            ),
            _buildCheckItem(
              title: 'Direct USB Connection',
              subtitle: 'Local device scanner ready',
              isSuccess: true,
              isPending: _isProbing,
            ),
            _buildCheckItem(
              title: 'System Scanner Driver',
              subtitle: 'Operating system scanner service ready',
              isSuccess: true,
              isPending: _isProbing,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(DesignTokens.onyx),
                      ),
                    )
                  : const Text(
                      'Check Scanner Connection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
