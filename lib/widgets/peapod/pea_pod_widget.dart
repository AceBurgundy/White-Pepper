import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';

/// Contoured liquid tool selector replicating minimalist/components/pea-pod/PeaPod.js
class PeaPodWidget extends StatefulWidget {
  const PeaPodWidget({
    required this.selectedTool,
    required this.onToolSelected,
    this.tools = PeaPodToolType.values,
    this.isDarkMode = false,
    super.key,
  });

  final PeaPodToolType selectedTool;
  final ValueChanged<PeaPodToolType> onToolSelected;
  final List<PeaPodToolType> tools;
  final bool isDarkMode;

  @override
  State<PeaPodWidget> createState() => _PeaPodWidgetState();
}

class _PeaPodWidgetState extends State<PeaPodWidget>
    with SingleTickerProviderStateMixin {
  int _windowStartIndex = 0;
  late AnimationController _dropletController;
  late Animation<double> _dropletScaleX;
  late Animation<double> _dropletScaleY;

  static const int _visibleSlots = 4;

  @override
  void initState() {
    super.initState();
    _dropletController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _dropletScaleX = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.28),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.28, end: 0.90),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.90, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(parent: _dropletController, curve: Curves.easeOutCubic));

    _dropletScaleY = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.80),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.80, end: 1.12),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.12, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(parent: _dropletController, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant PeaPodWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int maxStart = (widget.tools.length - _visibleSlots).clamp(0, 99);
    if (_windowStartIndex > maxStart) {
      _windowStartIndex = maxStart;
    }
    final int selectedIdx = widget.tools.indexOf(widget.selectedTool);
    if (selectedIdx != -1) {
      if (selectedIdx < _windowStartIndex) {
        _windowStartIndex = selectedIdx;
      } else if (selectedIdx >= _windowStartIndex + _visibleSlots) {
        _windowStartIndex =
            (selectedIdx - _visibleSlots + 1).clamp(0, maxStart);
      }
    }
  }

  @override
  void dispose() {
    _dropletController.dispose();
    super.dispose();
  }

  void _stepDirection(int delta) {
    final int selectedIdx = widget.tools.indexOf(widget.selectedTool);
    if (selectedIdx == -1) return;
    final int targetIdx =
        (selectedIdx + delta).clamp(0, widget.tools.length - 1);
    if (targetIdx != selectedIdx) {
      _dropletController.forward(from: 0.0);
      widget.onToolSelected(widget.tools[targetIdx]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final int slotCount = widget.tools.length < _visibleSlots
        ? widget.tools.length
        : _visibleSlots;
    final List<PeaPodToolType> visibleTools =
        widget.tools.skip(_windowStartIndex).take(slotCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Left Navigation Arrow Pod (.pea-pod__nav-pod)
        _buildNavPod(
          isDark: isDark,
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous parameter',
          onTap: () => _stepDirection(-1),
        ),
        const SizedBox(width: 12),

        // Central Contoured Pod Housing (.pea-pod__housing)
        AnimatedBuilder(
          animation: _dropletController,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scaleX: _dropletScaleX.value,
              scaleY: _dropletScaleY.value,
              child: child,
            );
          },
          child: SizedBox(
            height: 68,
            child: CustomPaint(
              painter: _PeaPodMetaballPainter(
                nodeCount: visibleTools.length,
                isDark: isDark,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(visibleTools.length, (int i) {
                    final PeaPodToolType tool = visibleTools[i];
                    final bool isActive = tool == widget.selectedTool;

                    final Color buttonBg = isActive
                        ? (isDark ? DesignTokens.pureWhite : DesignTokens.onyx)
                        : (isDark ? DesignTokens.darkSurfaceFive : DesignTokens.pureWhite);
                    final Color iconColor = isActive
                        ? (isDark ? DesignTokens.onyx : DesignTokens.pureWhite)
                        : (isDark ? DesignTokens.pureWhite : DesignTokens.onyx);

                    return Padding(
                      padding: EdgeInsets.only(
                        right: i < visibleTools.length - 1 ? 12 : 0,
                      ),
                      child: Tooltip(
                        message: tool.label,
                        child: GestureDetector(
                          onTap: () {
                            _dropletController.forward(from: 0.0);
                            widget.onToolSelected(tool);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: buttonBg,
                              shape: BoxShape.circle,
                              boxShadow: isDark
                                  ? null
                                  : <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                            ),
                            child: Icon(
                              tool.icon,
                              size: 22,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),
        // Right Navigation Arrow Pod (.pea-pod__nav-pod)
        _buildNavPod(
          isDark: isDark,
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next parameter',
          onTap: () => _stepDirection(1),
        ),
      ],
    );
  }

  Widget _buildNavPod({
    required bool isDark,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final Color podBg = isDark
        ? DesignTokens.darkSurfaceTwo
        : const Color(0xFFE4E4E7);
    final Color innerBg = isDark
        ? DesignTokens.darkSurfaceFive
        : DesignTokens.pureWhite;
    final Color iconColor = isDark
        ? DesignTokens.pureWhite
        : DesignTokens.onyx;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: podBg,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: innerBg,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeaPodMetaballPainter extends CustomPainter {
  const _PeaPodMetaballPainter({
    required this.nodeCount,
    required this.isDark,
  });

  final int nodeCount;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount <= 0) return;
    final Paint paint = Paint()
      ..color = isDark
          ? DesignTokens.darkSurfaceTwo
          : const Color(0xFFE4E4E7)
      ..style = PaintingStyle.fill;

    final double centerY = size.height / 2;
    const double buttonDiameter = 52.0;
    const double buttonSpacing = 12.0;
    const double horizontalPad = 6.0;
    const double nodeRadius = 32.0;

    final Path path = Path();
    for (int i = 0; i < nodeCount; i++) {
      final double cx =
          horizontalPad + (buttonDiameter / 2) + i * (buttonDiameter + buttonSpacing);
      path.addOval(
        Rect.fromCircle(center: Offset(cx, centerY), radius: nodeRadius),
      );
      if (i < nodeCount - 1) {
        final double nextCx =
            horizontalPad + (buttonDiameter / 2) + (i + 1) * (buttonDiameter + buttonSpacing);
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx, centerY - 21, nextCx, centerY + 21),
            const Radius.circular(10),
          ),
        );
      }
    }

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
      8.0,
      true,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PeaPodMetaballPainter oldDelegate) =>
      oldDelegate.nodeCount != nodeCount || oldDelegate.isDark != isDark;
}
