import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

enum ProgressButtonState {
  idle,
  processing,
  completed,
  error,
}

class ProgressButton extends StatefulWidget {
  const ProgressButton({
    required this.state,
    required this.onPressed,
    this.idleText = 'Start Scan',
    this.processingText = 'Scanning Platen...',
    this.completedText = 'Acquisition Complete',
    this.errorText = 'Scan Failed — Retry',
    this.height = 54.0,
    super.key,
  });

  final ProgressButtonState state;
  final VoidCallback onPressed;
  final String idleText;
  final String processingText;
  final String completedText;
  final String errorText;
  final double height;

  @override
  State<ProgressButton> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final String labelText;
    final Widget iconWidget;

    switch (widget.state) {
      case ProgressButtonState.idle:
        backgroundColor = DesignTokens.accentYellow;
        foregroundColor = DesignTokens.onyx;
        labelText = widget.idleText;
        iconWidget = const Icon(
          Icons.arrow_forward_rounded,
          color: DesignTokens.onyx,
          size: 20,
        );
      case ProgressButtonState.processing:
        backgroundColor = DesignTokens.onyx;
        foregroundColor = DesignTokens.accentYellow;
        labelText = widget.processingText;
        iconWidget = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.accentYellow),
          ),
        );
      case ProgressButtonState.completed:
        backgroundColor = DesignTokens.statusOnlineGreen;
        foregroundColor = DesignTokens.pureWhite;
        labelText = widget.completedText;
        iconWidget = const Icon(
          Icons.check_circle_rounded,
          color: DesignTokens.pureWhite,
          size: 20,
        );
      case ProgressButtonState.error:
        backgroundColor = DesignTokens.statusErrorRed;
        foregroundColor = DesignTokens.pureWhite;
        labelText = widget.errorText;
        iconWidget = const Icon(
          Icons.error_outline_rounded,
          color: DesignTokens.pureWhite,
          size: 20,
        );
    }

    final bool isClickable = widget.state == ProgressButtonState.idle ||
        widget.state == ProgressButtonState.error;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (BuildContext context, Widget? child) {
        return InkWell(
          onTap: isClickable ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
              boxShadow: widget.state == ProgressButtonState.idle
                  ? DesignTokens.shadowYellowButton
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(width: 12),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: foregroundColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
