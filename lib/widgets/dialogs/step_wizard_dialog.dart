import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/ipc_event.dart';
import '../../providers/app_state.dart';
import '../../widgets/buttons/progress_button.dart';
import '../icons/animated_line_icons/animated_line_icons.dart';

class StepWizardDialog extends StatelessWidget {
  const StepWizardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final IpcEvent? ipcEvent = state.activeIpcEvent;
    final int step = ipcEvent?.step ?? (state.config.workflowType.identifier == 'legal-two-pass' ? 1 : 1);
    final bool isCompleted = state.scanButtonState == ProgressButtonState.completed;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: DesignTokens.pureWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
          boxShadow: DesignTokens.shadowWorkstation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: DesignTokens.accentYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        color: DesignTokens.onyx,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.config.workflowType.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.onyx,
                          ),
                        ),
                        Text(
                          isCompleted
                              ? 'Pipeline Finished'
                              : 'Step $step of 2: Guided Placement',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.neutralGraySevenHundred,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                DialogCloseButton(
                  onTap: () {
                    if (state.scanButtonState == ProgressButtonState.processing) {
                      state.cancelScan();
                    }
                    Navigator.of(context).pop();
                  },
                  isDark: false,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Placement Illustration Area
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.neutralGrayFifty,
                borderRadius: BorderRadius.circular(DesignTokens.radiusCardInner),
                border: Border.all(
                  color: DesignTokens.neutralGrayTwoHundred,
                ),
              ),
              child: isCompleted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: DesignTokens.statusOnlineGreen,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Document Stitched & Saved Successfully!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.onyx,
                            ),
                          ),
                          if (state.lastGeneratedFilePath != null) ...[
                            const SizedBox(height: 6),
                            SelectableText(
                              state.lastGeneratedFilePath!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: DesignTokens.neutralGrayEightHundred,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Glass schematic
                        Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: DesignTokens.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DesignTokens.neutralGrayThreeHundred,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Icon(
                                  Icons.crop_free_rounded,
                                  size: 16,
                                  color: DesignTokens.neutralGrayFiveHundred,
                                ),
                              ),
                              Positioned(
                                top: step == 1 ? 4 : 40,
                                left: 4,
                                right: 4,
                                bottom: step == 1 ? 40 : 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: DesignTokens.accentYellow.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: DesignTokens.onyx,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      step == 1 ? 'TOP UPRIGHT' : 'BOTTOM UPSIDE-DOWN',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: DesignTokens.onyx,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Step description text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                step == 1
                                    ? 'Place the TOP upright half of the Legal sheet on the platen glass.'
                                    : 'Flip sheet UPSIDE DOWN and align the opposite bottom edge.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: DesignTokens.onyx,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step == 1
                                    ? 'Align the top-left edge flush with the scanner glass origin mark (0,0).'
                                    : 'Place the opposite corner into the marking so the bottom half is captured cleanly.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: DesignTokens.neutralGraySevenHundred,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 18),

            // Scanner Activity Status
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: DesignTokens.onyx,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusModuleContainer),
              ),
              child: state.consoleLogs.isEmpty
                  ? Center(
                      child: Text(
                        step == 1
                            ? 'Ready to scan Pass 1 (Top upright)'
                            : 'Ready to scan Pass 2 (Bottom upside-down)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: DesignTokens.neutralGrayFiveHundred,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: state.consoleLogs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String log = state.consoleLogs[
                            state.consoleLogs.length - 1 - index];
                        if (log.startsWith('\$') ||
                            log.contains('scan_cli.py') ||
                            log.contains('process_cli.py')) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          log,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DesignTokens.neutralGrayThreeHundred,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCompleted && state.lastGeneratedFilePath != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      OpenFile.open(state.lastGeneratedFilePath!);
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('Open Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.onyx,
                      foregroundColor: DesignTokens.pureWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton(
                  onPressed: () {
                    if (isCompleted) {
                      Navigator.of(context).pop();
                    } else {
                      state.sendStdinProceed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentYellow,
                    foregroundColor: DesignTokens.onyx,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isCompleted ? 'Close' : 'Confirm & Scan Step',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
