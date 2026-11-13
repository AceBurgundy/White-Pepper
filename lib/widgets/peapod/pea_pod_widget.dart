import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';
import '../icons/animated_line_icons/animated_line_icons.dart';

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
    with TickerProviderStateMixin {
  int _windowStartIndex = 0;
  late AnimationController _dropletController;
  late Animation<double> _dropletScaleX;
  late Animation<double> _dropletScaleY;

  late AnimationController _nudgeController;
  late Animation<double> _nudgeOffset;

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

    _nudgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _nudgeOffset = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 14.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 14.0, end: -3.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
    ]).animate(_nudgeController);

    if (widget.tools.length > _visibleSlots) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _nudgeController.forward(from: 0.0);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PeaPodWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int maxStart = (widget.tools.length - _visibleSlots).clamp(0, 99);
    if (_windowStartIndex > maxStart) {
      _windowStartIndex = maxStart;
    }
    final int selectedIndex = widget.tools.indexOf(widget.selectedTool);
    if (selectedIndex != -1) {
      if (selectedIndex < _windowStartIndex) {
        _windowStartIndex = selectedIndex;
      } else if (selectedIndex >= _windowStartIndex + _visibleSlots) {
        _windowStartIndex = (selectedIndex - _visibleSlots + 1).clamp(0, maxStart);
      }
    }
    if (widget.tools.length > _visibleSlots && oldWidget.tools != widget.tools) {
      _nudgeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _dropletController.dispose();
    _nudgeController.dispose();
    super.dispose();
  }

  void _stepDirection(int delta) {
    final int selectedIndex = widget.tools.indexOf(widget.selectedTool);
    if (selectedIndex == -1) return;
    final int targetIndex = (selectedIndex + delta).clamp(0, widget.tools.length - 1);
    if (targetIndex != selectedIndex) {
      _dropletController.forward(from: 0.0);
      widget.onToolSelected(widget.tools[targetIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final bool hasHiddenOptions = widget.tools.length > _visibleSlots;
    final int slotCount = widget.tools.length < _visibleSlots
        ? widget.tools.length
        : _visibleSlots;
    final List<PeaPodToolType> visibleTools = widget.tools.skip(_windowStartIndex).take(slotCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Left Navigation Arrow Pod (.pea-pod__nav-pod) - shown only when hidden options exist
        if (hasHiddenOptions) ...<Widget>[
          _PeaPodNavButton(
            isDark: isDark,
            isRight: false,
            tooltip: 'Previous parameter',
            onTap: () => _stepDirection(-1),
          ),
          const SizedBox(width: 12),
        ],

        // Central Contoured Pod Housing (.pea-pod__housing)
        AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_dropletController, _nudgeController]),
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(_nudgeOffset.value, 0.0),
              child: Transform.scale(
                scaleX: _dropletScaleX.value,
                scaleY: _dropletScaleY.value,
                child: child,
              ),
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
                  children: List<Widget>.generate(visibleTools.length, (int iterationIndex) {
                    final PeaPodToolType tool = visibleTools[iterationIndex];
                    final bool isActive = tool == widget.selectedTool;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: iterationIndex < visibleTools.length - 1 ? 12 : 0,
                      ),
                      child: _PeaPodButton(
                        tool: tool,
                        isActive: isActive,
                        isDark: isDark,
                        onTap: () {
                          _dropletController.forward(from: 0.0);
                          widget.onToolSelected(tool);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        // Right Navigation Arrow Pod (.pea-pod__nav-pod) - shown only when hidden options exist
        if (hasHiddenOptions) ...<Widget>[
          const SizedBox(width: 12),
          _PeaPodNavButton(
            isDark: isDark,
            isRight: true,
            tooltip: 'Next parameter',
            onTap: () => _stepDirection(1),
          ),
        ],
      ],
    );
  }
}

class _PeaPodButton extends StatefulWidget {
  const _PeaPodButton({
    required this.tool,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final PeaPodToolType tool;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_PeaPodButton> createState() => _PeaPodButtonState();
}

class _PeaPodButtonState extends State<_PeaPodButton> {
  bool _isHovered = false;

  LineIconType _resolveToolLineIconType(PeaPodToolType tool) {
    return switch (tool) {
      PeaPodToolType.layout => LineIconType.layout,
      PeaPodToolType.tune => LineIconType.tune,
      PeaPodToolType.timer => LineIconType.timer,
      PeaPodToolType.rotate => LineIconType.rotate,
      PeaPodToolType.contrast => LineIconType.contrast,
      PeaPodToolType.crop => LineIconType.crop,
      PeaPodToolType.title => LineIconType.title,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;
    final bool isDark = widget.isDark;

    // Background color is strictly steady: does NOT change on hover!
    final Color buttonBg = isActive
        ? (isDark ? DesignTokens.pureWhite : DesignTokens.onyx)
        : (isDark ? DesignTokens.darkSurfaceFive : DesignTokens.pureWhite);
    final Color iconColor = isActive
        ? (isDark ? DesignTokens.onyx : DesignTokens.pureWhite)
        : (isDark ? DesignTokens.pureWhite : DesignTokens.onyx);

    return Tooltip(
      message: widget.tool.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: buttonBg,
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? null
                  : const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x14000000),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedLineIcon(
                type: _resolveToolLineIconType(widget.tool),
                isHovered: _isHovered,
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

class _PeaPodNavButton extends StatefulWidget {
  const _PeaPodNavButton({
    required this.isDark,
    required this.isRight,
    required this.tooltip,
    required this.onTap,
  });

  final bool isDark;
  final bool isRight;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_PeaPodNavButton> createState() => _PeaPodNavButtonState();
}

class _PeaPodNavButtonState extends State<_PeaPodNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color podBg = isDark
        ? DesignTokens.darkSurfaceTwo
        : DesignTokens.neutralGrayOneHundred;
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
        message: widget.tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Material(
            color: innerBg,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onTap,
              mouseCursor: SystemMouseCursors.click,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: widget.isRight
                      ? AnimatedLineIcon(
                          type: LineIconType.chevronRight,
                          isHovered: _isHovered,
                          color: iconColor,
                          size: 22,
                        )
                      : Transform.rotate(
                          angle: math.pi,
                          child: AnimatedLineIcon(
                            type: LineIconType.chevronRight,
                            isHovered: _isHovered,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                ),
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
          : DesignTokens.neutralGrayOneHundred
      ..style = PaintingStyle.fill;

    final double centerY = size.height / 2;
    const double buttonDiameter = 52.0;
    const double buttonSpacing = 12.0;
    const double horizontalPad = 6.0;
    const double nodeRadius = 32.0;

    final Path path = Path();
    for (int nodeIndex = 0; nodeIndex < nodeCount; nodeIndex++) {
      final double centerCoordinateX = horizontalPad + (buttonDiameter / 2) +
          nodeIndex * (buttonDiameter + buttonSpacing);
      path.addOval(
        Rect.fromCircle(center: Offset(centerCoordinateX, centerY), radius: nodeRadius),
      );
      if (nodeIndex < nodeCount - 1) {
        final double nextCenterCoordinateX = horizontalPad + (buttonDiameter / 2) +
            (nodeIndex + 1) * (buttonDiameter + buttonSpacing);
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(centerCoordinateX, centerY - 21, nextCenterCoordinateX, centerY + 21),
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
