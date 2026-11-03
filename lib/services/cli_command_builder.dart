import 'package:path/path.dart' as p;
import '../models/scan_configuration_model.dart';

class CliCommandPlan {
  const CliCommandPlan({
    required this.scriptRelativePath,
    required this.arguments,
  });

  final String scriptRelativePath;
  final List<String> arguments;

  String toCommandLineString({String pythonExecutable = 'python'}) {
    final List<String> quotedArgs = arguments.map((String arg) {
      if (arg.contains(' ') || arg.contains('\\')) {
        return '"$arg"';
      }
      return arg;
    }).toList();
    return '$pythonExecutable $scriptRelativePath ${quotedArgs.join(' ')}';
  }
}

class CliCommandBuilder {
  static CliCommandPlan build(
    ScanConfigurationModel config, {
    String? cardSideSuffix,
  }) {
    switch (config.workflowType) {
      case WorkflowType.flatbed:
        final List<String> args = [
          'flatbed',
          '--paper-size',
          config.paperSize,
          '--dpi',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--output-dir',
          config.outputDirectory,
        ];
        if (config.fileNamePrefix.trim().isNotEmpty) {
          args.addAll(['--prefix', config.fileNamePrefix.trim()]);
        }
        if (config.rotation != 0) {
          args.addAll(['--rotate', '${config.rotation}']);
        }
        if (config.brightness != 0) {
          args.addAll(['--brightness', '${config.brightness}']);
        }
        if (config.contrast != 0) {
          args.addAll(['--contrast', '${config.contrast}']);
        }
        if (config.autoCrop) {
          args.add('--auto-crop');
        }
        if (config.paperSize == 'custom') {
          args.addAll([
            '--width',
            '${config.customWidth}',
            '--height',
            '${config.customHeight}',
            '--units',
            config.units,
            '--offset-x',
            '${config.offsetX}',
            '--offset-y',
            '${config.offsetY}',
          ]);
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.cardDuplex:
        final String basePrefix = config.fileNamePrefix.trim().isNotEmpty
            ? config.fileNamePrefix.trim()
            : 'card';
        final String effectivePrefix = cardSideSuffix != null
            ? '${basePrefix}_$cardSideSuffix'
            : basePrefix;
        final List<String> args = [
          'card',
          '--dpi',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--background',
          config.cardBackground,
          '--output-dir',
          config.outputDirectory,
          '--safety-inset-mm',
          '${config.safetyInsetMm}',
          '--corner-radius-mm',
          '${config.cornerRadiusMm}',
          '--prefix',
          effectivePrefix,
          '--no-prompt',
        ];
        if (config.noDeskew) {
          args.add('--no-deskew');
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.legalStitch:
        final List<String> args = [
          'legal-stitch',
          '--resolution',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--output-dir',
          config.outputDirectory,
        ];
        if (config.fileNamePrefix.trim().isNotEmpty) {
          args.addAll(['--name', config.fileNamePrefix.trim()]);
        }
        if (config.ipcMode) {
          args.add('--ipc-mode');
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.bookletBatch:
        final List<String> args = [
          'booklet',
          '--paper-size',
          config.paperSize,
          '--dpi',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--output-dir',
          config.outputDirectory,
          '--interval',
          '${config.intervalSeconds}',
        ];
        if (config.maxScans > 0) {
          args.addAll(['--max-scans', '${config.maxScans}']);
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.receiptArchive:
        final int effectiveMaxScans = config.maxScans > 0 ? config.maxScans : 1;
        final List<String> args = [
          'flatbed',
          '--preset',
          'boy-gatas-receipts',
          '--paper-size',
          config.paperSize,
          '--dpi',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--output-dir',
          config.outputDirectory,
          '--max-scans',
          '$effectiveMaxScans',
        ];
        if (config.fileNamePrefix.trim().isNotEmpty) {
          args.addAll(['--prefix', config.fileNamePrefix.trim()]);
        }
        if (config.brightness != 0) {
          args.addAll(['--brightness', '${config.brightness}']);
        }
        if (config.contrast != 0) {
          args.addAll(['--contrast', '${config.contrast}']);
        }
        if (config.autoCrop) {
          args.add('--auto-crop');
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.photoScan:
        final List<String> args = [
          'flatbed',
          '--preset',
          'photo-4x6',
          '--paper-size',
          config.paperSize,
          '--dpi',
          '${config.dpi}',
          '--color-mode',
          config.colorMode,
          '--format',
          config.format,
          '--output-dir',
          config.outputDirectory,
        ];
        if (config.fileNamePrefix.trim().isNotEmpty) {
          args.addAll(['--prefix', config.fileNamePrefix.trim()]);
        }
        if (config.rotation != 0) {
          args.addAll(['--rotate', '${config.rotation}']);
        }
        if (config.brightness != 0) {
          args.addAll(['--brightness', '${config.brightness}']);
        }
        if (config.contrast != 0) {
          args.addAll(['--contrast', '${config.contrast}']);
        }
        if (config.autoCrop) {
          args.add('--auto-crop');
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'scan_cli.py'),
          arguments: args,
        );

      case WorkflowType.compilePdf:
        final String outputFileName = config.fileNamePrefix.trim().isNotEmpty
            ? (config.fileNamePrefix.trim().toLowerCase().endsWith('.pdf')
                ? config.fileNamePrefix.trim()
                : '${config.fileNamePrefix.trim()}.pdf')
            : 'compiled_document.pdf';
        final List<String> args = [
          'compile-pdf',
          '--input-dir',
          config.outputDirectory,
          '--output-file',
          p.join(config.outputDirectory, outputFileName),
          '--paper-size',
          config.paperSize,
          '--fit-mode',
          config.fitMode,
          '--margin-mm',
          '${config.marginMm}',
        ];
        if (config.dpi > 0) {
          args.addAll(['--resolution', '${config.dpi}']);
        }
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'process_cli.py'),
          arguments: args,
        );

      case WorkflowType.batchCardDeskew:
        final List<String> args = [
          'cards',
          '--input-dir',
          config.outputDirectory,
          '--output-dir',
          config.outputDirectory,
          '--dpi',
          '${config.dpi}',
          '--format',
          config.format,
          '--background',
          config.cardBackground,
          '--safety-inset-mm',
          '${config.safetyInsetMm}',
          '--corner-radius-mm',
          '${config.cornerRadiusMm}',
        ];
        return CliCommandPlan(
          scriptRelativePath: p.join('scripts', 'process_cli.py'),
          arguments: args,
        );
    }
  }
}
