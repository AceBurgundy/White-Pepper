import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../providers/app_state.dart';
import '../../widgets/buttons/progress_button.dart';

/// Stage 3: Step-by-Step Progressing Instructions & Scanner Activity Screen.
/// Replicates the Split Wavy Layout (desktop-screen-connect & WavyInstructionCard & LegalStitchWizardModal)
/// from D:\Conversations\scanner\minimalist.
class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdController;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _holdController.reset();
          if (mounted) {
            context.read<AppState>().triggerCurrentInstructionStep();
          }
        }
      });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _openDirectory(String directoryPath) {
    final Directory dir = Directory(directoryPath);
    if (dir.existsSync()) {
      OpenFile.open(dir.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<WorkflowInstructionStep> steps = state.workflowSteps;
    final WorkflowInstructionStep currentStep = state.currentInstructionStep;
    final bool isProcessing = (state.scanButtonState == ProgressButtonState.processing &&
        !state.isAwaitingUserConfirmation);
    final bool isCompleted = (state.scanButtonState == ProgressButtonState.completed);
    final bool isError = state.scanButtonState == ProgressButtonState.error;
    final bool isDark = state.isDarkMode;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = (constraints.maxWidth < 800 || constraints.maxHeight < 620);
        if (isCompact) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  color: isDark
                      ? DesignTokens.darkSurfaceOne
                      : DesignTokens.neutralLightSurface,
                  padding: const EdgeInsets.fromLTRB(20, 38, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildLightPaneTopAndChecklist(
                        state,
                        steps,
                        currentStep,
                        isProcessing,
                        isCompleted,
                      ),
                      const SizedBox(height: 12),
                      _buildPlacementSchematicCard(
                        state,
                        currentStep,
                        isCompleted,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: DesignTokens.onyx,
                  padding: const EdgeInsets.all(20),
                  child: _buildDarkExecutionPaneContent(
                    state,
                    currentStep,
                    isProcessing,
                    isCompleted,
                    isError,
                  ),
                ),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // LEFT LIGHT SURFACE PANE (.desktop-connect-light-pane)
            Expanded(
              flex: 11,
              child: Container(
                color: isDark
                    ? DesignTokens.darkSurfaceOne
                    : DesignTokens.neutralLightSurface,
                padding:
                    const EdgeInsets.fromLTRB(32, 38, 32, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildLightPaneTopAndChecklist(
                          state,
                          steps,
                          currentStep,
                          isProcessing,
                          isCompleted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPlacementSchematicCard(
                      state,
                      currentStep,
                      isCompleted,
                    ),
                  ],
                ),
              ),
            ),

            // CENTRAL VERTICAL ORGANIC WAVE DIVIDER (44px wide matching DesktopMockup.js line 679)
            SizedBox(
              width: 44,
              child: CustomPaint(
                painter: _VerticalOrganicWavePainter(
                  lightColor: isDark
                      ? DesignTokens.darkSurfaceOne
                      : DesignTokens.neutralLightSurface,
                  darkColor: DesignTokens.onyx,
                ),
              ),
            ),

            // RIGHT DARK ONYX EXECUTION PANE (.desktop-connect-dark-pane)
            Expanded(
              flex: 11,
              child: Container(
                color: DesignTokens.onyx,
                padding:
                    const EdgeInsets.fromLTRB(32, 38, 32, 28),
                child: _buildDarkExecutionPaneContent(
                  state,
                  currentStep,
                  isProcessing,
                  isCompleted,
                  isError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLightPaneTopAndChecklist(
    AppState state,
    List<WorkflowInstructionStep> steps,
    WorkflowInstructionStep currentStep,
    bool isProcessing,
    bool isCompleted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Tooltip(
              message: 'Back to Options Deck',
              child: Material(
                color: const Color(0xFFE4E4E4),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    if (isProcessing) {
                      state.cancelScan();
                    }
                    state.switchScreen(AppScreen.options);
                  },
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: DesignTokens.onyx,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.onyx,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                ),
                child: Text(
                  '${state.config.workflowType.title.toUpperCase()} • ${state.config.dpi <= 0 ? "AUTO" : "${state.config.dpi}"} DPI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.accentYellow,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Primary Headline
        Text(
          currentStep.headline.replaceAll('\n', ' '),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: DesignTokens.onyx,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          currentStep.physicalInstruction,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrayEightHundred,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currentStep.subInstruction,
          style: const TextStyle(
            fontSize: 12.5,
            color: DesignTokens.neutralGraySevenHundred,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Step-by-Step Progressing Timeline Checklist
        ...List<Widget>.generate(steps.length, (int index) {
          final WorkflowInstructionStep stepItem = steps[index];
          final bool stepDone = isCompleted || index < state.currentStepIndex;
          final bool stepActive = (!isCompleted && index == state.currentStepIndex);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: stepActive
                  ? DesignTokens.pureWhite
                  : DesignTokens.pureWhite.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: stepActive
                    ? DesignTokens.onyx
                    : DesignTokens.neutralGrayTwoHundred,
                width: stepActive ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: stepDone
                        ? DesignTokens.statusOnlineGreen
                        : (stepActive
                            ? DesignTokens.accentYellow
                            : DesignTokens.neutralGrayTwoHundred),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: stepDone
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: DesignTokens.pureWhite,
                          )
                        : Text(
                            '${stepItem.stepNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.onyx,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        stepItem.badgeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: stepActive
                              ? DesignTokens.onyx
                              : DesignTokens.neutralGraySevenHundred,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stepItem.physicalInstruction,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: DesignTokens.neutralGraySevenHundred,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDarkExecutionPaneContent(
    AppState state,
    WorkflowInstructionStep currentStep,
    bool isProcessing,
    bool isCompleted,
    bool isError,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Top Step Badge + Action Headline
        Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isCompleted
                    ? DesignTokens.statusOnlineGreen
                    : (isError
                        ? DesignTokens.statusErrorRed
                        : DesignTokens.accentYellow),
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusPill,
                ),
              ),
              child: Text(
                currentStep.badgeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isCompleted || isError
                      ? DesignTokens.pureWhite
                      : DesignTokens.onyx,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isProcessing
                  ? 'Scanning & Processing...'
                  : (isCompleted
                      ? 'Workflow Completed!'
                      : currentStep.actionButtonLabel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: DesignTokens.pureWhite,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isProcessing
                  ? 'Communicating with scanner hardware...'
                  : (isCompleted
                      ? 'Document acquired and saved successfully.'
                      : 'Click or press-and-hold the yellow trigger below to execute this step'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: DesignTokens.neutralGrayFiveHundred,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Central 84x84 Circular Hold/Click Progress Trigger Button
        Column(
          children: <Widget>[
            GestureDetector(
              onTapDown:
                  isProcessing ? null : (_) => _holdController.forward(),
              onTapUp: isProcessing
                  ? null
                  : (_) {
                      if (_holdController.value < 1.0) {
                        _holdController.reset();
                        state.triggerCurrentInstructionStep();
                      }
                    },
              onTapCancel:
                  isProcessing ? null : () => _holdController.reset(),
              child: MouseRegion(
                cursor: isProcessing
                    ? SystemMouseCursors.wait
                    : SystemMouseCursors.click,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (isProcessing)
                        const SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DesignTokens.accentYellow,
                            ),
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _holdController,
                          builder: (BuildContext context, _) {
                            return SizedBox(
                              width: 84,
                              height: 84,
                              child: CircularProgressIndicator(
                                value: isCompleted
                                    ? 1.0
                                    : (_holdController.value > 0
                                        ? _holdController.value
                                        : 0.28),
                                strokeWidth: 3.5,
                                backgroundColor: DesignTokens.darkSurfaceFive,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted
                                      ? DesignTokens.statusOnlineGreen
                                      : DesignTokens.accentYellow,
                                ),
                              ),
                            );
                          },
                        ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? DesignTokens.statusOnlineGreen
                              : (isError
                                  ? DesignTokens.statusErrorRed
                                  : DesignTokens.accentYellow),
                          shape: BoxShape.circle,
                          boxShadow: DesignTokens.shadowYellowButton,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : (isProcessing
                                  ? Icons.hourglass_top_rounded
                                  : Icons.arrow_forward_rounded),
                          size: 30,
                          color: isCompleted || isError
                              ? DesignTokens.pureWhite
                              : DesignTokens.onyx,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isProcessing
                  ? 'Communicating with scanner...'
                  : (isCompleted
                      ? 'Click to return to Dashboard'
                      : 'Step ${currentStep.stepNumber} of ${currentStep.totalSteps} Ready'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrayFiveHundred,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Scanner Activity Card & Completion Actions
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 145,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DesignTokens.darkSurfaceOne,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusCardInner),
                border: Border.all(color: DesignTokens.darkSurfaceSix),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isProcessing
                                  ? DesignTokens.accentYellow
                                  : (isCompleted
                                      ? DesignTokens.statusOnlineGreen
                                      : DesignTokens.neutralGrayFiveHundred),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SCANNER ACTIVITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.accentYellow,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isProcessing
                            ? 'In Progress'
                            : (isCompleted ? 'Complete' : 'Ready'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? DesignTokens.statusOnlineGreen
                              : (isProcessing
                                  ? DesignTokens.accentYellow
                                  : DesignTokens.neutralGraySixHundred),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.consoleLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'Ready to start. Tap or hold the button above to begin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.neutralGrayFiveHundred,
                              ),
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            itemCount: state.consoleLogs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String rawLine = state.consoleLogs[
                                  state.consoleLogs.length - 1 - index];
                              if (rawLine.startsWith('\$') ||
                                  rawLine.contains('scan_cli.py') ||
                                  rawLine.contains('process_cli.py')) {
                                return const SizedBox.shrink();
                              }
                              final bool isSuccessLine = rawLine.contains('[Success]') ||
                                  rawLine.contains('[SAVED]') ||
                                  rawLine.contains('completed');
                              final bool isErrorLine = rawLine.contains('[ERROR]') ||
                                  rawLine.contains('[stderr]');
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  rawLine,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isSuccessLine
                                        ? DesignTokens.statusOnlineGreen
                                        : (isErrorLine
                                            ? DesignTokens.statusErrorRed
                                            : DesignTokens
                                                .neutralGrayThreeHundred),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons Row
            Row(
              children: <Widget>[
                if (isProcessing)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => state.cancelScan(),
                      icon: const Icon(Icons.stop_circle_rounded, size: 18),
                      label: const Text('Stop / Cancel Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.statusErrorRed,
                        foregroundColor: DesignTokens.pureWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                  )
                else ...<Widget>[
                  if (state.lastGeneratedFilePath != null) ...<Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          OpenFile.open(state.lastGeneratedFilePath!);
                        },
                        icon: const Icon(
                          Icons.visibility_rounded,
                          size: 17,
                        ),
                        label: const Text(
                          'Open File',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.accentYellow,
                          foregroundColor: DesignTokens.onyx,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusPill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openDirectory(state.config.outputDirectory),
                      icon: const Icon(
                        Icons.folder_open_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'Open Folder',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.darkSurfaceFive,
                        foregroundColor: DesignTokens.pureWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isCompleted) {
                          state.beginInstructionsWorkflow();
                        } else {
                          state.triggerCurrentInstructionStep();
                        }
                      },
                      icon: Icon(
                        isCompleted
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isCompleted ? 'Scan Again' : 'Execute Step',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? DesignTokens.darkSurfaceFive
                            : DesignTokens.accentYellow,
                        foregroundColor: isCompleted
                            ? DesignTokens.pureWhite
                            : DesignTokens.onyx,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlacementSchematicCard(
    AppState state,
    WorkflowInstructionStep currentStep,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DesignTokens.neutralGrayTwoHundred),
      ),
      child: Row(
        children: <Widget>[
          // Visual Platen Glass Diagram (from LegalStitchWizardModal.js / WavyInstructionCard.js)
          Container(
            width: 78,
            height: 98,
            decoration: BoxDecoration(
              color: DesignTokens.neutralGrayFifty,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DesignTokens.onyx, width: 1.8),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(
                    Icons.crop_free_rounded,
                    size: 13,
                    color: DesignTokens.neutralGraySixHundred,
                  ),
                ),
                if (currentStep.schematicMode == 'legal_pass_1')
                  Positioned(
                    top: 6,
                    left: 6,
                    right: 6,
                    bottom: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.accentYellow.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: DesignTokens.onyx, width: 1.2),
                      ),
                      child: const Center(
                        child: Text(
                          'TOP 11"\nUPRIGHT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.onyx,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (currentStep.schematicMode == 'legal_pass_2')
                  Positioned(
                    top: 24,
                    left: 6,
                    right: 6,
                    bottom: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.accentYellow.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: DesignTokens.onyx, width: 1.2),
                      ),
                      child: const Center(
                        child: Text(
                          '180° FLIP\nBOTTOM 11"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.0,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.onyx,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (currentStep.schematicMode == 'card_front' ||
                    currentStep.schematicMode == 'card_back')
                  Positioned(
                    top: 8,
                    left: 8,
                    width: 44,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.accentYellow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: DesignTokens.onyx, width: 1.4),
                      ),
                      child: Center(
                        child: Text(
                          currentStep.schematicMode == 'card_front'
                              ? 'FRONT'
                              : 'BACK',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.onyx,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 10,
                    bottom: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? DesignTokens.statusOnlineGreen.withValues(alpha: 0.22)
                            : DesignTokens.accentYellow.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: DesignTokens.onyx, width: 1.2),
                      ),
                      child: Center(
                        child: Text(
                          state.config.paperSize.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.onyx,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isCompleted
                      ? 'Output Saved (${state.generatedFiles.length} file${state.generatedFiles.length == 1 ? "" : "s"})'
                      : 'Platen Origin (0,0) Alignment Guide',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.onyx,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.lastGeneratedFilePath ??
                      'Target folder: ${state.config.outputDirectory}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.neutralGraySevenHundred,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the exact vertical organic SVG wave from DesktopMockup.js (viewBox 0 0 44 630):
/// `M0,0 C28,60 34,150 24,300 C14,450 32,540 4,630 L44,630 L44,0 Z`
class _VerticalOrganicWavePainter extends CustomPainter {
  const _VerticalOrganicWavePainter({
    required this.lightColor,
    required this.darkColor,
  });

  final Color lightColor;
  final Color darkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final double sx = size.width / 44.0;
    final double sy = size.height / 630.0;

    final Path wavePath = Path()
      ..moveTo(0 * sx, 0 * sy)
      ..cubicTo(28 * sx, 60 * sy, 34 * sx, 150 * sy, 24 * sx, 300 * sy)
      ..cubicTo(14 * sx, 450 * sy, 32 * sx, 540 * sy, 4 * sx, 630 * sy)
      ..lineTo(44 * sx, 630 * sy)
      ..lineTo(44 * sx, 0 * sy)
      ..close();

    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, darkPaint);
  }

  @override
  bool shouldRepaint(covariant _VerticalOrganicWavePainter oldDelegate) {
    return oldDelegate.lightColor != lightColor ||
        oldDelegate.darkColor != darkColor;
  }
}
