import 'package:flutter_test/flutter_test.dart';
import 'package:white_pepper/models/scan_configuration_model.dart';
import 'package:white_pepper/services/cli_command_builder.dart';

void main() {
  group('CliCommandBuilder Tests', () {
    test('Builds flatbed command with paper size, dpi, and color mode', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.flatbed,
        paperSize: 'a4',
        dpi: 300,
        colorMode: 'color',
        format: 'pdf',
      );

      final CliCommandPlan plan = CliCommandBuilder.build(config);
      expect(plan.scriptRelativePath, contains('scan_cli.py'));
      expect(plan.arguments, contains('flatbed'));
      expect(plan.arguments, contains('--paper-size'));
      expect(plan.arguments, contains('a4'));
      expect(plan.arguments, contains('--dpi'));
      expect(plan.arguments, contains('300'));
      expect(plan.arguments, contains('--format'));
      expect(plan.arguments, contains('pdf'));
    });

    test('Builds card duplex command with side suffix and --no-prompt', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.cardDuplex,
        dpi: 600,
        format: 'png',
        cardBackground: 'white',
        fileNamePrefix: 'Driver_ID',
      );

      final CliCommandPlan plan = CliCommandBuilder.build(
        config,
        cardSideSuffix: 'Front',
      );
      expect(plan.scriptRelativePath, contains('scan_cli.py'));
      expect(plan.arguments, contains('card'));
      expect(plan.arguments, contains('600'));
      expect(plan.arguments, contains('Driver_ID_Front'));
      expect(plan.arguments, contains('--no-prompt'));
      expect(plan.arguments, contains('white'));
    });

    test('Builds legal-stitch command with --ipc-mode', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.legalStitch,
        dpi: 600,
        format: 'pdf',
        ipcMode: true,
      );

      final CliCommandPlan plan = CliCommandBuilder.build(config);
      expect(plan.scriptRelativePath, contains('scan_cli.py'));
      expect(plan.arguments, contains('legal-stitch'));
      expect(plan.arguments, contains('--resolution'));
      expect(plan.arguments, contains('600'));
      expect(plan.arguments, contains('--ipc-mode'));
    });

    test('Builds compile-pdf command omitting --resolution when dpi is 0 (auto metadata)', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.compilePdf,
        paperSize: 'letter',
        marginMm: 10.0,
        dpi: 0,
      );

      final CliCommandPlan plan = CliCommandBuilder.build(config);
      expect(plan.scriptRelativePath, contains('process_cli.py'));
      expect(plan.arguments, contains('compile-pdf'));
      expect(plan.arguments, contains('--paper-size'));
      expect(plan.arguments, contains('letter'));
      expect(plan.arguments, contains('--margin-mm'));
      expect(plan.arguments, contains('10.0'));
      expect(plan.arguments.contains('--resolution'), isFalse);
    });
  });
}
