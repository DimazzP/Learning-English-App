import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/screens/home_screen.dart';
import 'package:learn_english/services/verb_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VerbRepository.instance.init();
  });

  testWidgets('HomeScreen renders collapsible left sidebar navigation', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify expanded sidebar shows text labels
    expect(find.text('Kamus Verbs'), findsOneWidget);
    expect(find.text('Kamus Universal'), findsOneWidget);
    expect(find.text('Tata Bahasa'), findsOneWidget);
    expect(find.text('Split Tampilan'), findsWidgets);
    // Verify bottom action buttons exist in sidebar
    final themeTooltip = VerbRepository.instance.isDarkMode ? 'Mode Terang' : 'Mode Gelap';
    expect(find.byTooltip(themeTooltip), findsOneWidget);
    expect(find.byTooltip('Kata Kerja Acak'), findsOneWidget);
    expect(find.byTooltip('Info Aplikasi'), findsOneWidget);

    // Tap theme toggle and verify state changed
    final initialDarkMode = VerbRepository.instance.isDarkMode;
    await tester.tap(find.byTooltip(themeTooltip));
    await tester.pumpAndSettle();
    expect(VerbRepository.instance.isDarkMode, !initialDarkMode);

    // Find collapse button and tap it
    final collapseBtn = find.byTooltip('Perkecil Menu');
    expect(collapseBtn, findsOneWidget);
    await tester.tap(collapseBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // In small mode, expanded text labels should not appear in the sidebar list
    expect(find.text('Kamus Verbs'), findsNothing);
    expect(find.text('Kamus Universal'), findsNothing);
    expect(find.text('Tata Bahasa'), findsNothing);

    // Expand button tooltip should now be present
    final expandBtn = find.byTooltip('Perbesar Menu');
    expect(expandBtn, findsOneWidget);

    // Re-expand sidebar
    await tester.tap(expandBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kamus Verbs'), findsOneWidget);
  });
}
