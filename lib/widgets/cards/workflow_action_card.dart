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
    required this.subtitle,
    required this.icon,
    required this.theme,
    required this.onTap,
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
    final Color subtitleColor;

    switch (widget.theme) {
      case WorkflowCardTheme.yellow:
        backgroundColor = DesignTokens.accentYellow;
        textColor = DesignTokens.onyx;
        arrowBadgeBackground = DesignTokens.pureWhite;
        arrowBadgeForeground = DesignTokens.onyx;
        subtitleColor = DesignTokens.onyx.withValues(alpha: 0.68);
      case WorkflowCardTheme.dark:
        backgroundColor = DesignTokens.onyx;
        textColor = DesignTokens.pureWhite;
        arrowBadgeBackground = DesignTokens.darkSurfaceFour;
        arrowBadgeForeground = DesignTokens.pureWhite;
        subtitleColor = DesignTokens.neutralGrayFourHundred;
      case WorkflowCardTheme.light:
        backgroundColor = DesignTokens.pureWhite;
        textColor = DesignTokens.onyx;
        arrowBadgeBackground = const Color(0xFFF2F2F2);
        arrowBadgeForeground = DesignTokens.onyx;
        subtitleColor = DesignTokens.neutralGraySevenHundred;
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
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: DesignTokens.pureWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: DesignTokens.onyx,
                        size: 19,
                      ),
                    )
                  else
                    Icon(
                      widget.icon,
                      color: DesignTokens.onyx,
                      size: 25,
                    ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.badgeText != null) ...<Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: arrowBadgeBackground.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusPill,
                                ),
                              ),
                              child: Text(
                                widget.badgeText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: arrowBadgeForeground,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
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
                  ),
                ],
              ),

              // Bottom Label + Consumer Subtitle
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
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
