import 'package:flutter/material.dart';
import 'scan_configuration_model.dart';

enum PeaPodToolType {
  layout(
    identifier: 'layout',
    label: 'Paper',
    displayTitle: 'Paper Size',
    icon: Icons.grid_view_rounded,
  ),
  tune(
    identifier: 'tune',
    label: 'DPI',
    displayTitle: 'Scan Resolution',
    icon: Icons.tune_rounded,
  ),
  contrast(
    identifier: 'contrast',
    label: 'Color',
    displayTitle: 'Color & Mode',
    icon: Icons.contrast_rounded,
  ),
  rotate(
    identifier: 'rotate',
    label: 'Rotate',
    displayTitle: 'Page Rotation',
    icon: Icons.rotate_90_degrees_cw_rounded,
  ),
  crop(
    identifier: 'crop',
    label: 'Geometry',
    displayTitle: 'Crop & Alignment',
    icon: Icons.crop_rounded,
  ),
  title(
    identifier: 'title',
    label: 'Output',
    displayTitle: 'Output & Storage',
    icon: Icons.title_rounded,
  );

  const PeaPodToolType({
    required this.identifier,
    required this.label,
    required this.displayTitle,
    required this.icon,
  });

  final String identifier;
  final String label;
  final String displayTitle;
  final IconData icon;

  /// Returns the ordered list of parameter tools applicable to a given CLI workflow.
  static List<PeaPodToolType> toolsForWorkflow(WorkflowType workflow) {
    switch (workflow) {
      case WorkflowType.flatbed:
      case WorkflowType.photoScan:
        return const <PeaPodToolType>[
          PeaPodToolType.layout,
          PeaPodToolType.tune,
          PeaPodToolType.contrast,
          PeaPodToolType.rotate,
          PeaPodToolType.crop,
          PeaPodToolType.title,
        ];
      case WorkflowType.receiptArchive:
      case WorkflowType.bookletBatch:
        return const <PeaPodToolType>[
          PeaPodToolType.layout,
          PeaPodToolType.tune,
          PeaPodToolType.crop,
          PeaPodToolType.contrast,
          PeaPodToolType.title,
        ];
      case WorkflowType.cardDuplex:
        return const <PeaPodToolType>[
          PeaPodToolType.tune,
          PeaPodToolType.crop,
          PeaPodToolType.contrast,
          PeaPodToolType.title,
        ];
      case WorkflowType.legalStitch:
        return const <PeaPodToolType>[
          PeaPodToolType.tune,
          PeaPodToolType.contrast,
          PeaPodToolType.title,
        ];
      case WorkflowType.compilePdf:
        return const <PeaPodToolType>[
          PeaPodToolType.layout,
          PeaPodToolType.crop,
          PeaPodToolType.tune,
          PeaPodToolType.title,
        ];
      case WorkflowType.batchCardDeskew:
        return const <PeaPodToolType>[
          PeaPodToolType.tune,
          PeaPodToolType.crop,
          PeaPodToolType.title,
        ];
    }
  }
}
