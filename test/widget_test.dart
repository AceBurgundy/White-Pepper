import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:white_pepper/main.dart';
import 'package:white_pepper/providers/app_state.dart';

void main() {
  testWidgets(
    'WhitePepperApp renders seamless top bar, right-most window actions, black line icons, and custom scroll thumb',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
          child: const WhitePepperApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Sidebar headline displays 'White Pepper' instead of 'Scanner Module'
      expect(find.text('White Pepper'), findsOneWidget);
      expect(find.text('Scanner\nModule'), findsNothing);
      expect(find.textContaining('Scanner Module'), findsNothing);
      expect(find.text('WORKSTATION'), findsOneWidget);
      expect(find.text('All Workflows (8)'), findsOneWidget);

      // 2. Top bar window action buttons sit at the far rightmost side of the 1280px window
      final Offset closeTopRight =
          tester.getTopRight(find.byTooltip('Close'));
      expect(closeTopRight.dx, greaterThan(1250.0));

      // 3. Old emoji icons are gone; black line icons are used on workflow cards
      expect(find.text('📄'), findsNothing);
      expect(find.text('🔍'), findsNothing);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.crop_free_outlined), findsOneWidget);

      // 4. Custom thin scroll thumb is present on the right cards section
      expect(
        find.byKey(const Key('workflow_grid_scroll_thumb')),
        findsOneWidget,
      );

      // 5. Clicking 'ID Card Duplex' transitions to Options Control Deck
      await tester.tap(find.text('ID Card Duplex'));
      await tester.pumpAndSettle();

      expect(find.text('SCAN SETTINGS'), findsOneWidget);
      expect(find.text('Tool & Parameter Adjustments'), findsOneWidget);
      expect(find.text('Start ID Card Duplex'), findsOneWidget);
      expect(find.text('Active Settings:'), findsOneWidget);

      // 6. Clicking 'Start ID Card Duplex' transitions to Step-by-Step Instructions Screen
      await tester.tap(find.text('Start ID Card Duplex'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1 of 3'), findsWidgets);
      expect(find.text('SCANNER ACTIVITY'), findsOneWidget);

      // Assert zero developer/CLI jargon is visible in the UI
      expect(find.textContaining('scan_cli'), findsNothing);
      expect(find.textContaining('process_cli'), findsNothing);
      expect(find.textContaining('LIVE CLI'), findsNothing);
      expect(find.textContaining('Executing Python'), findsNothing);
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
