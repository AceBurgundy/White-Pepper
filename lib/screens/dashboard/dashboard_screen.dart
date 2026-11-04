import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/dialogs/hardware_connect_dialog.dart';
import '../instructions/instructions_screen.dart';
import '../options/options_screen.dart';
import 'workflow_grid.dart';

/// Unified 3-Screen Workstation matching minimalist/interactive-mockup/4-is-to-3/DesktopMockup.js
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool isDarkScreen = state.currentScreen != AppScreen.dashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFDCDCDC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints outerConstraints) {
            final bool isCompactOuter = outerConstraints.maxWidth < 860;
            return Padding(
              padding: EdgeInsets.all(isCompactOuter ? 8.0 : 20.0),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  constraints: const BoxConstraints(
                    maxWidth: 1240,
                    maxHeight: 860,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkScreen
                        ? DesignTokens.onyx
                        : DesignTokens.neutralLightSurface,
                    borderRadius: BorderRadius.circular(
                      isCompactOuter ? 24.0 : DesignTokens.radiusViewportDesktop,
                    ),
                    border: Border.all(
                      color: isDarkScreen
                          ? DesignTokens.darkSurfaceThree
                          : DesignTokens.onyx,
                      width: isCompactOuter ? 3.0 : 6.0,
                    ),
                    boxShadow: DesignTokens.shadowWorkstation,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: switch (state.currentScreen) {
                      AppScreen.dashboard => _buildDashboardPane(context, state),
                      AppScreen.options => const OptionsScreen(
                          key: ValueKey<String>('screen_options'),
                        ),
                      AppScreen.instructions => const InstructionsScreen(
                          key: ValueKey<String>('screen_instructions'),
                        ),
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardPane(BuildContext context, AppState state) {
    return LayoutBuilder(
      key: const ValueKey<String>('screen_dashboard'),
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact =
            constraints.maxWidth < 800 || constraints.maxHeight < 580;
        if (isCompact) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildSidebarTopContent(context, state),
                const SizedBox(height: 16),
                SizedBox(
                  height: 520,
                  child: WorkflowGrid(
                    onSelectWorkflow: (WorkflowType workflow) {},
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: _buildDockedNavPill(state)),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Left Sidebar (310px matching .desktop-dashboard-left)
              SizedBox(
                width: 310,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildSidebarTopContent(context, state),
                      ),
                    ),
                    _buildDockedNavPill(state),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right 2x4 Workflow Cards Grid (.desktop-dashboard-grid)
              Expanded(
                child: WorkflowGrid(
                  onSelectWorkflow: (WorkflowType workflow) {
                    // AppState.selectWorkflow already transitions currentScreen to AppScreen.options
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarTopContent(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Actions Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildCircleIconButton(
              icon: Icons.segment_rounded,
              tooltip: 'Workstation Menu',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const HardwareConnectDialog(),
                );
              },
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.pureWhite,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                  border: Border.all(
                    color: DesignTokens.neutralGrayTwoHundred,
                  ),
                ),
                child: const Text(
                  '4:3 WORKSTATION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.onyx,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            Stack(
              children: <Widget>[
                _buildCircleIconButton(
                  icon: Icons.notifications_rounded,
                  tooltip: 'Probe Scanner Hardware',
                  onTap: () {
                    state.runDiagnostics();
                    showDialog<void>(
                      context: context,
                      builder: (_) => const HardwareConnectDialog(),
                    );
                  },
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: DesignTokens.accentYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Headline ("Printer / Scanner Module")
        const Text(
          'Scanner\nModule',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: DesignTokens.onyx,
            height: 1.12,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Navigation Tabs Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => state.switchScreen(AppScreen.dashboard),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.onyx,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                  border: Border.all(
                    color: DesignTokens.darkSurfaceFour,
                  ),
                ),
                child: const Text(
                  'All Workflows (8)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.pureWhite,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const HardwareConnectDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.pureWhite,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.onyx,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.onyx.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusPill,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: state.isScannerOnline
                          ? DesignTokens.statusOnlineGreen
                          : DesignTokens.statusErrorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isScannerOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.onyx,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Connected Printer Status Card (.card--printer-status from DesktopMockup.js)
        _buildSidebarPrinterCard(context, state),
      ],
    );
  }

  Widget _buildDockedNavPill(AppState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: DesignTokens.onyx,
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
        boxShadow: DesignTokens.shadowFloatingPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildDockedNavButton(
            icon: Icons.print_rounded,
            tooltip: 'Dashboard Workflows',
            isActive: state.currentScreen == AppScreen.dashboard,
            onTap: () => state.switchScreen(AppScreen.dashboard),
          ),
          const SizedBox(width: 4),
          _buildDockedNavButton(
            icon: Icons.tune_rounded,
            tooltip: 'Options Control Deck',
            isActive: state.currentScreen == AppScreen.options,
            onTap: () => state.switchScreen(AppScreen.options),
          ),
          const SizedBox(width: 4),
          _buildDockedNavButton(
            icon: Icons.checklist_rtl_rounded,
            tooltip: 'Step-by-Step Instructions',
            isActive: state.currentScreen == AppScreen.instructions,
            onTap: () => state.beginInstructionsWorkflow(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarPrinterCard(BuildContext context, AppState state) {
    final List<Map<String, Object>> channels = <Map<String, Object>>[
      <String, Object>{'label': 'C', 'pct': 0.85, 'color': DesignTokens.inkCyan},
      <String, Object>{'label': 'M', 'pct': 0.72, 'color': DesignTokens.inkMagenta},
      <String, Object>{'label': 'Y', 'pct': 0.92, 'color': DesignTokens.inkYellow},
      <String, Object>{'label': 'K', 'pct': 0.64, 'color': DesignTokens.pureWhite},
    ];

    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (_) => const HardwareConnectDialog(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DesignTokens.onyx,
          borderRadius: BorderRadius.circular(28),
          boxShadow: DesignTokens.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.scannerModel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.pureWhite,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'eSCL • ${state.scannerEndpoint}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: DesignTokens.neutralGrayFiveHundred,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.darkSurfaceFour,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: state.isScannerOnline
                              ? DesignTokens.statusOnlineGreen
                              : DesignTokens.accentYellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.isScannerOnline ? 'Ready' : 'Wake',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.pureWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ink / Sensor Channel Bars + Quick Hardware Probe Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: channels.map((Map<String, Object> ch) {
                    final double pct = ch['pct']! as double;
                    final Color color = ch['color']! as Color;
                    final String label = ch['label']! as String;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 14,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DesignTokens.darkSurfaceFour,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 14,
                              height: 36 * pct,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.neutralGrayFiveHundred,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: DesignTokens.accentYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: DesignTokens.onyx,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: DesignTokens.darkSurfaceFour,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: DesignTokens.pureWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockedNavButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? DesignTokens.accentYellow : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? DesignTokens.onyx : DesignTokens.pureWhite,
          ),
        ),
      ),
    );
  }
}
