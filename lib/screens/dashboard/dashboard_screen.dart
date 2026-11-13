import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/dialogs/app_settings_dialog.dart';
import '../../widgets/dialogs/hardware_connect_dialog.dart';
import '../../widgets/dialogs/scanner_selector_dialog.dart';
import '../../widgets/window/window_title_bar.dart';
import '../instructions/instructions_screen.dart';
import '../options/options_screen.dart';
import 'workflow_grid.dart';

/// Unified 3-Screen Workstation matching minimalist design system
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool isDark = state.isDarkMode;
    final String viewSubtitle = switch (state.currentScreen) {
      AppScreen.dashboard => 'Workstation',
      AppScreen.options => 'Scan Settings',
      AppScreen.instructions => 'Guided Scan',
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.onyx
                : DesignTokens.neutralLightSurface,
            borderRadius: BorderRadius.circular(
              DesignTokens.radiusViewportDesktop,
            ),
            border: Border.all(
              color: isDark
                  ? DesignTokens.darkSurfaceThree
                  : DesignTokens.neutralGrayThreeHundred,
              width: 1.0,
            ),
            boxShadow: DesignTokens.shadowWorkstation,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              // Main Application Content filling 100% of the window body
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (state.currentScreen) {
                    AppScreen.dashboard => _buildDashboardPane(context, state, isDark),
                    AppScreen.options => const OptionsScreen(
                        key: ValueKey<String>('screen_options'),
                      ),
                    AppScreen.instructions => const InstructionsScreen(
                        key: ValueKey<String>('screen_instructions'),
                      ),
                  },
                ),
              ),

              // Seamless Top Bar integrated directly into the top of the body
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: WindowTitleBar(
                  isDark: isDark,
                  subtitle: viewSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPane(BuildContext context, AppState state, bool isDark) {
    return LayoutBuilder(
      key: const ValueKey<String>('screen_dashboard'),
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = (constraints.maxWidth < 800 || constraints.maxHeight < 580);
        if (isCompact) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 38.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildSidebarTopContent(context, state, isDark),
                const SizedBox(height: 16),
                SizedBox(
                  height: 520,
                  child: WorkflowGrid(
                    onSelectWorkflow: (WorkflowType workflow) {},
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: _buildDockedNavPill(context, state, isDark)),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(28.0, 38.0, 28.0, 28.0),
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
                        child: _buildSidebarTopContent(context, state, isDark),
                      ),
                    ),
                    _buildDockedNavPill(context, state, isDark),
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

  Widget _buildSidebarTopContent(BuildContext context, AppState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Actions Bar (Workstation Pill + Night Mode Button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.pureWhite,
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusPill,
                ),
                border: Border.all(
                  color: isDark ? DesignTokens.darkSurfaceFive : DesignTokens.neutralGrayTwoHundred,
                ),
              ),
              child: Text(
                'WORKSTATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            _buildCircleIconButton(
              icon: state.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              tooltip: state.isDarkMode ? 'Day Mode' : 'Night Mode',
              isDark: isDark,
              onTap: () => state.toggleDarkMode(),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Headline ("White Pepper")
        Text(
          'White Pepper',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
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
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusPill,
                  ),
                ),
                child: Text(
                  'All Workflows (${WorkflowType.values.length})',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
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
                color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.onyx.withValues(alpha: 0.08),
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
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Connected Printer Status Card (.card--printer-status)
        _buildSidebarPrinterCard(context, state, isDark),
      ],
    );
  }

  Widget _buildDockedNavPill(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurfaceTwo : DesignTokens.onyx,
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
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            isActive: false,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => const AppSettingsDialog(),
              );
            },
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

  Widget _buildSidebarPrinterCard(BuildContext context, AppState state, bool isDark) {
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
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
          boxShadow: DesignTokens.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    state.scannerModel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.pureWhite,
                    ),
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

            // Ink Channel Bars + View Printer Tooltip/Hand Button
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Tooltip(
                      message: 'Switch Scanner',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => const ScannerSelectorDialog(),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: DesignTokens.darkSurfaceFour,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignTokens.pureWhite.withValues(alpha: 0.15),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.sync_rounded,
                              color: DesignTokens.pureWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'View Printer',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => const HardwareConnectDialog(),
                            );
                          },
                          child: Container(
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
                        ),
                      ),
                    ),
                  ],
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
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.pureWhite,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
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
