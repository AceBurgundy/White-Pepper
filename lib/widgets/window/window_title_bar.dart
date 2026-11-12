import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/theme/design_tokens.dart';

/// Seamless frameless window top bar integrated directly into the parent window body.
///
/// Features:
/// - Zero bottom border/divider so the top bar looks like part of the body
/// - No app name in the top bar (app name is displayed in the sidebar headline)
/// - Full-width draggable region with double-click to maximize/restore
/// - Right-most aligned Minimize, Maximize/Restore, and Close action buttons
class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar({
    required this.isDark,
    this.subtitle,
    super.key,
  });

  final bool isDark;
  final String? subtitle;

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      windowManager.addListener(this);
      _checkMaximizedState();
    }
  }

  @override
  void dispose() {
    if (_isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  Future<void> _checkMaximizedState() async {
    try {
      final bool maximized = await windowManager.isMaximized();
      if (mounted) {
        setState(() => _isMaximized = maximized);
      }
    } catch (_) {}
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  Future<void> _toggleMaximize() async {
    if (!_isDesktop) return;
    try {
      if (_isMaximized) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  Future<void> _minimizeWindow() async {
    if (!_isDesktop) return;
    try {
      await windowManager.minimize();
    } catch (_) {}
  }

  Future<void> _closeWindow() async {
    if (!_isDesktop) return;
    try {
      await windowManager.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = widget.isDark ? DesignTokens.pureWhite : DesignTokens.onyx;
    final Color hoverBackgroundColor = widget.isDark
        ? DesignTokens.pureWhite.withValues(alpha: 0.12)
        : DesignTokens.onyx.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      height: 36,
      padding: const EdgeInsets.only(left: 12, right: 10, top: 4),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Full-width draggable area occupying 100% of space to the left of action buttons
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) {
                if (_isDesktop) {
                  windowManager.startDragging();
                }
              },
              onDoubleTap: _toggleMaximize,
              child: const SizedBox.expand(),
            ),
          ),

          // Right-most Window Action Buttons
          _WindowActionButton(
            icon: Icons.remove_rounded,
            tooltip: 'Minimize',
            iconColor: foregroundColor,
            hoverColor: hoverBackgroundColor,
            onPressed: _minimizeWindow,
          ),
          const SizedBox(width: 4),
          _WindowActionButton(
            icon: _isMaximized
                ? Icons.filter_none_rounded
                : Icons.crop_square_rounded,
            tooltip: _isMaximized ? 'Restore' : 'Maximize',
            iconSize: _isMaximized ? 13 : 15,
            iconColor: foregroundColor,
            hoverColor: hoverBackgroundColor,
            onPressed: _toggleMaximize,
          ),
          const SizedBox(width: 4),
          _WindowActionButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            iconColor: foregroundColor,
            hoverColor: const Color(0xFFEF4444),
            hoverIconColor: DesignTokens.pureWhite,
            onPressed: _closeWindow,
          ),
        ],
      ),
    );
  }
}

class _WindowActionButton extends StatefulWidget {
  const _WindowActionButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.hoverColor,
    required this.onPressed,
    this.hoverIconColor,
    this.iconSize = 16,
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final Color hoverColor;
  final Color? hoverIconColor;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  State<_WindowActionButton> createState() => _WindowActionButtonState();
}

class _WindowActionButtonState extends State<_WindowActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color currentIconColor = (_isHovered && widget.hoverIconColor != null)
        ? widget.hoverIconColor!
        : widget.iconColor;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 32,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? widget.hoverColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: currentIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
