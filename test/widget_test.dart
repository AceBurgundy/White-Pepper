import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:white_pepper/main.dart';
import 'package:white_pepper/providers/app_state.dart';

void main() {
  testWidgets(
    'WhitePepperApp navigates Dashboard -> Options Control Deck -> Step-by-Step Instructions',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
          child: const WhitePepperApp(),
        ),
      );

      // 1. Dashboard Screen renders 4:3 Workstation and all 8 workflow cards
      expect(find.text('4:3 WORKSTATION'), findsOneWidget);
      expect(find.text('All Workflows (8)'), findsOneWidget);
      expect(find.text('Flatbed Document'), findsOneWidget);
      expect(find.text('Legal 2-Pass Stitch'), findsOneWidget);
      expect(find.text('ID Card Duplex'), findsOneWidget);
      expect(find.text('Compile PDF'), findsOneWidget);

      // 2. Clicking 'ID Card Duplex' transitions to Options Control Deck
      await tester.tap(find.text('ID Card Duplex'));
      await tester.pumpAndSettle();

      expect(find.text('4:3 CONTROL DECK'), findsOneWidget);
      expect(find.text('Tool & Parameter Adjustments'), findsOneWidget);
      expect(find.text('Start ID Card Duplex'), findsOneWidget);

      // 3. Clicking 'Start ID Card Duplex' transitions to Step-by-Step Instructions Screen
      await tester.tap(find.text('Start ID Card Duplex'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1 of 3'), findsWidgets);
      expect(find.text('LIVE CLI SUBPROCESS OUTPUT'), findsOneWidget);
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
        expect(find.text('4:3 CONTROL DECK'), findsOneWidget);

        // Switch to Step-by-Step Instructions at mobile resolution
        appState.beginInstructionsWorkflow();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('LIVE CLI SUBPROCESS OUTPUT'), findsOneWidget);
      }
    },
  );
}
