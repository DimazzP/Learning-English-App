import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/models/verb.dart';
import 'package:learn_english/services/verb_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Verb model tests', () {
    test('Correctly identifies irregular and regular verbs', () {
      const irregularVerb = Verb(
        id: 'go',
        v1: 'go',
        v2: 'went',
        v3: 'gone',
        vIng: 'going',
        vS: 'goes',
        meaning: 'pergi',
        type: 'irregular',
        difficulty: 'Basic',
        exampleSentence: 'I go to school.',
        exampleMeaning: 'Saya pergi ke sekolah.',
        tip: 'go - went - gone',
      );

      expect(irregularVerb.isIrregular, isTrue);
      expect(irregularVerb.isRegular, isFalse);
      expect(irregularVerb.firstLetter, 'G');

      const regularVerb = Verb(
        id: 'accept',
        v1: 'accept',
        v2: 'accepted',
        v3: 'accepted',
        vIng: 'accepting',
        vS: 'accepts',
        meaning: 'menerima',
        type: 'regular',
        difficulty: 'Basic',
        exampleSentence: 'They accepted the offer.',
        exampleMeaning: 'Mereka menerima tawaran itu.',
        tip: 'Tambah -ed',
      );

      expect(regularVerb.isRegular, isTrue);
      expect(regularVerb.isIrregular, isFalse);
      expect(regularVerb.firstLetter, 'A');
    });

    test('Serializes to and from JSON', () {
      final jsonMap = {
        'id': 'eat',
        'v1': 'eat',
        'v2': 'ate',
        'v3': 'eaten',
        'vIng': 'eating',
        'vS': 'eats',
        'meaning': 'makan',
        'type': 'irregular',
        'difficulty': 'Basic',
        'exampleSentence': 'We ate dinner.',
        'exampleMeaning': 'Kami makan malam.',
        'tip': 'eat - ate - eaten',
      };

      final verb = Verb.fromJson(jsonMap);
      expect(verb.id, 'eat');
      expect(verb.v1, 'eat');
      expect(verb.v2, 'ate');
      expect(verb.v3, 'eaten');
      expect(verb.meaning, 'makan');

      final outputMap = verb.toJson();
      expect(outputMap['id'], 'eat');
      expect(outputMap['v2'], 'ate');
    });
  });

  group('Verb repository init and search tests', () {
    test('Loads verbs from asset and filters properly', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = VerbRepository.instance;
      await repo.init();

      expect(repo.allVerbs.isNotEmpty, isTrue);
      expect(repo.allVerbs.length, greaterThanOrEqualTo(200));

      // Test irregular vs regular counts
      expect(repo.irregularVerbs.isNotEmpty, isTrue);
      expect(repo.regularVerbs.isNotEmpty, isTrue);

      // Test filter by query (V1)
      final searchGo = repo.filter(query: 'go');
      expect(searchGo.any((v) => v.v1.toLowerCase() == 'go'), isTrue);

      // Test filter by query (V2)
      final searchWent = repo.filter(query: 'went');
      expect(searchWent.any((v) => v.v2.toLowerCase() == 'went'), isTrue);

      // Test filter by meaning
      final searchMakan = repo.filter(query: 'makan');
      expect(searchMakan.any((v) => v.meaning.toLowerCase().contains('makan')), isTrue);

      // Test relevance ranking in VerbRepository: exact match 'go' is first
      final searchGoExact = repo.filter(query: 'go');
      expect(searchGoExact.first.v1, 'go');

      // Test language filter: en vs id
      final searchEnOnly = repo.filter(query: 'go', languageFilter: 'en');
      expect(searchEnOnly.every((v) => v.v1.contains('go') || v.v2.contains('go') || v.v3.contains('go') || v.vIng.contains('go')), isTrue);

      final searchIdOnly = repo.filter(query: 'pergi', languageFilter: 'id');
      expect(searchIdOnly.any((v) => v.meaning.toLowerCase().contains('pergi')), isTrue);

      // Test filter by letter
      final filterB = repo.filter(letterFilter: 'B');
      expect(filterB.every((v) => v.firstLetter == 'B'), isTrue);

      // Test quiz generation
      final qV2 = repo.generateQuizQuestion(mode: 'v2');
      expect(qV2.options.length, 4);
      expect(qV2.options.contains(qV2.correctAnswer), isTrue);

      final qV3 = repo.generateQuizQuestion(mode: 'v3');
      expect(qV3.options.length, 4);
      expect(qV3.options.contains(qV3.correctAnswer), isTrue);

      final qMeaning = repo.generateQuizQuestion(mode: 'meaning');
      expect(qMeaning.options.length, 4);
      expect(qMeaning.options.contains(qMeaning.correctAnswer), isTrue);

      // Test 16 tenses loaded
      expect(repo.allTenses.length, 16);
      expect(repo.allTenses.any((t) => t.id == 'simple_present'), isTrue);
      expect(repo.allTenses.any((t) => t.id == 'past_perfect_continuous'), isTrue);

      // Test 202 grammar questions loaded
      expect(repo.allGrammarQuestions.length, 202);

      // Test filter by level
      final qBeginner = repo.generateGrammarQuizQuestion(level: 'beginner');
      expect(qBeginner, isNotNull);
      expect(qBeginner!.question.level, 'beginner');

      final qIntermediate = repo.generateGrammarQuizQuestion(level: 'intermediate');
      expect(qIntermediate, isNotNull);
      expect(qIntermediate!.question.level, 'intermediate');

      final qExpert = repo.generateGrammarQuizQuestion(level: 'expert');
      expect(qExpert, isNotNull);
      expect(qExpert!.question.level, 'expert');

      // Test filter by tenseType
      final qPres = repo.generateGrammarQuizQuestion(tenseType: 'present');
      expect(qPres, isNotNull);
      expect(qPres!.question.tenseType, 'present');
      expect(qPres.shuffledOptions.length, 4);
      expect(qPres.shuffledOptions.contains(qPres.question.correctAnswer), isTrue);

      final qPast = repo.generateGrammarQuizQuestion(tenseType: 'past');
      expect(qPast, isNotNull);
      expect(qPast!.question.tenseType, 'past');

      final qFut = repo.generateGrammarQuizQuestion(tenseType: 'future');
      expect(qFut, isNotNull);
      expect(qFut!.question.tenseType, 'future');

      final qPfut = repo.generateGrammarQuizQuestion(tenseType: 'past_future');
      expect(qPfut, isNotNull);
      expect(qPfut!.question.tenseType, 'past_future');

      // Test excludeIds to prevent repeated questions
      final seenIds = <String>{};
      final firstQ = repo.generateGrammarQuizQuestion(level: 'expert', tenseType: 'present', excludeIds: seenIds);
      expect(firstQ, isNotNull);
      seenIds.add(firstQ!.question.id);

      final secondQ = repo.generateGrammarQuizQuestion(level: 'expert', tenseType: 'present', excludeIds: seenIds);
      expect(secondQ, isNotNull);
      expect(secondQ!.question.id, isNot(equals(firstQ.question.id)));

      // Test verb quiz excludeIds
      final seenVerbs = <String>{};
      final firstVerb = repo.generateQuizQuestion(mode: 'v2', excludeIds: seenVerbs);
      seenVerbs.add(firstVerb.verb.id);
      final secondVerb = repo.generateQuizQuestion(mode: 'v2', excludeIds: seenVerbs);
      expect(secondVerb.verb.id, isNot(equals(firstVerb.verb.id)));
    });
  });
}
