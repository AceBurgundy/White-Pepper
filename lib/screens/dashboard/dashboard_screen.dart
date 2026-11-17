import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../models/scan_configuration_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/buttons/progress_button.dart';
import '../../widgets/common/printer_3d_visual.dart';
import '../../widgets/dialogs/app_settings_dialog.dart';
import '../../widgets/dialogs/hardware_connect_dialog.dart';
import '../../widgets/dialogs/scanner_selector_dialog.dart';
import '../../widgets/icons/animated_line_icons/animated_line_icons.dart';
import '../../widgets/loading/loading_screen.dart';
import '../../widgets/window/window_title_bar.dart';
import '../instructions/instructions_screen.dart';
import '../options/options_screen.dart';
import 'workflow_grid.dart';

/// Unified 3-Screen Workstation featuring unboxed 3D printer visuals,
/// status-reactive imagery, single-row carousel workflows, and docked navigation.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<LoadingScreenState> _loadingKey = GlobalKey<LoadingScreenState>();
  bool _showLoadingScreen = true;

  @override
  void initState() {
    super.initState();
    final bool isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    if (isTestEnvironment) {
      _showLoadingScreen = false;
    } else {
      Future<void>.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          _loadingKey.currentState?.dismiss();
        }
      });
    }
  }

  PrinterDeviceStatus _resolvePrinterStatus(AppState state) {
    if (!state.isScannerOnline) {
      return PrinterDeviceStatus.offline;
    }
    if (state.scanButtonState == ProgressButtonState.processing) {
      return PrinterDeviceStatus.scanning;
    }
    if (state.activeScanner == null && !state.isScannerOnline) {
      return PrinterDeviceStatus.standby;
    }
    return PrinterDeviceStatus.ready;
  }

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

              // Full-Screen Dual-Orb Loading Screen from documentation
              if (_showLoadingScreen)
                Positioned.fill(
                  child: LoadingScreen(
                    key: _loadingKey,
                    isDarkMode: isDark,
                    onDismissCompleted: () {
                      if (mounted) {
                        setState(() {
                          _showLoadingScreen = false;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPane(BuildContext context, AppState state, bool isDark) {
    final PrinterDeviceStatus printerStatus = _resolvePrinterStatus(state);

    return LayoutBuilder(
      key: const ValueKey<String>('screen_dashboard'),
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = (constraints.maxWidth < 740 || constraints.maxHeight < 640);
        final double topMargin = isCompact ? 14.0 : 36.0;
        final double bottomMargin = isCompact ? 18.0 : 44.0;
        final double bottomPillSpacing = isCompact ? 20.0 : 32.0;

        final Widget upperContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 1. Header Bar: White Pepper Headline + Workstation Pill + Theme Toggle
            _buildHeaderRow(context, state, isDark, isCompact),
            SizedBox(height: topMargin),

            // 2. Top Row with 2 Columns: Bigger 3D Printer Logo (Col 1) + Name, Status, Ink & Buttons (Col 2)
            _buildTopTwoColumnHero(context, state, isDark, printerStatus, isCompact),
            SizedBox(height: bottomMargin),

            // 3. Single-Row Carousel of Workflow Cards moved to the bottom
            WorkflowGrid(
              onSelectWorkflow: (WorkflowType workflow) {
                // AppState.selectWorkflow transitions currentScreen to AppScreen.options
              },
            ),
          ],
        );

        if (isCompact) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 44.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                upperContent,
                SizedBox(height: bottomPillSpacing),
                Center(child: _buildDockedNavPill(context, state, isDark)),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 48.0, 40.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              upperContent,
              Center(child: _buildDockedNavPill(context, state, isDark)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context, AppState state, bool isDark, bool isCompact) {
    if (isCompact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'White Pepper',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
              letterSpacing: -0.5,
            ),
          ),
          _CircleIconButton(
            lineIconType: LineIconType.themeToggle,
            tooltip: state.isDarkMode ? 'Day Mode' : 'Night Mode',
            isDark: isDark,
            onTap: () => state.toggleDarkMode(),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'White Pepper',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
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
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        _CircleIconButton(
          lineIconType: LineIconType.themeToggle,
          tooltip: state.isDarkMode ? 'Day Mode' : 'Night Mode',
          isDark: isDark,
          onTap: () => state.toggleDarkMode(),
        ),
      ],
    );
  }

  Widget _buildTopTwoColumnHero(
    BuildContext context,
    AppState state,
    bool isDark,
    PrinterDeviceStatus printerStatus,
    bool isCompact,
  ) {
    final Widget printerGraphic = Printer3DVisual(
      status: printerStatus,
      isDarkMode: isDark,
      width: isCompact ? 160.0 : 252.0,
      height: isCompact ? 112.0 : 176.0,
    );

    final Widget printerInfoColumn = _buildPrinterInfoColumn(
      context,
      state,
      isDark,
      printerStatus,
      isCompact,
    );

    if (isCompact) {
      return Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            printerGraphic,
            printerInfoColumn,
          ],
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          printerGraphic,
          const SizedBox(width: 40),
          printerInfoColumn,
        ],
      ),
    );
  }

  Widget _buildPrinterInfoColumn(
    BuildContext context,
    AppState state,
    bool isDark,
    PrinterDeviceStatus printerStatus,
    bool isCompact,
  ) {
    return Column(
      crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Printer Model Name
        Text(
          state.scannerModel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isCompact ? 18 : 22,
            fontWeight: FontWeight.w800,
            color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 5),

        // Status Badge, Connection Label & Workflows Tag
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _buildStatusGraphic(printerStatus, isDark),
            Text(
              state.scannerConnectionLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? DesignTokens.neutralGrayFourHundred : DesignTokens.neutralGraySixHundred,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
              ),
              child: Text(
                'All Workflows (${state.availableWorkflows.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? DesignTokens.onyx : DesignTokens.pureWhite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Ink Channels
        _buildInkLevelsRow(isDark),
        const SizedBox(height: 14),

        // Action Buttons ("Switch Scanner" & "View Printer")
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SwitchScannerButton(
              isDark: isDark,
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const ScannerSelectorDialog(),
                );
              },
            ),
            const SizedBox(width: 8),
            _ViewPrinterButton(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const HardwareConnectDialog(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInkLevelsRow(bool isDark) {
    final List<Map<String, Object>> inkChannels = <Map<String, Object>>[
      <String, Object>{'label': 'C', 'name': 'Cyan', 'percentage': 0.85, 'color': DesignTokens.inkCyan},
      <String, Object>{'label': 'M', 'name': 'Magenta', 'percentage': 0.72, 'color': DesignTokens.inkMagenta},
      <String, Object>{'label': 'Y', 'name': 'Yellow', 'percentage': 0.92, 'color': DesignTokens.inkYellow},
      <String, Object>{
        'label': 'K',
        'name': 'Black',
        'percentage': 0.64,
        'color': isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
      },
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: inkChannels.map((Map<String, Object> channelData) {
        final double percentage = channelData['percentage']! as double;
        final Color color = channelData['color']! as Color;
        final String label = channelData['label']! as String;
        final String channelName = channelData['name']! as String;

        return Tooltip(
          message: '$channelName: ${(percentage * 100).toInt()}%',
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 14,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.darkSurfaceFour
                        : DesignTokens.neutralGrayTwoHundred,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 14,
                    height: 38 * percentage,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? DesignTokens.neutralGrayFourHundred
                        : DesignTokens.neutralGraySixHundred,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusGraphic(PrinterDeviceStatus status, bool isDark) {
    final (Color badgeColor, Color textColor, IconData statusIcon, String statusTitle) = switch (status) {
      PrinterDeviceStatus.ready => (
          DesignTokens.statusOnlineGreen,
          Colors.white,
          Icons.check_circle_rounded,
          'Ready',
        ),
      PrinterDeviceStatus.scanning => (
          const Color(0xFF00E5FF),
          DesignTokens.onyx,
          Icons.radar_rounded,
          'Scanning',
        ),
      PrinterDeviceStatus.standby => (
          DesignTokens.accentYellow,
          DesignTokens.onyx,
          Icons.nightlight_round,
          'Wake',
        ),
      PrinterDeviceStatus.offline => (
          DesignTokens.statusErrorRed,
          Colors.white,
          Icons.cloud_off_rounded,
          'Offline',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            statusIcon,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
            ),
          ),
        ],
      ),
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
          _DockedNavButton(
            lineIconType: LineIconType.flatbed,
            tooltip: 'Dashboard Workflows',
            isActive: state.currentScreen == AppScreen.dashboard,
            onTap: () => state.switchScreen(AppScreen.dashboard),
          ),
          const SizedBox(width: 4),
          _DockedNavButton(
            lineIconType: LineIconType.settings,
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
          _DockedNavButton(
            lineIconType: LineIconType.instructions,
            tooltip: 'Step-by-Step Instructions',
            isActive: state.currentScreen == AppScreen.instructions,
            onTap: () => state.beginInstructionsWorkflow(),
          ),
        ],
      ),
    );
  }
}

class _SwitchScannerButton extends StatefulWidget {
  const _SwitchScannerButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_SwitchScannerButton> createState() => _SwitchScannerButtonState();
}

class _SwitchScannerButtonState extends State<_SwitchScannerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    return Tooltip(
      message: 'Switch Scanner',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.neutralGrayOneHundred
                  : DesignTokens.pureWhite,
              shape: BoxShape.circle,
              boxShadow: DesignTokens.shadowCard,
              border: Border.all(
                color: isDark
                    ? DesignTokens.neutralGrayThreeHundred
                    : DesignTokens.neutralGrayTwoHundred,
                width: 1.0,
              ),
            ),
            child: Center(
              child: AnimatedLineIcon(
                type: LineIconType.switchScanner,
                isHovered: _isHovered,
                color: DesignTokens.onyx,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewPrinterButton extends StatefulWidget {
  const _ViewPrinterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ViewPrinterButton> createState() => _ViewPrinterButtonState();
}

class _ViewPrinterButtonState extends State<_ViewPrinterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'View Printer',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignTokens.accentYellow,
              shape: BoxShape.circle,
              boxShadow: DesignTokens.shadowCard,
            ),
            child: Center(
              child: AnimatedLineIcon(
                type: LineIconType.printer,
                isHovered: _isHovered,
                color: DesignTokens.onyx,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatefulWidget {
  const _CircleIconButton({
    required this.lineIconType,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  final LineIconType lineIconType;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? DesignTokens.darkSurfaceFour : DesignTokens.pureWhite,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedLineIcon(
                type: widget.lineIconType,
                isHovered: _isHovered,
                color: isDark ? DesignTokens.pureWhite : DesignTokens.onyx,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockedNavButton extends StatefulWidget {
  const _DockedNavButton({
    required this.lineIconType,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  final LineIconType lineIconType;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_DockedNavButton> createState() => _DockedNavButtonState();
}

class _DockedNavButtonState extends State<_DockedNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? DesignTokens.accentYellow : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedLineIcon(
                type: widget.lineIconType,
                isHovered: _isHovered,
                color: isActive ? DesignTokens.onyx : DesignTokens.pureWhite,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
