import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ipc_event.dart';
import '../models/peapod_tool.dart';
import '../models/scan_configuration_model.dart';
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
  final String _scannerModel = 'HP DeskJet / Wireless eSCL';
  final String _scannerEndpoint = '192.168.1.150:8080';

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
                'Pass 2 captures the remaining 3.0" legal tail with an 8.0" overlap for Fourier phase-correlation stitching.',
            actionButtonLabel: 'Scan Pass 2 & Auto-Stitch',
            schematicMode: 'legal_pass_2',
          ),
          WorkflowInstructionStep(
            stepNumber: 3,
            totalSteps: 3,
            badgeLabel: 'Step 3 of 3 • Reconstruction Complete',
            headline: 'Legal Document\nStitched!',
            physicalInstruction:
                'Both passes have been registered via sub-pixel Fourier phase correlation into a seamless 8.5" × 14.0" canvas.',
            subInstruction:
                'Physical DPI metadata is embedded directly into the output document.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.cardDuplex:
        if (_config.cardDuplexTwoSided) {
          return <WorkflowInstructionStep>[
            WorkflowInstructionStep(
              stepNumber: 1,
              totalSteps: 3,
              badgeLabel: 'Step 1 of 3 • Front Side (${_config.dpi} DPI)',
              headline: 'Place Card\nFRONT Side',
              physicalInstruction:
                  'Place the FRONT side of your ID-1 card face-down near the top-left corner of the scanner glass (within the 5.0" × 5.0" zone).',
              subInstruction:
                  'Leave a ~5 mm white border gap from the plastic bezel so computer vision can pin all 4 card edges.',
              actionButtonLabel: 'Scan & Deskew Front Side',
              schematicMode: 'card_front',
            ),
            WorkflowInstructionStep(
              stepNumber: 2,
              totalSteps: 3,
              badgeLabel: 'Step 2 of 3 • Back Side (${_config.dpi} DPI)',
              headline: 'Flip Card to\nBACK Side',
              physicalInstruction:
                  'Flip the ID card over to its BACK side in the same top-left 5.0" × 5.0" corner zone of the platen glass.',
              subInstruction:
                  'Sub-degree contour deskewing and ${_config.cornerRadiusMm.toStringAsFixed(2)} mm rounded-corner masking will run automatically.',
              actionButtonLabel: 'Scan & Deskew Back Side',
              schematicMode: 'card_back',
            ),
            const WorkflowInstructionStep(
              stepNumber: 3,
              totalSteps: 3,
              badgeLabel: 'Step 3 of 3 • Duplex Extraction Complete',
              headline: 'Front & Back\nExtracted!',
              physicalInstruction:
                  'Both card sides have been isolated, rotationally deskewed, alpha-masked, and saved with native DPI headers.',
              subInstruction:
                  'Use the actions below to inspect the extracted card images or open the output folder.',
              actionButtonLabel: 'Done',
              schematicMode: 'completed',
            ),
          ];
        } else {
          return <WorkflowInstructionStep>[
            WorkflowInstructionStep(
              stepNumber: 1,
              totalSteps: 2,
              badgeLabel: 'Step 1 of 2 • Card Placement (${_config.dpi} DPI)',
              headline: 'Place ID Card\nat Top-Left',
              physicalInstruction:
                  'Place the ID-1 card face-down in the top-left 5.0" × 5.0" platen corner.',
              subInstruction:
                  'Computer vision contour detection will deskew and mask the card at ${_config.dpi} DPI.',
              actionButtonLabel: 'Scan & Deskew Card',
              schematicMode: 'card_front',
            ),
            const WorkflowInstructionStep(
              stepNumber: 2,
              totalSteps: 2,
              badgeLabel: 'Step 2 of 2 • Extraction Complete',
              headline: 'ID-1 Card\nExtracted!',
              physicalInstruction:
                  'The ID card has been deskewed and saved with embedded optical DPI metadata.',
              subInstruction: 'Click Open File below to view the output.',
              actionButtonLabel: 'Done',
              schematicMode: 'completed',
            ),
          ];
        }

      case WorkflowType.bookletBatch:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 3,
            badgeLabel: 'Step 1 of 3 • Spread Setup (${_config.paperSize.toUpperCase()})',
            headline: 'Place Booklet\nSpread #1',
            physicalInstruction:
                'Lay the open booklet spread flat against the top-left scanner glass origin mark.',
            subInstruction:
                'Continuous interval mode will capture a spread every ${_config.intervalSeconds}s (${_config.maxScans == 0 ? "until stopped" : "max ${_config.maxScans} spreads"}).',
            actionButtonLabel: 'Start Continuous Batch',
            schematicMode: 'platen_sheet',
          ),
          WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 3,
            badgeLabel: 'Step 2 of 3 • Interval Capture Active',
            headline: 'Turn Pages\nBetween Scans',
            physicalInstruction:
                'Watch the live CLI countdown log on the right and turn to the next booklet spread during each ${_config.intervalSeconds}s pause.',
            subInstruction:
                'You can stop the batch at any time once your final spread is captured.',
            actionButtonLabel: 'Capturing Spreads...',
            schematicMode: 'platen_sheet',
          ),
          const WorkflowInstructionStep(
            stepNumber: 3,
            totalSteps: 3,
            badgeLabel: 'Step 3 of 3 • Batch Spreads Saved',
            headline: 'Booklet Batch\nFinished!',
            physicalInstruction:
                'All booklet spreads have been saved to the output directory with native DPI metadata.',
            subInstruction: 'Ready for saddle-stitch processing or PDF compilation.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.compilePdf:
      case WorkflowType.batchCardDeskew:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 2,
            badgeLabel: 'Step 1 of 2 • Verify Processing Pipeline',
            headline: wf == WorkflowType.compilePdf
                ? 'Compile Images\nto PDF'
                : 'Batch Card\nVision Deskew',
            physicalInstruction: wf == WorkflowType.compilePdf
                ? 'Verify target folder (${_config.outputDirectory}) and layout settings (${_config.paperSize.toUpperCase()} • fit=${_config.fitMode}).'
                : 'Verify source folder (${_config.outputDirectory}) for batch ID-1 contour isolation at ${_config.dpi} DPI.',
            subInstruction:
                'Press the yellow trigger button on the right to launch scripts/process_cli.py.',
            actionButtonLabel: 'Run Processing Pipeline',
            schematicMode: 'platen_sheet',
          ),
          const WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 2,
            badgeLabel: 'Step 2 of 2 • Pipeline Complete',
            headline: 'Processing\nComplete!',
            physicalInstruction:
                'All files have been processed by scripts/process_cli.py with lossless DPI metadata preservation.',
            subInstruction: 'Open the generated output below.',
            actionButtonLabel: 'Done',
            schematicMode: 'completed',
          ),
        ];

      case WorkflowType.flatbed:
      case WorkflowType.receiptArchive:
      case WorkflowType.photoScan:
        return <WorkflowInstructionStep>[
          WorkflowInstructionStep(
            stepNumber: 1,
            totalSteps: 2,
            badgeLabel:
                'Step 1 of 2 • Align ${_config.paperSize.toUpperCase()} @ ${_config.dpi} DPI',
            headline: 'Align Document\non Platen Glass',
            physicalInstruction:
                'Place your ${wf.title.toLowerCase()} face-down flush with the top-left platen origin mark (0,0) and close the scanner lid.',
            subInstruction:
                'Target region: ${_config.paperSize.toUpperCase()} • ${_config.dpi} DPI • ${_config.colorMode.toUpperCase()} • .${_config.format.toUpperCase()}',
            actionButtonLabel: 'Start Optical Scan',
            schematicMode: 'platen_sheet',
          ),
          const WorkflowInstructionStep(
            stepNumber: 2,
            totalSteps: 2,
            badgeLabel: 'Step 2 of 2 • Acquisition Complete',
            headline: 'Scan Saved\nSuccessfully!',
            physicalInstruction:
                'Optical capture, region clipping, and DPI metadata embedding completed via scripts/scan_cli.py.',
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
    _config = ScanConfigurationModel(workflowType: workflow);

    switch (workflow) {
      case WorkflowType.flatbed:
        _config.paperSize = 'a4';
        _config.dpi = 300;
        _config.format = 'pdf';
      case WorkflowType.cardDuplex:
        _config.paperSize = 'id-card';
        _config.dpi = 600;
        _config.format = 'png';
        _config.cardBackground = 'transparent';
        _config.cardDuplexTwoSided = true;
      case WorkflowType.legalStitch:
        _config.paperSize = 'legal';
        _config.dpi = 300;
        _config.format = 'pdf';
        _config.ipcMode = true;
      case WorkflowType.bookletBatch:
        _config.paperSize = 'full';
        _config.dpi = 300;
        _config.format = 'png';
        _config.intervalSeconds = 10;
      case WorkflowType.receiptArchive:
        _config.paperSize = 'receipt-half';
        _config.dpi = 300;
        _config.format = 'png';
      case WorkflowType.photoScan:
        _config.paperSize = 'photo-4x6';
        _config.dpi = 600;
        _config.format = 'png';
      case WorkflowType.compilePdf:
        _config.paperSize = 'auto';
        _config.dpi = 0; // Auto (Embedded DPI)
        _config.fitMode = 'contain';
        _config.format = 'pdf';
      case WorkflowType.batchCardDeskew:
        _config.paperSize = 'id-card';
        _config.dpi = 600;
        _config.format = 'png';
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
    if (_config.workflowType == WorkflowType.cardDuplex &&
        _config.cardDuplexTwoSided) {
      if (_processService.isRunning) return;
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

    // Standard single-command workflow (Flatbed, Photo, Receipt, Booklet, Compile PDF, Batch Cards, Single-Sided Card)
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
            final String codeStr =
                line.replaceFirst('[exit] Process completed with code ', '').trim();
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
    } catch (e) {
      _consoleLogs.add('[EXECUTION EXCEPTION] $e');
      _scanButtonState = ProgressButtonState.error;
      _isAwaitingUserConfirmation = true;
      notifyListeners();
    }
  }

  void _extractSavedFilePathFromLog(String line) {
    final List<String> markers = <String>[
      '[Success] Scanned file saved:',
      '[Success] Extracted ID-1 Card:',
      '[Success] Stitched US Legal Document:',
      '[Success] Compiled PDF document:',
      '[SAVED]',
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

  void cancelScan() {
    _processService.cancelActiveProcess();
    _scanButtonState = ProgressButtonState.idle;
    _activeIpcEvent = null;
    _isAwaitingUserConfirmation = true;
    notifyListeners();
  }

  Future<void> runDiagnostics() async {
    _consoleLogs.add('[DIAGNOSTICS] Probing hardware endpoint $_scannerEndpoint...');
    notifyListeners();

    final Map<String, dynamic> report = await _processService.runDiagnostics(
      ip: '192.168.1.150',
      port: 8080,
    );

    final bool success = (report['success'] as bool?) ?? false;
    _isScannerOnline = success;
    _consoleLogs.add('[DIAGNOSTICS REPORT] $report');
    notifyListeners();
  }
}
