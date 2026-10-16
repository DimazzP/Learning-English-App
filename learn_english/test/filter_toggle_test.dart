import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/screens/tabs/grammar_guide_tab.dart';
import 'package:learn_english/screens/tabs/quiz_tab.dart';
import 'package:learn_english/screens/tabs/verb_list_tab.dart';
import 'package:learn_english/screens/tabs/universal_dictionary_tab.dart';
import 'package:learn_english/services/verb_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VerbRepository.instance.init();
  });

  group('Filter & Mode Collapsible Toggle Tests', () {
    testWidgets('GrammarGuideTab hides all modes and filters initially, toggles on header click',
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

      // 1. Initial state: both mode buttons and category chips are hidden
      expect(find.text('Tabel Grid Lengkap'), findsNothing);
      expect(find.text('Kartu Penjelasan'), findsNothing);
      expect(find.text('Present (4)'), findsNothing);
      expect(find.text('Past (4)'), findsNothing);

      // Only the Filter & Mode toggle header is shown
      expect(find.text('Tampilan & Filter Tenses'), findsOneWidget);

      // 2. Click Filter Header -> All modes and chips expand
      await tester.tap(find.text('Tampilan & Filter Tenses'));
      await tester.pumpAndSettle();

      expect(find.text('Tabel Grid Lengkap'), findsOneWidget);
      expect(find.text('Kartu Penjelasan'), findsOneWidget);
      expect(find.text('Present (4)'), findsOneWidget);
      expect(find.text('Past (4)'), findsOneWidget);

      // 3. Click again -> All modes and chips collapse
      await tester.tap(find.text('Tampilan & Filter Tenses'));
      await tester.pumpAndSettle();

      expect(find.text('Tabel Grid Lengkap'), findsNothing);
      expect(find.text('Present (4)'), findsNothing);
    });

    testWidgets('QuizTab hides primary categories, submodes, and filters initially, toggles on header click',
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

      // 1. Initial state: primary category (Kamus Verb), sub-mode (Pilihan Ganda), and filters are ALL hidden
      expect(find.text('Kamus Verb (V1, V2, V3)'), findsNothing);
      expect(find.text('Pilihan Ganda'), findsNothing);
      expect(find.text('Tingkat Kesulitan:'), findsNothing);
      expect(find.text('Semua Tenses'), findsNothing);

      // Only the Filter Header is shown
      expect(find.text('Filter & Mode Kuis'), findsOneWidget);

      // 2. Click Filter Header -> Everything expands
      await tester.tap(find.text('Filter & Mode Kuis'));
      await tester.pumpAndSettle();

      expect(find.text('Kamus Verb (V1, V2, V3)'), findsOneWidget);
      expect(find.text('Pilihan Ganda'), findsOneWidget);
      expect(find.text('Tingkat Kesulitan:'), findsOneWidget);
      expect(find.text('Semua Tenses'), findsOneWidget);

      // 3. Click again -> Everything collapses
      await tester.tap(find.text('Filter & Mode Kuis'));
      await tester.pumpAndSettle();

      expect(find.text('Kamus Verb (V1, V2, V3)'), findsNothing);
      expect(find.text('Pilihan Ganda'), findsNothing);
      expect(find.text('Tingkat Kesulitan:'), findsNothing);
      expect(find.text('Semua Tenses'), findsNothing);
    });

    testWidgets('VerbListTab hides filter chips initially, toggles on filter button click',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerbListTab(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial state: filter chips are hidden
      expect(find.text('Semua Bahasa'), findsNothing);
      expect(find.text('🇬🇧 Inggris'), findsNothing);

      final filterButton = find.byTooltip('Tampilkan Filter');
      expect(filterButton, findsOneWidget);

      // 2. Click Filter Button -> chips expand
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      expect(find.text('Semua Bahasa'), findsOneWidget);
      expect(find.text('🇬🇧 Inggris'), findsOneWidget);

      // 3. Click again -> chips collapse
      final hideButton = find.byTooltip('Sembunyikan Filter');
      expect(hideButton, findsOneWidget);
      await tester.tap(hideButton);
      await tester.pumpAndSettle();

      expect(find.text('Semua Bahasa'), findsNothing);
      expect(find.text('🇬🇧 Inggris'), findsNothing);
    });

    testWidgets('UniversalDictionaryTab hides modes and filters initially, toggles on filter button click',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UniversalDictionaryTab(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial state: mode buttons are hidden
      expect(find.text('Kamus KBBI (115.978)'), findsNothing);
      expect(find.text('Baku vs Nonbaku (2.847)'), findsNothing);

      final filterButton = find.byTooltip('Tampilkan Menu & Filter');
      expect(filterButton, findsOneWidget);

      // 2. Click Filter Button -> modes expand
      await tester.tap(filterButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Kamus KBBI (115.978)'), findsOneWidget);
      expect(find.text('Baku vs Nonbaku (2.847)'), findsOneWidget);

      // 3. Click again -> modes collapse
      final hideButton = find.byTooltip('Sembunyikan Menu & Filter');
      expect(hideButton, findsOneWidget);
      await tester.tap(hideButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Kamus KBBI (115.978)'), findsNothing);
      expect(find.text('Baku vs Nonbaku (2.847)'), findsNothing);
    });
  });
}
