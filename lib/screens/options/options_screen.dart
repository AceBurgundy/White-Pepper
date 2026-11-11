import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/peapod/pea_pod_drawer.dart';
import '../../widgets/peapod/pea_pod_widget.dart';
import '../../widgets/preview/platen_preview_canvas.dart';

/// Dark #212121 Options Control Deck replicating Screen 2 of DesktopMockup.js (lines 520–652)
class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  void _navigateBackToDashboard(BuildContext context, AppState state) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      state.switchScreen(AppScreen.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int workflowIndex =
        WorkflowType.values.indexOf(state.config.workflowType) + 1;
    final int totalWorkflows = WorkflowType.values.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact =
            constraints.maxWidth < 800 || constraints.maxHeight < 620;

        if (isCompact) {
          return Container(
            color: DesignTokens.onyx,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 360,
                    child: _buildLeftPreviewCard(
                      context,
                      state,
                      workflowIndex,
                      totalWorkflows,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildControlDeckHeading(state),
                  const SizedBox(height: 14),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PeaPodWidget(
                        tools: state.availableTools,
                        selectedTool: state.activeTool,
                        onToolSelected: (PeaPodToolType tool) {
                          state.setActiveTool(tool);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDrawerAndSummaryBar(state),
                  const SizedBox(height: 16),
                  _buildBottomActionRow(context, state),
                ],
              ),
            ),
          );
        }

        return Container(
          color: DesignTokens.onyx,
          padding: const EdgeInsets.all(28.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Left Column (340px): #2A2A2A Live Document Preview & Printer Platen
              SizedBox(
                width: 340,
                child: _buildLeftPreviewCard(
                  context,
                  state,
                  workflowIndex,
                  totalWorkflows,
                ),
              ),
              const SizedBox(width: 28),

              // Right Column: Dedicated Control Panel (Pea Pod + Active Drawer + Summary + Start)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildControlDeckHeading(state),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: PeaPodWidget(
                          tools: state.availableTools,
                          selectedTool: state.activeTool,
                          onToolSelected: (PeaPodToolType tool) {
                            state.setActiveTool(tool);
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildDrawerAndSummaryBar(state),
                      ),
                    ),
                    _buildBottomActionRow(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftPreviewCard(
    BuildContext context,
    AppState state,
    int workflowIndex,
    int totalWorkflows,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.darkSurfaceOne,
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Header Bar with Back Button, Workflow Pill, and Index Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Tooltip(
                message: 'Back to Dashboard',
                child: Material(
                  color: DesignTokens.darkSurfaceFour,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => _navigateBackToDashboard(context, state),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: DesignTokens.pureWhite,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.darkSurfaceFour,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusPill,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        state.config.workflowType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DesignTokens.pureWhite,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: DesignTokens.accentYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Flexible(
                            child: Text(
                              'Ready to Configure',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: DesignTokens.accentYellow,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '$workflowIndex/$totalWorkflows',
                style: const TextStyle(
                  color: DesignTokens.neutralGraySixHundred,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Printer Pill + Paper Sheet Preview
          Expanded(
            child: PlatenPreviewCanvas(
              paperPreset: state.config.paperSize,
              dpi: state.config.dpi,
              rotation: state.config.rotation,
              customWidth: state.config.customWidth,
              customHeight: state.config.customHeight,
              fileNamePrefix: state.config.fileNamePrefix,
              colorMode: state.config.colorMode,
              format: state.config.format,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlDeckHeading(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'SCAN SETTINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: DesignTokens.accentYellow,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tool & Parameter Adjustments',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: DesignTokens.pureWhite,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a category below to customize paper size, scan quality, color tone, and save location for ${state.config.workflowType.title}.',
          style: const TextStyle(
            fontSize: 13.5,
            color: DesignTokens.neutralGrayFiveHundred,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerAndSummaryBar(AppState state) {
    final ScanConfigurationModel config = state.config;
    final String dpiLabel =
        config.dpi <= 0 ? 'Auto Quality' : '${config.dpi} DPI';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PeaPodDrawer(
          selectedTool: state.activeTool,
          config: config,
          onConfigChanged: (ScanConfigurationModel cfg) {
            state.updateConfig(cfg);
          },
        ),
        const SizedBox(height: 10),
        // Active Scan Configuration Summary Bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.darkSurfaceOne,
            borderRadius: BorderRadius.circular(DesignTokens.radiusCardInner),
            border: Border.all(
              color: DesignTokens.darkSurfaceFive,
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.tune_rounded,
                size: 16,
                color: DesignTokens.accentYellow,
              ),
              const SizedBox(width: 10),
              const Text(
                'Active Settings:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.pureWhite,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    _buildSummaryBadge(
                      label: 'Paper',
                      value: config.paperSize.toUpperCase(),
                    ),
                    _buildSummaryBadge(
                      label: 'Quality',
                      value: dpiLabel,
                    ),
                    _buildSummaryBadge(
                      label: 'Color',
                      value: config.colorMode.toUpperCase(),
                    ),
                    _buildSummaryBadge(
                      label: 'Format',
                      value: '.${config.format.toUpperCase()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DesignTokens.darkSurfaceFour,
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      ),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DesignTokens.neutralGrayFiveHundred,
          ),
          children: <InlineSpan>[
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DesignTokens.pureWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionRow(BuildContext context, AppState state) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: DesignTokens.darkSurfaceTwo,
            borderRadius: BorderRadius.circular(
              DesignTokens.radiusPill,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Tooltip(
                message: 'Reset Workflow Defaults',
                child: Material(
                  color: DesignTokens.darkSurfaceFive,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => state.resetCurrentWorkflowDefaults(),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.undo_rounded,
                        color: DesignTokens.pureWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Return to Workflow Cards',
                child: Material(
                  color: DesignTokens.darkSurfaceFive,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => _navigateBackToDashboard(context, state),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: DesignTokens.neutralGrayFiveHundred,
                        size: 20,
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
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                state.beginInstructionsWorkflow();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.accentYellow,
                foregroundColor: DesignTokens.onyx,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 24,
                    color: DesignTokens.onyx,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Start ${state.config.workflowType.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.onyx,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
