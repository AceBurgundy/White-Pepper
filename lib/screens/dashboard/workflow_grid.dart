import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/cards/workflow_action_card.dart';
import '../../widgets/icons/animated_line_icons/animated_line_icons.dart';

/// Single-row horizontal scrollable carousel of workflow action cards.
class WorkflowGrid extends StatefulWidget {
  const WorkflowGrid({
    required this.onSelectWorkflow,
    super.key,
  });

  final ValueChanged<WorkflowType> onSelectWorkflow;

  @override
  State<WorkflowGrid> createState() => _WorkflowGridState();
}

class _WorkflowGridState extends State<WorkflowGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollArrows() {
    if (!mounted || !_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    final bool canLeft = position.pixels > 4.0;
    final bool canRight = position.pixels < (position.maxScrollExtent - 4.0);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollByDelta(double offsetDelta) {
    if (!_scrollController.hasClients) return;
    final double targetOffset = (_scrollController.offset + offsetDelta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description_outlined;
      case 'badge':
        return Icons.badge_outlined;
      case 'vertical_split':
        return Icons.vertical_split_outlined;
      case 'auto_stories':
        return Icons.auto_stories_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'picture_as_pdf':
        return Icons.picture_as_pdf_outlined;
      case 'view_carousel':
        return Icons.crop_free_outlined;
      case 'crop':
        return Icons.crop_outlined;
      case 'high_res':
        return Icons.high_quality_outlined;
      case 'filter_b_and_w':
        return Icons.filter_b_and_w_outlined;
      case 'visibility':
        return Icons.visibility_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  WorkflowCardTheme _resolveTheme(WorkflowType type) {
    switch (type) {
      case WorkflowType.flatbed:
        return WorkflowCardTheme.yellow;
      case WorkflowType.cardDuplex:
        return WorkflowCardTheme.light;
      case WorkflowType.compilePdf:
        return WorkflowCardTheme.dark;
      case WorkflowType.customPlaten:
        return WorkflowCardTheme.light;
      case WorkflowType.legalStitch:
        return WorkflowCardTheme.yellow;
    }
  }

  String _resolveBadge(WorkflowType type) {
    switch (type) {
      case WorkflowType.flatbed:
        return 'PRESETS • 300-1200 DPI';
      case WorkflowType.cardDuplex:
        return '4" WINDOW • TRANSPARENT PNG';
      case WorkflowType.compilePdf:
        return 'MULTI-PAGE • ALL FORMATS';
      case WorkflowType.customPlaten:
        return 'CUSTOM IN/MM';
      case WorkflowType.legalStitch:
        return '2-PASS 14"';
    }
  }

  LineIconType _resolveLineIconType(WorkflowType workflow) {
    return switch (workflow) {
      WorkflowType.flatbed => LineIconType.flatbed,
      WorkflowType.cardDuplex => LineIconType.cardDuplex,
      WorkflowType.compilePdf => LineIconType.compilePdf,
      WorkflowType.customPlaten => LineIconType.customRegion,
      WorkflowType.legalStitch => LineIconType.legalStitch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = Provider.of<AppState>(context);
    final List<WorkflowType> workflows = appState.availableWorkflows;
    final bool isDark = appState.isDarkMode;

    const double cardWidth = 246.0;
    const double cardSpacing = 14.0;
    const double carouselHeight = 162.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Carousel Container with Left/Right navigation chevrons
        SizedBox(
          height: carouselHeight,
          child: Stack(
            children: <Widget>[
              // Horizontal Scrollable Cards List
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  _updateScrollArrows();
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                    itemCount: workflows.length,
                    separatorBuilder: (BuildContext separatorContext, int itemIndex) {
                      return const SizedBox(width: cardSpacing);
                    },
                    itemBuilder: (BuildContext itemContext, int workflowIndex) {
                      final WorkflowType workflow = workflows[workflowIndex];
                      return SizedBox(
                        width: cardWidth,
                        child: WorkflowActionCard(
                          title: workflow.title,
                          subtitle: workflow.subtitle,
                          icon: _resolveIcon(workflow.iconName),
                          lineIconType: _resolveLineIconType(workflow),
                          emojiIcon: workflow.emojiIcon,
                          useEmoji: workflow.useEmoji,
                          theme: _resolveTheme(workflow),
                          badgeText: _resolveBadge(workflow),
                          onTap: () {
                            context.read<AppState>().selectWorkflow(workflow);
                            widget.onSelectWorkflow(workflow);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Left Navigation Chevron Button (visible when scrollable to the left)
              if (_canScrollLeft)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _CarouselArrowButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous Workflows',
                      isDark: isDark,
                      onTap: () => _scrollByDelta(-(cardWidth + cardSpacing)),
                    ),
                  ),
                ),

              // Right Navigation Chevron Button (visible when scrollable to the right)
              if (_canScrollRight)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _CarouselArrowButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next Workflows',
                      isDark: isDark,
                      onTap: () => _scrollByDelta(cardWidth + cardSpacing),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CarouselArrowButton extends StatefulWidget {
  const _CarouselArrowButton({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color arrowBackgroundColor = isDark
        ? (_isHovered ? DesignTokens.pureWhite : DesignTokens.darkSurfaceTwo)
        : (_isHovered ? DesignTokens.onyx : DesignTokens.pureWhite);
    final Color arrowForegroundColor = isDark
        ? (_isHovered ? DesignTokens.onyx : DesignTokens.pureWhite)
        : (_isHovered ? DesignTokens.pureWhite : DesignTokens.onyx);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: arrowBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: DesignTokens.shadowCard,
              border: Border.all(
                color: isDark
                    ? DesignTokens.darkSurfaceFour
                    : DesignTokens.neutralGrayTwoHundred,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 20,
                color: arrowForegroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
