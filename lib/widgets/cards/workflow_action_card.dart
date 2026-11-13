import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

enum WorkflowCardTheme {
  yellow,
  dark,
  light,
}

class WorkflowActionCard extends StatefulWidget {
  const WorkflowActionCard({
    required this.title,
    required this.icon,
    required this.theme,
    required this.onTap,
    this.subtitle = '',
    this.emojiIcon,
    this.useEmoji = false,
    this.badgeText,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? emojiIcon;
  final bool useEmoji;
  final WorkflowCardTheme theme;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  State<WorkflowActionCard> createState() => _WorkflowActionCardState();
}

class _WorkflowActionCardState extends State<WorkflowActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final Color arrowBadgeBackground;
    final Color arrowBadgeForeground;

    switch (widget.theme) {
      case WorkflowCardTheme.yellow:
        backgroundColor = DesignTokens.accentYellow;
        textColor = DesignTokens.onyx;
        arrowBadgeBackground = DesignTokens.pureWhite;
        arrowBadgeForeground = DesignTokens.onyx;
      case WorkflowCardTheme.dark:
        backgroundColor = DesignTokens.onyx;
        textColor = DesignTokens.pureWhite;
        arrowBadgeBackground = DesignTokens.darkSurfaceFour;
        arrowBadgeForeground = DesignTokens.pureWhite;
      case WorkflowCardTheme.light:
        backgroundColor = DesignTokens.pureWhite;
        textColor = DesignTokens.onyx;
        arrowBadgeBackground = DesignTokens.neutralGrayOneHundred;
        arrowBadgeForeground = DesignTokens.onyx;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(DesignTokens.radiusCardMedium),
            border: Border.all(
              color: widget.theme == WorkflowCardTheme.light
                  ? DesignTokens.neutralGrayTwoHundred
                  : (widget.theme == WorkflowCardTheme.dark
                      ? DesignTokens.darkSurfaceFour
                      : Colors.transparent),
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? <BoxShadow>[
                    BoxShadow(
                      color: DesignTokens.onyx.withValues(alpha: 0.14),
                      offset: const Offset(0, 10),
                      blurRadius: 28,
                    ),
                  ]
                : <BoxShadow>[
                    BoxShadow(
                      color: DesignTokens.onyx.withValues(
                        alpha: widget.theme == WorkflowCardTheme.dark ? 0.08 : 0.05,
                      ),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Top row: Black Line Icon + North-East Circular Arrow Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (widget.theme == WorkflowCardTheme.dark)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: DesignTokens.pureWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: DesignTokens.onyx,
                        size: 20,
                      ),
                    )
                  else
                    Icon(
                      widget.icon,
                      color: DesignTokens.onyx,
                      size: 26,
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    transform: Matrix4.translationValues(
                      _isHovered ? 2.0 : 0.0,
                      _isHovered ? -2.0 : 0.0,
                      0.0,
                    ),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: arrowBadgeBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.north_east_rounded,
                      color: arrowBadgeForeground,
                      size: 16,
                    ),
                  ),
                ],
              ),

              // Bottom Label: Title and short subtitle description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                  ),
                  if (widget.subtitle.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.theme == WorkflowCardTheme.dark
                            ? DesignTokens.neutralGrayFourHundred
                            : (widget.theme == WorkflowCardTheme.yellow
                                ? DesignTokens.onyx.withValues(alpha: 0.72)
                                : DesignTokens.neutralGraySixHundred),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
