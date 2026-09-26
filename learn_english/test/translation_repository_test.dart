import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/models/translation_entry.dart';
import 'package:learn_english/services/translation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TranslationEntry model tests', () {
    test('Serializes to and from JSON', () {
      final entry = const TranslationEntry(
        word: 'nikah',
        translation: '1 marriage, wedding. 2 marry.',
      );

      final jsonMap = entry.toJson();
      expect(jsonMap['w'], 'nikah');
      expect(jsonMap['t'], '1 marriage, wedding. 2 marry.');

      final fromJson = TranslationEntry.fromJson(jsonMap);
      expect(fromJson.word, 'nikah');
      expect(fromJson.translation, '1 marriage, wedding. 2 marry.');
    });
  });

  group('TranslationRepository tests', () {
    test('Initializes manifest and letter shards', () async {
      final repo = TranslationRepository.instance;
      await repo.init();

      expect(repo.isInitialized, isTrue);
      expect(repo.totalIdEn, 30450);
      expect(repo.totalEnId, 23623);
      expect(repo.idLetterCounts.containsKey('A'), isTrue);
      expect(repo.enLetterCounts.containsKey('A'), isTrue);
    });

    test('Searches Indonesia to English with exact match priority', () async {
      final repo = TranslationRepository.instance;
      await repo.init();

      // Search 'nikah' in ID -> EN
      final results = await repo.search(
        query: 'nikah',
        direction: TranslationDirection.idToEn,
      );

      expect(results, isNotEmpty);
      // Exact match 'nikah' must be first!
      expect(results.first.word, 'nikah');
      expect(results.first.translation, contains('marriage'));
    });

    test('Searches English to Indonesia with exact match priority', () async {
      final repo = TranslationRepository.instance;
      await repo.init();

      // Search 'marry' in EN -> ID
      final results = await repo.search(
        query: 'marry',
        direction: TranslationDirection.enToId,
      );

      expect(results, isNotEmpty);
      // Exact match 'marry' must be first!
      expect(results.first.word, 'marry');
      expect(results.first.translation, contains('kawin'));
    });

    test('Loads letter shard for empty query', () async {
      final repo = TranslationRepository.instance;
      await repo.init();

      final listA = await repo.search(
        query: '',
        direction: TranslationDirection.idToEn,
        letter: 'b',
      );

      expect(listA, isNotEmpty);
      expect(listA.first.word.toLowerCase().startsWith('b'), isTrue);
    });
  });
}
