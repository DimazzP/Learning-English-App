import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/screens/tabs/grammar_guide_tab.dart';
import 'package:learn_english/screens/tabs/quiz_tab.dart';
import 'package:learn_english/services/verb_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VerbRepository.instance.init();
  });

  group('Filter Toggle Tests', () {
    testWidgets('GrammarGuideTab hides filters initially and toggles on filter icon button click',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrammarGuideTab(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial state: filter chips should be hidden
      expect(find.text('Present (4)'), findsNothing);
      expect(find.text('Past (4)'), findsNothing);
      expect(find.text('Future (4)'), findsNothing);
      expect(find.text('Past Future (4)'), findsNothing);

      // Filter button should be present
      final filterButton = find.byTooltip('Tampilkan Filter');
      expect(filterButton, findsOneWidget);

      // 2. Click Filter button -> filters should appear
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      expect(find.text('Present (4)'), findsOneWidget);
      expect(find.text('Past (4)'), findsOneWidget);
      expect(find.text('Future (4)'), findsOneWidget);
      expect(find.text('Past Future (4)'), findsOneWidget);

      // 3. Click Filter button again -> filters should hide
      final hideFilterButton = find.byTooltip('Sembunyikan Filter');
      expect(hideFilterButton, findsOneWidget);
      await tester.tap(hideFilterButton);
      await tester.pumpAndSettle();

      expect(find.text('Present (4)'), findsNothing);
      expect(find.text('Past (4)'), findsNothing);
    });

    testWidgets('QuizTab hides filters initially and toggles on filter icon button click',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuizTab(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial state: difficulty and tense filters should be hidden
      expect(find.text('Tingkat Kesulitan:'), findsNothing);
      expect(find.text('Semua Tenses'), findsNothing);

      // Filter button should be present
      final filterButton = find.byTooltip('Tampilkan Filter');
      expect(filterButton, findsOneWidget);

      // 2. Click Filter button -> filters should appear
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      expect(find.text('Tingkat Kesulitan:'), findsOneWidget);
      expect(find.text('Semua Tenses'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);

      // 3. Click Filter button again -> filters should hide
      final hideFilterButton = find.byTooltip('Sembunyikan Filter');
      expect(hideFilterButton, findsOneWidget);
      await tester.tap(hideFilterButton);
      await tester.pumpAndSettle();

      expect(find.text('Tingkat Kesulitan:'), findsNothing);
      expect(find.text('Semua Tenses'), findsNothing);
    });
  });
}
