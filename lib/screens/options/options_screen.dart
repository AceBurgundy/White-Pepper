import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/peapod_tool.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/peapod/pea_pod_drawer.dart';
import '../../widgets/peapod/pea_pod_widget.dart';
import '../../widgets/preview/platen_preview_canvas.dart';
import '../../widgets/icons/animated_line_icons/animated_line_icons.dart';

/// Options Control Deck replicating Screen 2 with All-Day Theme default & 1.5x borderless options.
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
    final bool isDark = state.isDarkMode;
    final int workflowIndex = WorkflowType.values.indexOf(state.config.workflowType) + 1;
    final int totalWorkflows = WorkflowType.values.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = (constraints.maxWidth < 800 || constraints.maxHeight < 620);

        if (isCompact) {
          return Container(
            color: isDark
                ? DesignTokens.onyx
                : DesignTokens.neutralLightSurface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 38.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 380,
                    child: _buildLeftPreviewCard(
                      context,
                      state,
                      workflowIndex,
                      totalWorkflows,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildControlDeckHeading(state, isDark),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Transform.scale(
                            scale: 1.5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: PeaPodWidget(
                                isDarkMode: isDark,
                                tools: state.availableTools,
                                selectedTool: state.activeTool,
                                onToolSelected: (PeaPodToolType tool) {
                                  state.setActiveTool(tool);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.activeTool.displayTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? DesignTokens.pureWhite
                                : DesignTokens.onyx,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDrawerAndSummaryBar(state, isDark),
                  const SizedBox(height: 16),
                  _buildBottomActionRow(context, state, isDark),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isNarrow = constraints.maxWidth < 800;

            if (isNarrow) {
              return Container(
                color: isDark
                    ? DesignTokens.onyx
                    : DesignTokens.neutralLightSurface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 380,
                        child: _buildLeftPreviewCard(
                          context,
                          state,
                          workflowIndex,
                          totalWorkflows,
                          isDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildControlDeckHeading(state, isDark),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    child: PeaPodWidget(
                                      isDarkMode: isDark,
                                      tools: state.availableTools,
                                      selectedTool: state.activeTool,
                                      onToolSelected: (PeaPodToolType tool) {
                                        state.setActiveTool(tool);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.activeTool.displayTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? DesignTokens.pureWhite
                                      : DesignTokens.onyx,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDrawerAndSummaryBar(state, isDark),
                      const SizedBox(height: 20),
                      _buildBottomActionRow(context, state, isDark),
                    ],
                  ),
                ),
              );
            }

            return Container(
              color: isDark
                  ? DesignTokens.onyx
                  : DesignTokens.neutralLightSurface,
              padding: const EdgeInsets.fromLTRB(28.0, 38.0, 28.0, 28.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Left Column (390px): Widened Live Document Preview & Optical Platen
                  SizedBox(
                    width: 390,
                    child: _buildLeftPreviewCard(
                      context,
                      state,
                      workflowIndex,
                      totalWorkflows,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Right Column: Dedicated Control Panel (Pea Pod + Active Drawer + Summary + Start)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildControlDeckHeading(state, isDark),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Transform.scale(
                                    scale: 1.5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      child: PeaPodWidget(
                                        isDarkMode: isDark,
                                        tools: state.availableTools,
                                        selectedTool: state.activeTool,
                                        onToolSelected: (PeaPodToolType tool) {
                                          state.setActiveTool(tool);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.activeTool.displayTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? DesignTokens.pureWhite
                                        : DesignTokens.onyx,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildDrawerAndSummaryBar(state, isDark),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBottomActionRow(context, state, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeftPreviewCard(
    BuildContext context,
    AppState state,
    int workflowIndex,
    int totalWorkflows,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.darkSurfaceOne
            : DesignTokens.pureWhite,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: isDark
              ? DesignTokens.darkSurfaceThree
              : DesignTokens.neutralGrayThreeHundred,
          width: 1.0,
        ),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Header Bar with Back Button, Workflow Pill, and Index Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _CompactBackButton(
                isDark: isDark,
                onTap: () => _navigateBackToDashboard(context, state),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.darkSurfaceFour
                        : const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusPill,
                    ),
                    border: Border.all(
                      color: isDark
                          ? DesignTokens.darkSurfaceFive
                          : const Color(0xFFE4E4E7),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        state.config.workflowType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? DesignTokens.pureWhite
                              : DesignTokens.onyx,
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
                              color: DesignTokens.statusOnlineGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Ready to Configure',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? DesignTokens.accentYellow
                                    : const Color(0xFF15803D),
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
                style: TextStyle(
                  color: isDark
                      ? DesignTokens.neutralGraySixHundred
                      : DesignTokens.neutralGraySevenHundred,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Widened Optical Platen Bed
          Expanded(
            child: PlatenPreviewCanvas(
              isDarkMode: isDark,
              paperPreset: state.config.paperSize,
              dpi: state.config.dpi,
              rotation: state.config.rotation,
              customWidth: state.config.customWidth,
              customHeight: state.config.customHeight,
              units: state.config.units,
              fileNamePrefix: state.config.fileNamePrefix,
              colorMode: state.config.colorMode,
              format: state.config.format,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlDeckHeading(AppState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'SCAN SETTINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? DesignTokens.accentYellow : const Color(0xFFB45309),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tool & Parameter Adjustments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a category below to customize paper size, scan quality, color tone, and save location for ${state.config.workflowType.title}.',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? DesignTokens.neutralGrayFiveHundred
                : DesignTokens.neutralGraySevenHundred,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerAndSummaryBar(AppState state, bool isDark) {
    final ScanConfigurationModel config = state.config;
    final String dpiLabel = config.dpi <= 0 ? 'Auto Quality' : '${config.dpi} DPI';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PeaPodDrawer(
          isDarkMode: isDark,
          selectedTool: state.activeTool,
          config: config,
          onConfigChanged: (ScanConfigurationModel cfg) {
            state.updateConfig(cfg);
          },
        ),
        const SizedBox(height: 14),
        // Active Scan Configuration Summary Bar - Borderless without parent background
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: isDark
                    ? DesignTokens.accentYellow
                    : const Color(0xFFD4AC0D),
              ),
              const SizedBox(width: 8),
              Text(
                'Active Settings:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    _buildSummaryBadge(
                      isDark: isDark,
                      label: 'Paper',
                      value: PeaPodDrawer.formatPresetTitle(config.paperSize),
                    ),
                    _buildSummaryBadge(
                      isDark: isDark,
                      label: 'Quality',
                      value: dpiLabel,
                    ),
                    _buildSummaryBadge(
                      isDark: isDark,
                      label: 'Color',
                      value: PeaPodDrawer.formatPresetTitle(config.colorMode),
                    ),
                    _buildSummaryBadge(
                      isDark: isDark,
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
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.darkSurfaceFour
            : DesignTokens.neutralGrayOneHundred,
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      ),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? DesignTokens.neutralGrayFiveHundred
                : DesignTokens.neutralGrayEightHundred,
          ),
          children: <InlineSpan>[
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionRow(
    BuildContext context,
    AppState state,
    bool isDark,
  ) {
    return Row(
      children: <Widget>[
        _ReturnBackButton(
          isDark: isDark,
          onTap: () => _navigateBackToDashboard(context, state),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                state.beginInstructionsWorkflow();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.accentYellow,
                foregroundColor: DesignTokens.onyx,
                enabledMouseCursor: SystemMouseCursors.click,
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

class _ReturnBackButton extends StatefulWidget {
  const _ReturnBackButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_ReturnBackButton> createState() => _ReturnBackButtonState();
}

class _ReturnBackButtonState extends State<_ReturnBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    return Tooltip(
      message: 'Return to Workflow Cards',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: isDark
              ? DesignTokens.darkSurfaceTwo
              : DesignTokens.neutralGrayOneHundred,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: widget.onTap,
            mouseCursor: SystemMouseCursors.click,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Opacity(
                      opacity: 0.001,
                      child: Icon(Icons.arrow_back_rounded, size: 24),
                    ),
                    AnimatedLineIcon(
                      type: LineIconType.arrowBack,
                      isHovered: _isHovered,
                      color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactBackButton extends StatefulWidget {
  const _CompactBackButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_CompactBackButton> createState() => _CompactBackButtonState();
}

class _CompactBackButtonState extends State<_CompactBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    return Tooltip(
      message: 'Back to Dashboard',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: isDark
              ? DesignTokens.darkSurfaceFour
              : DesignTokens.neutralGrayOneHundred,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: widget.onTap,
            mouseCursor: SystemMouseCursors.click,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedLineIcon(
                  type: LineIconType.arrowBack,
                  isHovered: _isHovered,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
