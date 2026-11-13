import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../models/ipc_event.dart';
import '../models/peapod_tool.dart';
import '../models/scan_configuration_model.dart';
import '../models/scanner_device_model.dart';
import '../services/cli_command_builder.dart';
import '../services/scanner_process_service.dart';
import '../widgets/buttons/progress_button.dart';

enum AppScreen {
  dashboard,
  options,
  instructions,
}

class WorkflowInstructionStep {
  const WorkflowInstructionStep({
    required this.stepNumber,
    required this.totalSteps,
    required this.badgeLabel,
    required this.headline,
    required this.physicalInstruction,
    required this.subInstruction,
    required this.actionButtonLabel,
    required this.schematicMode,
  });

  final int stepNumber;
  final int totalSteps;
  final String badgeLabel;
  final String headline;
  final String physicalInstruction;
  final String subInstruction;
  final String actionButtonLabel;
  final String schematicMode;
}

class AppState extends ChangeNotifier {
  AppState({
    ScannerProcessService? processService,
  }) : _processService = processService ?? ScannerProcessService();

  final ScannerProcessService _processService;

  AppScreen _currentScreen = AppScreen.dashboard;
  ScanConfigurationModel _config = ScanConfigurationModel();
  PeaPodToolType _activeTool = PeaPodToolType.layout;
  ProgressButtonState _scanButtonState = ProgressButtonState.idle;
  final List<String> _consoleLogs = <String>[];
  final List<String> _generatedFiles = <String>[];
  IpcEvent? _activeIpcEvent;
  String? _lastGeneratedFilePath;

  int _currentStepIndex = 0;
  bool _isAwaitingUserConfirmation = true;
  bool _pendingLegalInitialConfirmation = false;

  bool _isScannerOnline = true;
  String _scannerModel = 'HP DeskJet / Wireless eSCL';
  String _scannerEndpoint = '192.168.1.150:8080';
  bool _isDarkMode = false;

  List<ScannerDeviceModel> _availableScanners = const <ScannerDeviceModel>[];
  ScannerDeviceModel? _activeScanner;
  bool _isDiscoveringScanners = false;

  int _compilePdfPageCount = 0;
  String? _compilePdfStagingPath;
  Timer? _compilePdfCountdownTimer;
  int _compilePdfCountdownSeconds = 0;

  Timer? _cardFlipTimer;
  int _cardFlipCountdownSeconds = 0;

  // Getters
  AppScreen get currentScreen => _currentScreen;
  ScanConfigurationModel get config => _config;
  PeaPodToolType get activeTool => _activeTool;
  ProgressButtonState get scanButtonState => _scanButtonState;
  List<String> get consoleLogs => List<String>.unmodifiable(_consoleLogs);
  List<String> get generatedFiles => List<String>.unmodifiable(_generatedFiles);
  IpcEvent? get activeIpcEvent => _activeIpcEvent;
  String? get lastGeneratedFilePath => _lastGeneratedFilePath;
  int get currentStepIndex => _currentStepIndex;
  bool get isAwaitingUserConfirmation => _isAwaitingUserConfirmation;
  bool get isScannerOnline => _isScannerOnline;
  String get scannerModel => _scannerModel;
  String get scannerEndpoint => _scannerEndpoint;
  bool get isDarkMode => _isDarkMode;

  List<ScannerDeviceModel> get availableScanners => _availableScanners;
  ScannerDeviceModel? get activeScanner => _activeScanner;
  bool get isDiscoveringScanners => _isDiscoveringScanners;
  bool get isLegalStitchSupportedByHardware => _activeScanner?.supportsLegal ?? false;
  bool get isLegalStitchCardVisible => !isLegalStitchSupportedByHardware;
  int get compilePdfPageCount => _compilePdfPageCount;
  String? get compilePdfStagingPath => _compilePdfStagingPath;
  int get compilePdfCountdownSeconds => _compilePdfCountdownSeconds;
  int get cardFlipCountdownSeconds => _cardFlipCountdownSeconds;

  String get scannerConnectionLabel {
    if (_activeScanner != null) {
      final String status = _isScannerOnline ? 'Ready' : 'Offline';
      return '${_activeScanner!.connectionLabel} • $status';
    }
    return _isScannerOnline ? 'Wi-Fi • Ready' : 'Offline';
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  List<PeaPodToolType> get availableTools =>
      PeaPodToolType.toolsForWorkflow(_config.workflowType);

  String get currentCommandPreview =>
      CliCommandBuilder.build(_config).toCommandLineString();

  List<WorkflowInstructionStep> get workflowSteps {
    final WorkflowType wf = _config.workflowType;
    switch (wf) {
      case WorkflowType.legalStitch:
        return const <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 3,
            badgeLabel: 'Step 1 of 3 • Pass 1 (Top Upright)',
            headline: 'Place Paper\nUPRIGHT',
            physicalInstruction:
                'Align the top-left corner of the 8.5" × 14.0" US Legal sheet into the scanner glass origin markings (0,0).',
            subInstruction:
                'The top 11.0" Letter area covers 100% of the glass — completely eliminating the bottom shadow gradient.',
            actionButtonLabel: 'Scan Pass 1 (Top 11.0")',
            schematicMode: 'legal_pass_1',
          ),
          WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 3,
            badgeLabel: 'Step 2 of 3 • Pass 2 (180° Upside-Down)',
            headline: 'Rotate Sheet\n180° Upside-Down',
            physicalInstruction:
                'Rotate the Legal sheet 180° upside-down and align the opposite bottom edge flush against the top-left markings.',
            subInstruction:
                'Pass 2 captures the remaining 3.0" legal tail with an 8.0" overlap for automatic alignment and seamless stitching.',
            actionButtonLabel: 'Scan Pass 2 & Auto-Stitch',
            schematicMode: 'legal_pass_2',
          ),
          WorkflowInstructionStep(
            stepNumber: 3,
            totalSteps: 3,
            badgeLabel: 'Step 3 of 3 • Reconstruction Complete',
            headline: 'Legal Document\nStitched!',
            physicalInstruction:
                'Both passes have been aligned and stitched into a seamless 8.5" × 14.0" Legal document.',
            subInstruction:
                'Physical DPI metadata is embedded directly into the output document.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.cardDuplex:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 3,
            badgeLabel: 'Step 1 of 3 • Front Side (${_config.dpi} DPI)',
            headline: 'Place Card\nFRONT DOWN',
            physicalInstruction:
                'Place the card FRONT DOWN on the glass corner with 0.5 inch space away from the corner.',
            subInstruction:
                'A 4.0" × 4.0" window is scanned, contour-deskewed, and masked to rounded corners with transparent background.',
            actionButtonLabel: 'Scan Front Side',
            schematicMode: 'card_front',
          ),
          WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 3,
            badgeLabel: 'Step 2 of 3 • Back Side (${_config.dpi} DPI)',
            headline: 'Flip Card\nBACK DOWN',
            physicalInstruction:
                'Flip the card BACK DOWN in the same position with 0.5 inch space away from the corner.',
            subInstruction: _cardFlipCountdownSeconds > 0
                ? 'Auto-scan starting in ${_cardFlipCountdownSeconds}s... Click Scan Back Side to proceed immediately.'
                : 'Click "Scan Back Side" or let the countdown timer trigger automatically.',
            actionButtonLabel: 'Scan Back Side',
            schematicMode: 'card_back',
          ),
          WorkflowInstructionStep(
            stepNumber: 3,
            totalSteps: 3,
            badgeLabel: 'Step 3 of 3 • Duplex Extraction Complete',
            headline: 'Front & Back\nSaved as PNG!',
            physicalInstruction:
                'Both card sides have been contour-deskewed, alpha-masked to rounded corners, and saved with embedded DPI.',
            subInstruction:
                'Saved as "${_config.fileNamePrefix.isNotEmpty ? _config.fileNamePrefix : "Card"} - Front.png" and "${_config.fileNamePrefix.isNotEmpty ? _config.fileNamePrefix : "Card"} - Back.png".',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.compilePdf:
        if (_compilePdfPageCount == 0) {
          return <WorkflowInstructionStep>[
            WorkflowInstructionStep(
              stepNumber: 1,
              totalSteps: 2,
              badgeLabel:
                  'Batch Scan Setup • ${_config.paperSize.toUpperCase()} @ ${_config.dpi <= 0 ? 300 : _config.dpi} DPI',
              headline: 'Place Page 1\non Platen Glass',
              physicalInstruction:
                  'Place the first document page face-down against the top-left platen corner (0,0) and close the scanner lid.',
              subInstruction: _config.intervalSeconds > 0
                  ? 'Auto-scan timer: ${_config.intervalSeconds}s cadence enabled between pages.'
                  : 'Manual multi-page mode: Click trigger to scan each page.',
              actionButtonLabel: 'Scan Page 1',
              schematicMode: 'platen_sheet',
            ),
            WorkflowInstructionStep(
              stepNumber: 2,
              totalSteps: 2,
              badgeLabel: 'Batch Scan Complete',
              headline: 'Batch Scan\nComplete!',
              physicalInstruction:
                  'All scanned pages have been processed and saved into .${_config.format.toUpperCase()} format.',
              subInstruction: 'Open the generated output below.',
              actionButtonLabel: 'Done',
              schematicMode: 'completed',
            ),
          ];
        } else if (_scanButtonState != ProgressButtonState.completed) {
          final int nextPageNumber = _compilePdfPageCount + 1;
          final String autoNote = _compilePdfCountdownSeconds > 0
              ? 'Auto-scan starting in ${_compilePdfCountdownSeconds}s... '
              : '';
          return <WorkflowInstructionStep>[
            WorkflowInstructionStep(
              stepNumber: nextPageNumber,
              totalSteps: nextPageNumber + 1,
              badgeLabel:
                  'Page $nextPageNumber • $_compilePdfPageCount Page${_compilePdfPageCount == 1 ? "" : "s"} Captured',
              headline: 'Replace Paper\nfor Page $nextPageNumber',
              physicalInstruction:
                  'Remove the scanned sheet and place page $nextPageNumber on the platen glass.',
              subInstruction:
                  '${autoNote}Click "Scan Page $nextPageNumber" to continue, or "Stop Early" to finalize as .${_config.format.toUpperCase()}.',
              actionButtonLabel: 'Scan Page $nextPageNumber',
              schematicMode: 'platen_sheet',
            ),
            WorkflowInstructionStep(
              stepNumber: 2,
              totalSteps: 2,
              badgeLabel: 'Batch Scan Complete',
              headline: 'Batch Scan\nComplete!',
              physicalInstruction:
                  'All scanned pages have been processed and saved into .${_config.format.toUpperCase()} format.',
              subInstruction: 'Open the generated output below.',
              actionButtonLabel: 'Done',
              schematicMode: 'completed',
            ),
          ];
        } else {
          return <WorkflowInstructionStep>[
            WorkflowInstructionStep(
              stepNumber: 1,
              totalSteps: 1,
              badgeLabel: 'Batch Scan Complete • $_compilePdfPageCount Pages',
              headline: 'Batch Scan\nComplete!',
              physicalInstruction:
                  'All $_compilePdfPageCount pages have been saved into .${_config.format.toUpperCase()} format.',
              subInstruction: 'Open the generated output below.',
              actionButtonLabel: 'Done',
              schematicMode: 'completed',
            ),
          ];
        }

      case WorkflowType.flatbed:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 2,
            badgeLabel:
                'Step 1 of 2 • Align ${_config.paperSize.toUpperCase()} @ ${_config.dpi} DPI',
            headline: 'Align Document\non Platen Glass',
            physicalInstruction:
                'Place your document or photo face-down flush with the top-left platen origin mark (0,0) and close the scanner lid.',
            subInstruction:
                'Target: ${_config.paperSize.toUpperCase()} • ${_config.dpi} DPI • ${_config.colorMode.toUpperCase()} • .${_config.format.toUpperCase()}',
            actionButtonLabel: 'Start Optical Scan',
            schematicMode: 'platen_sheet',
          ),
          const WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 2,
            badgeLabel: 'Step 2 of 2 • Acquisition Complete',
            headline: 'Scan Saved\nSuccessfully!',
            physicalInstruction:
                'Document scanned, cropped, and saved successfully with high resolution clarity.',
            subInstruction: 'Open the scanned file or folder below.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.customPlaten:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 2,
            badgeLabel:
                'Step 1 of 2 • Custom Region (${_config.customWidth} × ${_config.customHeight} ${_config.units})',
            headline: 'Align Target Area\non Platen Glass',
            physicalInstruction:
                'Position your material on the platen within the designated custom capture coordinates.',
            subInstruction:
                'Region: ${_config.customWidth}${_config.units} × ${_config.customHeight}${_config.units} @ ${_config.dpi} DPI • ${_config.colorMode.toUpperCase()}',
            actionButtonLabel: 'Scan Custom Region',
            schematicMode: 'platen_sheet',
          ),
          const WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 2,
            badgeLabel: 'Step 2 of 2 • Acquisition Complete',
            headline: 'Custom Region\nSaved!',
            physicalInstruction:
                'Custom boundary scanned and clipped successfully.',
            subInstruction: 'Open the scanned file or folder below.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];
    }
  }

  WorkflowInstructionStep get currentInstructionStep {
    final List<WorkflowInstructionStep> steps = workflowSteps;
    final int safeIndex = _currentStepIndex.clamp(0, steps.length - 1);
    return steps[safeIndex];
  }

  void switchScreen(AppScreen targetScreen) {
    _currentScreen = targetScreen;
    notifyListeners();
  }

  void selectWorkflow(WorkflowType workflow) {
    final String previousUnits = _config.units;
    final String previousOutputDirectory = _config.outputDirectory;
    final String? previousBackend = _config.selectedBackend;
    final String? previousHost = _config.selectedHost;
    final int? previousPort = _config.selectedPort;
    final String? previousDeviceId = _config.selectedDeviceId;

    _config = ScanConfigurationModel(
      workflowType: workflow,
      units: previousUnits,
      outputDirectory: previousOutputDirectory,
      selectedBackend: previousBackend,
      selectedHost: previousHost,
      selectedPort: previousPort,
      selectedDeviceId: previousDeviceId,
    );

    switch (workflow) {
      case WorkflowType.flatbed:
        _config.paperSize = 'a4';
        _config.dpi = 300;
        _config.format = 'pdf';
        _config.colorMode = 'color';
      case WorkflowType.cardDuplex:
        _config.paperSize = 'id-card';
        _config.dpi = 600;
        _config.format = 'png';
        _config.cardBackground = 'transparent';
        _config.cardDuplexTwoSided = true;
        _config.intervalSeconds = 5;
        _cardFlipCountdownSeconds = 0;
        _cancelCardFlipTimer();
      case WorkflowType.legalStitch:
        _config.paperSize = 'legal';
        _config.dpi = 300;
        _config.format = 'pdf';
        _config.ipcMode = true;
      case WorkflowType.compilePdf:
        _config.paperSize = 'full';
        _config.dpi = 300;
        _config.fitMode = 'contain';
        _config.format = 'pdf';
        _config.intervalSeconds = 0;
        _config.fileNamePrefix = 'batch_scan';
        _compilePdfPageCount = 0;
        _compilePdfCountdownSeconds = 0;
        _cancelCompilePdfTimer();
        _cleanUpCompilePdfStaging();
      case WorkflowType.customPlaten:
        _config.paperSize = 'custom';
        if (_config.units == 'in') {
          _config.customWidth = 6.0;
          _config.customHeight = 8.0;
        } else {
          _config.customWidth = 152.0;
          _config.customHeight = 203.0;
        }
        _config.dpi = 300;
        _config.format = 'pdf';
    }

    final List<PeaPodToolType> validTools = availableTools;
    _activeTool = validTools.first;
    _scanButtonState = ProgressButtonState.idle;
    _consoleLogs.clear();
    _generatedFiles.clear();
    _activeIpcEvent = null;
    _lastGeneratedFilePath = null;
    _currentStepIndex = 0;
    _isAwaitingUserConfirmation = true;
    _currentScreen = AppScreen.options;
    notifyListeners();
  }

  void resetCurrentWorkflowDefaults() {
    selectWorkflow(_config.workflowType);
  }

  void updateConfig(ScanConfigurationModel newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void setActiveTool(PeaPodToolType tool) {
    _activeTool = tool;
    notifyListeners();
  }

  /// Transitions from Options Screen to Step-by-Step Instructions Screen.
  void beginInstructionsWorkflow() {
    if (_processService.isRunning) {
      _processService.cancelActiveProcess();
    }
    _scanButtonState = ProgressButtonState.idle;
    _consoleLogs.clear();
    _generatedFiles.clear();
    _activeIpcEvent = null;
    _lastGeneratedFilePath = null;
    _currentStepIndex = 0;
    _isAwaitingUserConfirmation = true;
    _pendingLegalInitialConfirmation = false;
    if (_config.workflowType == WorkflowType.compilePdf) {
      _compilePdfPageCount = 0;
      _compilePdfCountdownSeconds = 0;
      _cancelCompilePdfTimer();
      _cleanUpCompilePdfStaging();
    }
    if (_config.workflowType == WorkflowType.cardDuplex) {
      _cancelCardFlipTimer();
      _cardFlipCountdownSeconds = 0;
    }
    _currentScreen = AppScreen.instructions;
    notifyListeners();
  }

  /// Triggered when the user clicks or holds the primary action button on InstructionsScreen.
  void triggerCurrentInstructionStep() {
    if (_scanButtonState == ProgressButtonState.completed) {
      switchScreen(AppScreen.dashboard);
      return;
    }

    // Legal 2-Pass Stitch uses interactive stdin IPC with scan_cli.py legal-stitch --ipc-mode
    if (_config.workflowType == WorkflowType.legalStitch) {
      if (!_processService.isRunning) {
        _pendingLegalInitialConfirmation = true;
        _isAwaitingUserConfirmation = false;
        _launchSubprocess(CliCommandBuilder.build(_config));
      } else if (_isAwaitingUserConfirmation) {
        _isAwaitingUserConfirmation = false;
        notifyListeners();
        _processService.sendStdinLine('');
      }
      return;
    }

    // ID Card Duplex 2-step guided front & back capture
    if (_config.workflowType == WorkflowType.cardDuplex) {
      if (_processService.isRunning) return;
      _cancelCardFlipTimer();
      _isAwaitingUserConfirmation = false;
      final String sideSuffix = _currentStepIndex == 0 ? 'Front' : 'Back';
      final CliCommandPlan plan = CliCommandBuilder.build(
        _config,
        cardSideSuffix: sideSuffix,
      );
      _launchSubprocess(
        plan,
        onStepProcessSuccess: () {
          if (_currentStepIndex == 0) {
            // Advance to Step 2 (Flip to Back side) and wait for user confirmation
            _currentStepIndex = 1;
            _scanButtonState = ProgressButtonState.idle;
            _isAwaitingUserConfirmation = true;
            _consoleLogs.add(
              '[STEP 1 COMPLETE] Front side saved. Flip card to BACK side and trigger Step 2.',
            );
            if (_config.intervalSeconds > 0) {
              _startCardFlipCountdown();
            }
            notifyListeners();
          } else {
            _currentStepIndex = 2;
            _scanButtonState = ProgressButtonState.completed;
            _isAwaitingUserConfirmation = false;
            notifyListeners();
          }
        },
      );
      return;
    }

    // Multi-page guided PDF compilation workflow
    if (_config.workflowType == WorkflowType.compilePdf) {
      if (_processService.isRunning) return;
      _cancelCompilePdfTimer();
      _isAwaitingUserConfirmation = false;
      _ensureCompilePdfStagingDirectory();

      final int targetPageNumber = _compilePdfPageCount + 1;
      final CliCommandPlan pageScanPlan = CliCommandBuilder.buildCompilePdfPageScanPlan(
        _config,
        _compilePdfStagingPath!,
        targetPageNumber,
      );

      _launchSubprocess(
        pageScanPlan,
        onStepProcessSuccess: () {
          _compilePdfPageCount = targetPageNumber;
          _scanButtonState = ProgressButtonState.idle;
          _isAwaitingUserConfirmation = true;
          _consoleLogs.add(
            '[PAGE $targetPageNumber CAPTURED] Page $targetPageNumber added to session staging buffer.',
          );
          if (_config.intervalSeconds > 0) {
            _startCompilePdfCountdown();
          }
          notifyListeners();
        },
      );
      return;
    }

    // Standard single-command workflow (Flatbed, Photo, Receipt, Booklet, Batch Cards, Single-Sided Card)
    if (!_processService.isRunning) {
      _isAwaitingUserConfirmation = false;
      if (workflowSteps.length > 2) {
        _currentStepIndex = 1;
      }
      _launchSubprocess(CliCommandBuilder.build(_config));
    }
  }

  void startScan() {
    beginInstructionsWorkflow();
    triggerCurrentInstructionStep();
  }

  void _launchSubprocess(
    CliCommandPlan plan, {
    VoidCallback? onStepProcessSuccess,
  }) {
    _scanButtonState = ProgressButtonState.processing;
    _consoleLogs.add('\$ ${plan.toCommandLineString()}');
    notifyListeners();

    try {
      final Stream<String> stream = _processService.execute(
        plan,
        onIpcEvent: (IpcEvent event) {
          _activeIpcEvent = event;
          if (event.type == IpcEventType.stepPrompt) {
            if (event.step == 1 && _pendingLegalInitialConfirmation) {
              _pendingLegalInitialConfirmation = false;
              _isAwaitingUserConfirmation = false;
              _processService.sendStdinLine('');
            } else if (event.step == 2) {
              _currentStepIndex = 1;
              _isAwaitingUserConfirmation = true;
            }
          } else if (event.type == IpcEventType.stitching) {
            _isAwaitingUserConfirmation = false;
          } else if (event.type == IpcEventType.completed) {
            _currentStepIndex = workflowSteps.length - 1;
            _isAwaitingUserConfirmation = false;
            _scanButtonState = ProgressButtonState.completed;
          } else if (event.type == IpcEventType.error) {
            _scanButtonState = ProgressButtonState.error;
            _isAwaitingUserConfirmation = true;
          }
          if (event.outputPath != null && event.outputPath!.isNotEmpty) {
            _recordGeneratedFile(event.outputPath!);
          }
          notifyListeners();
        },
      );

      stream.listen(
        (String line) {
          _consoleLogs.add(line);
          _extractSavedFilePathFromLog(line);
          if (line.startsWith('[exit] Process completed with code ')) {
            final String codeStr = line.replaceFirst(
              '[exit] Process completed with code ',
              '',
            ).trim();
            final int? exitCode = int.tryParse(codeStr);
            if (exitCode != null && exitCode != 0) {
              _scanButtonState = ProgressButtonState.error;
              _isAwaitingUserConfirmation = true;
            }
          }
          notifyListeners();
        },
        onError: (dynamic error) {
          _consoleLogs.add('[ERROR] $error');
          _scanButtonState = ProgressButtonState.error;
          _isAwaitingUserConfirmation = true;
          notifyListeners();
        },
        onDone: () {
          if (_scanButtonState != ProgressButtonState.error) {
            if (onStepProcessSuccess != null) {
              onStepProcessSuccess();
            } else {
              _currentStepIndex = workflowSteps.length - 1;
              _scanButtonState = ProgressButtonState.completed;
              _isAwaitingUserConfirmation = false;
            }
          }
          notifyListeners();
        },
      );
    } catch (exception) {
      _consoleLogs.add('[EXECUTION EXCEPTION] $exception');
      _scanButtonState = ProgressButtonState.error;
      _isAwaitingUserConfirmation = true;
      notifyListeners();
    }
  }

  void _extractSavedFilePathFromLog(String line) {
    final List<String> markers = <String>[
      '[Success] Scanned file saved:',
      '[Success] Saved:',
      '[Success] Extracted ID-1 Card:',
      '[Success] Raw card capture saved:',
      '[Success] Stitched US Legal Document:',
      '[Success] Compiled PDF document:',
      '[Success] Compiled booklet PDF:',
      '-> Extracted ID-1 card:',
      '[SAVED]',
      '[Saved]',
      'saved to:',
    ];
    for (final String marker in markers) {
      final int markerIdx = line.indexOf(marker);
      if (markerIdx != -1) {
        String candidate = line.substring(markerIdx + marker.length).trim();
        final int parenIdx = candidate.indexOf(' (');
        if (parenIdx != -1) {
          candidate = candidate.substring(0, parenIdx).trim();
        }
        if (candidate.isNotEmpty) {
          _recordGeneratedFile(candidate);
        }
      }
    }
  }

  void _recordGeneratedFile(String path) {
    _lastGeneratedFilePath = path;
    if (!_generatedFiles.contains(path)) {
      _generatedFiles.add(path);
    }
  }

  void sendStdinProceed() {
    _isAwaitingUserConfirmation = false;
    notifyListeners();
    _processService.sendStdinLine('');
  }

  /// Finalizes the multi-page batch scan session by bundling all scanned pages in staging.
  void finishAndCompilePdf() {
    if (_processService.isRunning) return;
    _cancelCompilePdfTimer();
    if (_compilePdfStagingPath == null || _compilePdfPageCount == 0) {
      _consoleLogs.add('[WARNING] No pages scanned yet to save.');
      return;
    }

    final String format = _config.format.toLowerCase();
    if (format != 'pdf') {
      _isAwaitingUserConfirmation = false;
      _scanButtonState = ProgressButtonState.processing;
      notifyListeners();

      try {
        final Directory stagingDirectory = Directory(_compilePdfStagingPath!);
        final List<FileSystemEntity> files = stagingDirectory
            .listSync()
            .where((FileSystemEntity fileEntity) => fileEntity is File)
            .toList()
          ..sort((FileSystemEntity firstEntity, FileSystemEntity secondEntity) =>
              firstEntity.path.compareTo(secondEntity.path));

        final String cleanPrefix = _config.fileNamePrefix.trim().isNotEmpty
            ? _config.fileNamePrefix.trim()
            : 'batch_scan';

        int pageIndex = 1;
        for (final FileSystemEntity entity in files) {
          if (entity is File) {
            final String paddedNumber = pageIndex.toString().padLeft(2, '0');
            final String targetFileName = '${cleanPrefix}_page_$paddedNumber.$format';
            final String destinationPath = p.join(_config.outputDirectory, targetFileName);
            entity.copySync(destinationPath);
            _recordGeneratedFile(destinationPath);
            pageIndex++;
          }
        }
        _scanButtonState = ProgressButtonState.completed;
        _consoleLogs.add(
          '[SUCCESS] All $_compilePdfPageCount pages saved as .$format to ${_config.outputDirectory}',
        );
        _cleanUpCompilePdfStaging();
        notifyListeners();
      } catch (saveException) {
        _scanButtonState = ProgressButtonState.error;
        _consoleLogs.add('[ERROR] Failed to save batch images: $saveException');
        _isAwaitingUserConfirmation = true;
        notifyListeners();
      }
      return;
    }

    _isAwaitingUserConfirmation = false;
    final CliCommandPlan assemblyPlan = CliCommandBuilder.buildCompilePdfFinalAssemblyPlan(
      _config,
      _compilePdfStagingPath!,
    );

    _launchSubprocess(
      assemblyPlan,
      onStepProcessSuccess: () {
        _scanButtonState = ProgressButtonState.completed;
        _isAwaitingUserConfirmation = false;
        _consoleLogs.add(
          '[SUCCESS] All $_compilePdfPageCount pages compiled into unified PDF document.',
        );
        _cleanUpCompilePdfStaging();
        notifyListeners();
      },
    );
  }

  void _ensureCompilePdfStagingDirectory() {
    if (_compilePdfStagingPath == null) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _compilePdfStagingPath = p.join(
        _config.outputDirectory,
        '.staging_pdf_$timestamp',
      );
      final Directory stagingDirectory = Directory(_compilePdfStagingPath!);
      if (!stagingDirectory.existsSync()) {
        stagingDirectory.createSync(recursive: true);
      }
    }
  }

  void _startCompilePdfCountdown() {
    _cancelCompilePdfTimer();
    _compilePdfCountdownSeconds = _config.intervalSeconds;
    notifyListeners();

    _compilePdfCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_compilePdfCountdownSeconds <= 1) {
          _cancelCompilePdfTimer();
          if (_scanButtonState != ProgressButtonState.processing &&
              _config.workflowType == WorkflowType.compilePdf &&
              _currentScreen == AppScreen.instructions) {
            triggerCurrentInstructionStep();
          }
        } else {
          _compilePdfCountdownSeconds -= 1;
          notifyListeners();
        }
      },
    );
  }

  void _startCardFlipCountdown() {
    _cancelCardFlipTimer();
    _cardFlipCountdownSeconds = _config.intervalSeconds;
    notifyListeners();

    _cardFlipTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_cardFlipCountdownSeconds <= 1) {
          _cancelCardFlipTimer();
          if (_scanButtonState != ProgressButtonState.processing &&
              _config.workflowType == WorkflowType.cardDuplex &&
              _currentStepIndex == 1 &&
              _currentScreen == AppScreen.instructions) {
            triggerCurrentInstructionStep();
          }
        } else {
          _cardFlipCountdownSeconds -= 1;
          notifyListeners();
        }
      },
    );
  }

  void cancelCountdownTimer() {
    _cancelCompilePdfTimer();
    _cancelCardFlipTimer();
    notifyListeners();
  }

  void _cancelCompilePdfTimer() {
    _compilePdfCountdownTimer?.cancel();
    _compilePdfCountdownTimer = null;
    _compilePdfCountdownSeconds = 0;
  }

  void _cancelCardFlipTimer() {
    _cardFlipTimer?.cancel();
    _cardFlipTimer = null;
    _cardFlipCountdownSeconds = 0;
  }

  void _cleanUpCompilePdfStaging() {
    if (_compilePdfStagingPath != null) {
      try {
        final Directory stagingDirectory = Directory(_compilePdfStagingPath!);
        if (stagingDirectory.existsSync()) {
          stagingDirectory.deleteSync(recursive: true);
        }
      } catch (cleanUpException) {
        _consoleLogs.add('[CLEANUP EXCEPTION] $cleanUpException');
      }
      _compilePdfStagingPath = null;
    }
  }

  void cancelScan() {
    _cancelCompilePdfTimer();
    _cancelCardFlipTimer();
    _cleanUpCompilePdfStaging();
    _compilePdfPageCount = 0;
    _processService.cancelActiveProcess();
    _scanButtonState = ProgressButtonState.idle;
    _activeIpcEvent = null;
    _isAwaitingUserConfirmation = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelCompilePdfTimer();
    _cancelCardFlipTimer();
    _cleanUpCompilePdfStaging();
    super.dispose();
  }

  void selectScanner(ScannerDeviceModel scanner, {bool triggerDiscovery = false}) {
    _activeScanner = scanner;
    _isScannerOnline = scanner.isOnline;
    _scannerModel = scanner.name;
    if (scanner.connectionType == ScannerConnectionType.wifi && scanner.host.isNotEmpty) {
      _scannerEndpoint = '${scanner.host}:${scanner.port}';
    }

    _config = _config.copyWith(
      selectedBackend: scanner.connectionType == ScannerConnectionType.wifi ? 'escl' : 'wia',
      selectedHost: scanner.host.isNotEmpty ? scanner.host : null,
      selectedPort: scanner.port > 0 ? scanner.port : null,
      selectedDeviceId: scanner.deviceId.isNotEmpty ? scanner.deviceId : null,
    );
    notifyListeners();

    if (triggerDiscovery) {
      discoverScanners(notify: true);
    }
  }

  Future<void> discoverScanners({bool notify = true}) async {
    _isDiscoveringScanners = true;
    if (notify) {
      notifyListeners();
    }

    try {
      final String hostCandidate = (_activeScanner != null && _activeScanner!.host.isNotEmpty)
          ? _activeScanner!.host
          : '192.168.1.150';
      final int portCandidate = (_activeScanner != null && _activeScanner!.port > 0)
          ? _activeScanner!.port
          : 8080;

      final Map<String, dynamic> report = await _processService.runDiagnostics(
        ip: hostCandidate,
        port: portCandidate,
      );

      final List<dynamic>? rawScanners = report['discovered_scanners'] as List<dynamic>?;
      if (rawScanners != null && rawScanners.isNotEmpty) {
        _availableScanners = rawScanners
            .map((dynamic item) => ScannerDeviceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        final Map<String, dynamic>? escl = report['escl'] as Map<String, dynamic>?;
        if (escl != null && (escl['reachable'] as bool? ?? false)) {
          final String modelName = (escl['make_and_model'] as String? ?? '').trim();
          final String friendlyName = (modelName.isEmpty || modelName.toLowerCase() == 'xxxx')
              ? 'HP DeskJet Wireless Scanner'
              : modelName;
          final String uuid = (escl['uuid'] as String? ?? '');
          _availableScanners = [
            ScannerDeviceModel(
              id: uuid.isNotEmpty ? 'escl:$uuid' : 'escl:192.168.1.150_8080',
              name: friendlyName,
              connectionType: ScannerConnectionType.wifi,
              host: (escl['host'] as String? ?? '192.168.1.150'),
              port: (escl['port'] as num?)?.toInt() ?? 8080,
              isOnline: true,
            ),
          ];
        } else {
          _availableScanners = const <ScannerDeviceModel>[];
        }
      }

      // Zero-Touch Auto-Connect:
      // 1. If active scanner is still present, retain it.
      ScannerDeviceModel? matchedScanner;
      if (_activeScanner != null) {
        for (final ScannerDeviceModel candidate in _availableScanners) {
          if (candidate.id == _activeScanner!.id) {
            matchedScanner = candidate;
            break;
          }
        }
      }

      if (matchedScanner != null) {
        _activeScanner = matchedScanner;
        _isScannerOnline = matchedScanner.isOnline;
        _scannerModel = matchedScanner.name;
      } else if (_availableScanners.isNotEmpty) {
        // Auto-connect to first available scanner immediately
        selectScanner(_availableScanners.first, triggerDiscovery: false);
      } else {
        _activeScanner = null;
        _isScannerOnline = false;
      }
    } catch (exception) {
      _consoleLogs.add('[DISCOVERY EXCEPTION] $exception');
    } finally {
      _isDiscoveringScanners = false;
      notifyListeners();
    }
  }

  Future<void> runDiagnostics() async {
    _consoleLogs.add('[DIAGNOSTICS] Probing available hardware scanners...');
    notifyListeners();

    await discoverScanners(notify: false);

    _consoleLogs.add('[DIAGNOSTICS] Found ${_availableScanners.length} available scanner(s).');
    notifyListeners();
  }
}
