import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/design_tokens.dart';
import 'providers/app_state.dart';
import 'screens/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();
      final WindowOptions windowOptions = const WindowOptions(
        size: Size(DesignTokens.desktopWidth, DesignTokens.desktopHeight),
        minimumSize: Size(920, 660),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: 'White Pepper',
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setAsFrameless();
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (exception) {
      debugPrint('Window manager initialization notice: $exception');
    }
  }

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: const WhitePepperApp(),
    ),
  );
}

class WhitePepperApp extends StatelessWidget {
  const WhitePepperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White-Pepper Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
