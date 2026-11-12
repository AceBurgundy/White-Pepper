import 'package:flutter_test/flutter_test.dart';
import 'package:white_pepper/models/scan_configuration_model.dart';
import 'package:white_pepper/models/scanner_device_model.dart';
import 'package:white_pepper/providers/app_state.dart';
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

    test('Appends eSCL Wi-Fi device targeting arguments when active', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.flatbed,
        selectedBackend: 'escl',
        selectedHost: '192.168.1.150',
        selectedPort: 8080,
      );

      final CliCommandPlan plan = CliCommandBuilder.build(config);
      expect(plan.arguments, contains('--backend'));
      expect(plan.arguments, contains('escl'));
      expect(plan.arguments, contains('--ip'));
      expect(plan.arguments, contains('192.168.1.150'));
      expect(plan.arguments, contains('--port'));
      expect(plan.arguments, contains('8080'));
    });

    test('Appends WIA USB device targeting arguments when active', () {
      final ScanConfigurationModel config = ScanConfigurationModel(
        workflowType: WorkflowType.flatbed,
        selectedBackend: 'wia',
        selectedDeviceId: '{6BDD1FC6-810F-11D0-BEC7-08002BE2092F}\\0000',
      );

      final CliCommandPlan plan = CliCommandBuilder.build(config);
      expect(plan.arguments, contains('--backend'));
      expect(plan.arguments, contains('wia'));
      expect(plan.arguments, contains('--device-id'));
      expect(plan.arguments, contains('{6BDD1FC6-810F-11D0-BEC7-08002BE2092F}\\0000'));
    });
  });

  group('ScannerDeviceModel & Zero-Touch State Tests', () {
    test('ScannerDeviceModel serializes and deserializes correctly', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'escl:test-uuid-1234',
        'name': 'HP Smart Tank 580 series',
        'transport': 'wifi',
        'host': '192.168.1.180',
        'port': 8080,
        'device_id': '',
        'reachable': true,
      };

      final ScannerDeviceModel model = ScannerDeviceModel.fromJson(json);
      expect(model.id, equals('escl:test-uuid-1234'));
      expect(model.name, equals('HP Smart Tank 580 series'));
      expect(model.connectionType, equals(ScannerConnectionType.wifi));
      expect(model.connectionLabel, equals('Wi-Fi'));
      expect(model.host, equals('192.168.1.180'));
      expect(model.port, equals(8080));
      expect(model.isOnline, isTrue);

      final Map<String, dynamic> outputJson = model.toJson();
      expect(outputJson['id'], equals('escl:test-uuid-1234'));
      expect(outputJson['transport'], equals('wifi'));
    });

    test('AppState selectScanner updates activeScanner, scannerModel, and config transport', () {
      final AppState state = AppState();
      const ScannerDeviceModel usbScanner = ScannerDeviceModel(
        id: 'wia:usb-device-001',
        name: 'Canon CanoScan LiDE 300',
        connectionType: ScannerConnectionType.usb,
        deviceId: 'device-guid-xyz',
        isOnline: true,
      );

      state.selectScanner(usbScanner);

      expect(state.activeScanner, equals(usbScanner));
      expect(state.scannerModel, equals('Canon CanoScan LiDE 300'));
      expect(state.isScannerOnline, isTrue);
      expect(state.scannerConnectionLabel, equals('USB • Ready'));
      expect(state.config.selectedBackend, equals('wia'));
      expect(state.config.selectedDeviceId, equals('device-guid-xyz'));
    });
  });
}
