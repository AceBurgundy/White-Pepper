import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:white_pepper/main.dart';
import 'package:white_pepper/providers/app_state.dart';

void main() {
  testWidgets(
    'WhitePepperApp renders All-Day default theme, Switch Scanner button, View Printer dialog, and borderless 1.5x options deck',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      final AppState appState = AppState();
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const WhitePepperApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. All-Day (Light) theme is active by default
      expect(appState.isDarkMode, isFalse);

      // 2. Workstation Menu button is removed
      expect(find.byTooltip('Workstation Menu'), findsNothing);

      // 3. Night Mode toggle button is present in the top-right of the left sidebar
      final Finder nightModeBtn = find.byTooltip('Night Mode');
      expect(nightModeBtn, findsOneWidget);
      await tester.tap(nightModeBtn);
      await tester.pumpAndSettle();
      expect(appState.isDarkMode, isTrue);

      // Toggle back to Day Mode
      await tester.tap(find.byTooltip('Day Mode'));
      await tester.pumpAndSettle();
      expect(appState.isDarkMode, isFalse);

      // 4. Left printer card has Switch Scanner button with encircling icon
      final Finder switchScannerBtn = find.byTooltip('Switch Scanner');
      expect(switchScannerBtn, findsOneWidget);

      // Tap 'Switch Scanner' to open ScannerSelectorDialog
      await tester.tap(switchScannerBtn);
      await tester.pumpAndSettle();
      expect(find.text('Select Scanner'), findsOneWidget);
      expect(find.text('Scan for Printers'), findsOneWidget);

      // Close ScannerSelectorDialog
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byIcon(Icons.close_rounded),
        ),
      );
      await tester.pumpAndSettle();

      // 5. Left printer card has pointer hand cursor and 'View Printer' tooltip
      final Finder viewPrinterBtn = find.byTooltip('View Printer');
      expect(viewPrinterBtn, findsOneWidget);

      // Tap 'View Printer' to open dialog with C/M/Y/K ink levels & hardware diagnostics
      await tester.tap(viewPrinterBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Printer Details'), findsOneWidget);
      expect(find.text('INK LEVELS'), findsOneWidget);
      expect(find.text('HARDWARE DIAGNOSTICS'), findsOneWidget);
      expect(find.text('Check Scanner'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Switch Scanner'),
        ),
        findsOneWidget,
      );

      // Assert zero raw IP addresses (e.g., 192.168.) are visible anywhere in the UI
      expect(find.textContaining('192.168.'), findsNothing);

      // Close dialog
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byIcon(Icons.close_rounded),
        ),
      );
      await tester.pumpAndSettle();

      // 6. Docked bottom pill has Settings button and Instructions button
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.byTooltip('Step-by-Step Instructions'), findsOneWidget);

      // Open settings dialog
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Application Settings'), findsOneWidget);
      expect(find.text('APPLICATION THEME'), findsOneWidget);
      expect(find.text('MEASUREMENT UNITS'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byIcon(Icons.close_rounded),
        ),
      );
      await tester.pumpAndSettle();

      // 7. Workflow cards have descriptions and pills removed
      expect(find.text('Flatbed Document'), findsOneWidget);
      expect(find.text('Standard document & photo scanning'), findsNothing);

      // 8. Clicking 'Flatbed Document' transitions to Options Control Deck
      await tester.tap(find.text('Flatbed Document'));
      await tester.pumpAndSettle();

      expect(find.text('SCAN SETTINGS'), findsOneWidget);
      expect(find.text('Tool & Parameter Adjustments'), findsOneWidget);
      expect(find.text('Start Flatbed Document'), findsOneWidget);

      // 9. Active option title is centered below the options button
      expect(find.text(appState.activeTool.displayTitle), findsWidgets);

      // 10. Paper size pills are in Title Case (e.g. 'ID Card', 'A4', 'Letter')
      expect(find.text('ID Card'), findsWidgets);
      expect(find.text('A4'), findsWidgets);
      expect(find.text('Letter'), findsWidgets);

      // 11. Return to workflow cards has only the Back button (menu button removed)
      final Finder returnBackBtn = find.byTooltip('Return to Workflow Cards');
      expect(returnBackBtn, findsOneWidget);
      expect(
        find.descendant(
          of: returnBackBtn,
          matching: find.byIcon(Icons.arrow_back_rounded),
        ),
        findsOneWidget,
      );

      // 12. Clicking 'Start Flatbed Document' transitions to Step-by-Step Instructions Screen
      await tester.tap(find.text('Start Flatbed Document'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1 of 2'), findsWidgets);
      expect(find.text('SCANNER ACTIVITY'), findsOneWidget);

      // Assert zero developer/CLI jargon is visible in the UI
      expect(find.textContaining('scan_cli'), findsNothing);
      expect(find.textContaining('process_cli'), findsNothing);
      expect(find.textContaining('LIVE CLI'), findsNothing);
      expect(find.textContaining('Executing Python'), findsNothing);
      expect(find.textContaining('192.168.'), findsNothing);
    },
  );

  testWidgets(
    'WhitePepperApp renders with zero RenderFlex overflows at mobile 360x800 and 375x667 viewports',
    (WidgetTester tester) async {
      for (final Size mobileViewport in const <Size>[
        Size(360, 800),
        Size(375, 667),
      ]) {
        await tester.binding.setSurfaceSize(mobileViewport);
        final AppState appState = AppState();
        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const WhitePepperApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Switch Scanner Dialog opens cleanly without overflow at mobile size
        await tester.tap(find.byTooltip('Switch Scanner'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Select Scanner'), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.byIcon(Icons.close_rounded),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Switch to Options Control Deck at mobile resolution
        appState.switchScreen(AppScreen.options);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('SCAN SETTINGS'), findsOneWidget);

        // Switch to Step-by-Step Instructions at mobile resolution
        appState.beginInstructionsWorkflow();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('SCANNER ACTIVITY'), findsOneWidget);
      }
    },
  );
}
