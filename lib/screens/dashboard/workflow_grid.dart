import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/cards/workflow_action_card.dart';
import '../../widgets/icons/animated_line_icons/animated_line_icons.dart';

/// 2-Row workflow cards deck configured as 3 cards in the top row
/// and 2 cards in the bottom row to consume workstation space balancedly.
class WorkflowGrid extends StatelessWidget {
  const WorkflowGrid({
    required this.onSelectWorkflow,
    super.key,
  });

  final ValueChanged<WorkflowType> onSelectWorkflow;

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

  Widget _buildCard(
    BuildContext context,
    WorkflowType workflow, {
    required double height,
  }) {
    return SizedBox(
      height: height,
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
          onSelectWorkflow(workflow);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = Provider.of<AppState>(context);
    final List<WorkflowType> workflows = appState.availableWorkflows;

    return LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        final bool isCompact = constraints.maxWidth < 680;

        if (isCompact) {
          return _buildCompactDeck(context, workflows);
        }

        return _buildTwoRowDeck(context, workflows);
      },
    );
  }

  Widget _buildTwoRowDeck(BuildContext context, List<WorkflowType> workflows) {
    const double cardSpacing = 16.0;
    const double cardHeight = 144.0;

    final List<WorkflowType> topRowWorkflows = workflows.take(3).toList();
    final List<WorkflowType> bottomRowWorkflows = workflows.skip(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Top Row: 3 Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int workflowIndex = 0; workflowIndex < topRowWorkflows.length; workflowIndex++) ...<Widget>[
              if (workflowIndex > 0) const SizedBox(width: cardSpacing),
              Expanded(
                child: _buildCard(
                  context,
                  topRowWorkflows[workflowIndex],
                  height: cardHeight,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: cardSpacing),

        // Bottom Row: 2 Cards (consuming space evenly)
        if (bottomRowWorkflows.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int workflowIndex = 0; workflowIndex < bottomRowWorkflows.length; workflowIndex++) ...<Widget>[
                if (workflowIndex > 0) const SizedBox(width: cardSpacing),
                Expanded(
                  child: _buildCard(
                    context,
                    bottomRowWorkflows[workflowIndex],
                    height: cardHeight,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildCompactDeck(BuildContext context, List<WorkflowType> workflows) {
    const double cardSpacing = 12.0;
    const double cardHeight = 136.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int workflowIndex = 0; workflowIndex < workflows.length; workflowIndex++) ...<Widget>[
          if (workflowIndex > 0) const SizedBox(height: cardSpacing),
          _buildCard(
            context,
            workflows[workflowIndex],
            height: cardHeight,
          ),
        ],
      ],
    );
  }
}
