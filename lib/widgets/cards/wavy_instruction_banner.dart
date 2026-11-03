import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../common/wave_painter.dart';

class WavyInstructionBanner extends StatelessWidget {
  const WavyInstructionBanner({
    required this.title,
    required this.description,
    this.badgeText = 'READY',
    this.actionLabel,
    this.onTapAction,
    super.key,
  });

  final String title;
  final String description;
  final String badgeText;
  final String? actionLabel;
  final VoidCallback? onTapAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DesignTokens.pureWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusCardInner),
        boxShadow: DesignTokens.shadowCard,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 16,
            child: const CustomPaint(
              painter: WavePainter(
                waveColor: DesignTokens.neutralGrayTwoHundred,
                amplitude: 3.0,
                frequency: 0.04,
                strokeWidth: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentYellow,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.onyx,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.onyx,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: DesignTokens.neutralGraySevenHundred,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onTapAction != null)
                  ElevatedButton(
                    onPressed: onTapAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.onyx,
                      foregroundColor: DesignTokens.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
