import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/models/kbbi_entry.dart';
import 'package:learn_english/services/kbbi_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KBBI Model tests', () {
    test('KbbiEntry parses correctly from JSON', () {
      final jsonMap = {
        'w': 'belajar',
        'c': 'Verba',
        'd': 'berusaha memperoleh kepandaian atau ilmu',
      };

      final entry = KbbiEntry.fromJson(jsonMap);
      expect(entry.word, 'belajar');
      expect(entry.category, 'Verba');
      expect(entry.definition, 'berusaha memperoleh kepandaian atau ilmu');

      final serialized = entry.toJson();
      expect(serialized['w'], 'belajar');
      expect(serialized['c'], 'Verba');
      expect(serialized['d'], 'berusaha memperoleh kepandaian atau ilmu');
    });

    test('BakuNonbakuEntry parses correctly', () {
      final jsonMap = {
        'id': 1,
        'word': 'Apotek',
        'wrong': 'Apotik',
        'explain': 'Kata baku menurut KBBI adalah Apotek.',
        'clue': 'Tempat menjual obat',
      };

      final entry = BakuNonbakuEntry.fromJson(jsonMap);
      expect(entry.id, 1);
      expect(entry.word, 'Apotek');
      expect(entry.wrong, 'Apotik');
      expect(entry.explain, contains('Apotek'));
      expect(entry.clue, 'Tempat menjual obat');
    });

    test('AntonimEntry parses correctly', () {
      final jsonMap = {
        'id': 1,
        'kata_a': 'baik',
        'kata_b': 'buruk',
        'jenis_oposisi': 'gradabel',
        'bidang': 'umum',
        'penjelasan': 'Lawan kata baik adalah buruk.',
      };

      final entry = AntonimEntry.fromJson(jsonMap);
      expect(entry.id, 1);
      expect(entry.kataA, 'baik');
      expect(entry.kataB, 'buruk');
      expect(entry.jenisOposisi, 'gradabel');
      expect(entry.bidang, 'umum');
      expect(entry.penjelasan, contains('buruk'));
    });
  });

  group('KbbiRepository tests', () {
    test('Initializes manifest and preloads letter A', () async {
      final repo = KbbiRepository.instance;
      await repo.init();

      expect(repo.isInitialized, isTrue);
      expect(repo.totalWords, 115978);
      expect(repo.bakuCount, 2847);
      expect(repo.antonimCount, 549);
      expect(repo.letterCounts.containsKey('A'), isTrue);

      final letterAEntries = await repo.loadLetter('a');
      expect(letterAEntries, isNotEmpty);
      expect(letterAEntries.first.word.toLowerCase().startsWith('a'), isTrue);
    });

    test('Filter KBBI by search query and category', () async {
      final repo = KbbiRepository.instance;
      await repo.init();

      final searchResults = await repo.getEntries(
        letter: 'A',
        query: 'abadi',
      );

      expect(searchResults, isNotEmpty);
      expect(searchResults.any((e) => e.word.contains('abadi')), isTrue);

      final categoryResults = await repo.getEntries(
        letter: 'A',
        category: 'Nomina',
      );
      expect(categoryResults, isNotEmpty);
      expect(categoryResults.every((e) => e.category == 'Nomina'), isTrue);

      // Relevance ranking test: searching 'nikah' must return 'nikah' first, NOT 'naik'
      final nikahResults = await repo.getEntries(query: 'nikah');
      expect(nikahResults, isNotEmpty);
      expect(nikahResults.first.word, 'nikah');
      // Verify that 'naik' does not come before 'nikah'
      final naikIndex = nikahResults.indexWhere((e) => e.word == 'naik');
      final nikahIndex = nikahResults.indexWhere((e) => e.word == 'nikah');
      expect(nikahIndex, lessThan(naikIndex));
    });

    test('Loads and searches BakuNonbaku and Antonim', () async {
      final repo = KbbiRepository.instance;
      await repo.init();

      final bakuList = await repo.loadBakuEntries();
      expect(bakuList, isNotEmpty);

      final bakuSearch = repo.searchBaku('Bujang');
      expect(bakuSearch, isNotEmpty);
      expect(bakuSearch.first.word, 'Bujang');

      final antonimList = await repo.loadAntonimEntries();
      expect(antonimList, isNotEmpty);

      final antonimSearch = repo.searchAntonim('baik');
      expect(antonimSearch, isNotEmpty);
      expect(antonimSearch.any((a) => a.kataA == 'baik' || a.kataB == 'baik'), isTrue);
    });
  });
}
