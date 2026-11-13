import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

class PrinterStatusCard extends StatelessWidget {
  const PrinterStatusCard({
    required this.deviceTitle,
    required this.deviceEndpoint,
    required this.isOnline,
    required this.onTapDiagnostics,
    this.cyanLevel = 0.85,
    this.magentaLevel = 0.70,
    this.yellowLevel = 0.90,
    this.blackLevel = 0.60,
    super.key,
  });

  final String deviceTitle;
  final String deviceEndpoint;
  final bool isOnline;
  final VoidCallback onTapDiagnostics;
  final double cyanLevel;
  final double magentaLevel;
  final double yellowLevel;
  final double blackLevel;

  Widget _buildInkIndicator(String label, Color color, double level) {
    return Tooltip(
      message: '$label: ${(level * 100).toInt()}%',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 28,
            decoration: BoxDecoration(
              color: DesignTokens.neutralGrayOneHundred,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 10,
              height: 28 * level.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: DesignTokens.neutralGraySixHundred,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.pureWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusModuleContainer),
        boxShadow: DesignTokens.shadowCard,
      ),
      child: Row(
        children: [
          // Status LED with pulse glow
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? DesignTokens.statusOnlineGreen
                  : DesignTokens.statusErrorRed,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: DesignTokens.statusOnlineGreen.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Printer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deviceTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.onyx,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deviceEndpoint,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.neutralGraySixHundred,
                  ),
                ),
              ],
            ),
          ),

          // Ink bars
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInkIndicator('C', DesignTokens.inkCyan, cyanLevel),
              const SizedBox(width: 6),
              _buildInkIndicator('M', DesignTokens.inkMagenta, magentaLevel),
              const SizedBox(width: 6),
              _buildInkIndicator('Y', DesignTokens.inkYellow, yellowLevel),
              const SizedBox(width: 6),
              _buildInkIndicator('K', DesignTokens.inkBlack, blackLevel),
            ],
          ),
          const SizedBox(width: 16),

          // Action / Connect button
          InkWell(
            onTap: onTapDiagnostics,
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: DesignTokens.neutralGrayFifty,
                borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                border: Border.all(
                  color: DesignTokens.neutralGrayTwoHundred,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings_input_component,
                    size: 15,
                    color: DesignTokens.onyx,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.onyx,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
