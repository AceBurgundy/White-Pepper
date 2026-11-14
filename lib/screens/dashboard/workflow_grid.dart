import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/cards/workflow_action_card.dart';
import '../../widgets/icons/animated_line_icons/animated_line_icons.dart';

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
  double _scrollFraction = 0.0;
  double _thumbFraction = 0.35;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScrollChanged());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollChanged() {
    if (!mounted || !_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    final double maxExtent = position.maxScrollExtent;
    final double viewport = position.viewportDimension;
    final double totalContent = viewport + (maxExtent > 0 ? maxExtent : 0.0);

    final double newThumbFraction = totalContent > 0
        ? (viewport / totalContent).clamp(0.18, 0.55)
        : 0.35;
    final double newScrollFraction = maxExtent > 0
        ? (position.pixels / maxExtent).clamp(0.0, 1.0)
        : 0.0;

    if ((newScrollFraction - _scrollFraction).abs() > 0.002 ||
        (newThumbFraction - _thumbFraction).abs() > 0.002) {
      setState(() {
        _scrollFraction = newScrollFraction;
        _thumbFraction = newThumbFraction;
      });
    }
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
    final List<WorkflowType> workflows = WorkflowType.values.where((WorkflowType workflow) {
      if (workflow == WorkflowType.legalStitch) {
        return appState.isLegalStitchCardVisible;
      }
      return true;
    }).toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth < 420 ? 1 : 2;
        const double spacing = 16.0;
        const double cardHeight = 148.0;

        final double trackHeight = constraints.maxHeight.clamp(120.0, 4000.0);
        final double thumbHeight = (trackHeight * _thumbFraction).clamp(36.0, trackHeight * 0.65);
        final double availableThumbTravel = (trackHeight - thumbHeight).clamp(0.0, 4000.0);
        final double thumbTop = availableThumbTravel * _scrollFraction;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (ScrollMetricsNotification notification) {
                  _handleScrollChanged();
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16.0),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      mainAxisExtent: cardHeight,
                    ),
                    itemCount: workflows.length,
                    itemBuilder: (BuildContext context, int index) {
                      final WorkflowType workflow = workflows[index];
                      return WorkflowActionCard(
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
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Thin custom scroll thumb (no native scrollbar trough)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  if (!_scrollController.hasClients) return;
                  final double maxExtent = _scrollController.position.maxScrollExtent;
                  if (maxExtent <= 0 || availableThumbTravel <= 0) return;
                  final double deltaScroll = (details.delta.dy / availableThumbTravel) * maxExtent;
                  _scrollController.jumpTo(
                    (_scrollController.offset + deltaScroll)
                        .clamp(0.0, maxExtent),
                  );
                },
                child: SizedBox(
                  width: 6,
                  height: trackHeight,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: thumbTop,
                        right: 1,
                        child: Container(
                          key: const Key('workflow_grid_scroll_thumb'),
                          width: 3.5,
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            color: DesignTokens.onyx.withValues(alpha: 0.36),
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusPill),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
