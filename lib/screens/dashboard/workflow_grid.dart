import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/cards/workflow_action_card.dart';

class WorkflowGrid extends StatelessWidget {
  const WorkflowGrid({
    required this.onSelectWorkflow,
    super.key,
  });

  final ValueChanged<WorkflowType> onSelectWorkflow;

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description_rounded;
      case 'badge':
        return Icons.badge_rounded;
      case 'vertical_split':
        return Icons.vertical_split_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'picture_as_pdf':
        return Icons.picture_as_pdf_rounded;
      case 'view_carousel':
        return Icons.view_carousel_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  /// Matches the exact 2x4 card theme alternating pattern in minimalist/WorkflowActionCard.js
  WorkflowCardTheme _resolveTheme(WorkflowType type) {
    switch (type) {
      case WorkflowType.flatbed:
        return WorkflowCardTheme.yellow;
      case WorkflowType.photoScan:
        return WorkflowCardTheme.light;
      case WorkflowType.bookletBatch:
        return WorkflowCardTheme.dark;
      case WorkflowType.cardDuplex:
        return WorkflowCardTheme.light;
      case WorkflowType.batchCardDeskew:
        return WorkflowCardTheme.yellow;
      case WorkflowType.compilePdf:
        return WorkflowCardTheme.dark;
      case WorkflowType.receiptArchive:
        return WorkflowCardTheme.light;
      case WorkflowType.legalStitch:
        return WorkflowCardTheme.yellow;
    }
  }

  String _resolveBadge(WorkflowType type) {
    switch (type) {
      case WorkflowType.flatbed:
        return 'A4 • 300 DPI';
      case WorkflowType.photoScan:
        return '4×6 • 600 DPI';
      case WorkflowType.bookletBatch:
        return '10s BATCH';
      case WorkflowType.cardDuplex:
        return 'DUPLEX • 600 DPI';
      case WorkflowType.batchCardDeskew:
        return 'AI VISION';
      case WorkflowType.compilePdf:
        return 'AUTO DPI';
      case WorkflowType.receiptArchive:
        return 'HALF PLATEN';
      case WorkflowType.legalStitch:
        return '2-PASS 14"';
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<WorkflowType> workflows = WorkflowType.values;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const int crossAxisCount = 2;
        const int rowCount = 4;
        const double spacing = 12.0;

        final double availableWidth =
            (constraints.maxWidth - spacing).clamp(200.0, 4000.0);
        final double itemWidth = availableWidth / crossAxisCount;
        final double availableHeight =
            (constraints.maxHeight - (spacing * (rowCount - 1))).clamp(320.0, 4000.0);
        final double itemHeight = (availableHeight / rowCount).clamp(96.0, 220.0);
        final double aspectRatio = (itemWidth / itemHeight).clamp(1.2, 3.8);

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: workflows.length,
          itemBuilder: (BuildContext context, int index) {
            final WorkflowType workflow = workflows[index];
            return WorkflowActionCard(
              title: workflow.title,
              subtitle: workflow.subtitle,
              icon: _resolveIcon(workflow.iconName),
              emojiIcon: workflow.emojiIcon,
              useEmoji: workflow.useEmoji,
              theme: _resolveTheme(workflow),
              badgeText: _resolveBadge(workflow),
              onTap: () {
                context.read<AppState>().selectWorkflow(workflow);
                onSelectWorkflow(workflow);
              },
            );
          },
        );
      },
    );
  }
}
