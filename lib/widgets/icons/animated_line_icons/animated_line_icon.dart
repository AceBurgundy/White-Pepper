import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import 'line_icon_type.dart';
import 'painters/workflow_icon_painters.dart';
import 'painters/tool_icon_painters.dart';
import 'painters/system_icon_painters.dart';

/// Universal animated line icon widget that independently animates its
/// constituent geometric components when [isHovered] is toggled.
class AnimatedLineIcon extends StatefulWidget {
  const AnimatedLineIcon({
    super.key,
    required this.type,
    this.isHovered = false,
    this.color = const Color(0xFF212121),
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.duration = const Duration(milliseconds: 240),
  });

  final LineIconType type;
  final bool isHovered;
  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<AnimatedLineIcon> createState() => _AnimatedLineIconState();
}

class _AnimatedLineIconState extends State<AnimatedLineIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isHovered ? 1.0 : 0.0,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedLineIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  CustomPainter _resolvePainter(double animationProgress) {
    final Color iconColor = widget.color;
    final double iconStrokeWidth = widget.strokeWidth;

    return switch (widget.type) {
      LineIconType.flatbed => FlatbedLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.photoScan => PhotoScanLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.bookletBatch => BookletBatchLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.cardDuplex => CardDuplexLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.batchCardDeskew => BatchAiLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.compilePdf => PdfLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.grayscaleDocument || LineIconType.receiptArchive => ReceiptLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.legalStitch => LegalStitchLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.customRegion || LineIconType.crop => CropLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.highResArchive => HighResArchiveLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.quickPreview => QuickPreviewLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.layout => LayoutLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.tune => TuneLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.timer => TimerLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.rotate => RotateLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.contrast => ContrastLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.title => TitleLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.arrowBack => ArrowBackLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.themeToggle => ThemeToggleLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.switchScanner => SwitchScannerLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.close => CloseLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.settings => SettingsLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.instructions => InstructionsLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
      LineIconType.chevronRight => ChevronRightLinePainter(
          color: iconColor,
          strokeWidth: iconStrokeWidth,
          animationProgress: animationProgress,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _resolvePainter(_curvedAnimation.value),
        );
      },
    );
  }
}

/// Dedicated dialog close button with animated vector cross strokes on hover.
class DialogCloseButton extends StatefulWidget {
  const DialogCloseButton({
    required this.onTap,
    required this.isDark,
    super.key,
  });

  final VoidCallback onTap;
  final bool isDark;

  @override
  State<DialogCloseButton> createState() => _DialogCloseButtonState();
}

class _DialogCloseButtonState extends State<DialogCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? DesignTokens.darkSurfaceFour
                : DesignTokens.neutralGrayOneHundred,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Opacity(
                  opacity: 0.001,
                  child: Icon(Icons.close_rounded, size: 18),
                ),
                AnimatedLineIcon(
                  type: LineIconType.close,
                  isHovered: _isHovered,
                  color: isDark
                      ? DesignTokens.neutralGrayFourHundred
                      : DesignTokens.neutralGraySevenHundred,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
