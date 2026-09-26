import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/services/translation_checker.dart';

void main() {
  group('TranslationChecker tests', () {
    const target = 'My sister studies English with her tutor every Tuesday evening.';
    final accepted = [
      'My sister studies English with her tutor every Tuesday evening.',
    ];

    test('Validates exact match correctly', () {
      final res = TranslationChecker.analyze(
        userInput: 'My sister studies English with her tutor every Tuesday evening.',
        targetSentence: target,
        acceptedAnswers: accepted,
        tenseName: 'Simple Present Tense',
      );

      expect(res.isCorrect, isTrue);
      expect(res.specificCorrections.isEmpty, isTrue);
    });

    test('Validates case-insensitive and punctuation-tolerant match', () {
      final res = TranslationChecker.analyze(
        userInput: 'my sister studies english with her tutor every tuesday evening',
        targetSentence: target,
        acceptedAnswers: accepted,
        tenseName: 'Simple Present Tense',
      );

      expect(res.isCorrect, isTrue);
    });

    test('Catches wrong verb form and pinpoints exact correction', () {
      final res = TranslationChecker.analyze(
        userInput: 'My sister study English with her tutor every Tuesday evening.',
        targetSentence: target,
        acceptedAnswers: accepted,
        tenseName: 'Simple Present Tense',
      );

      expect(res.isCorrect, isFalse);
      expect(res.comparisons.isNotEmpty, isTrue);
      expect(
        res.specificCorrections.any((c) => c.contains("Anda menulis 'study' ➔ seharusnya 'studies'")),
        isTrue,
      );
    });

    test('Catches missing words and provides clear notice', () {
      final res = TranslationChecker.analyze(
        userInput: 'My sister studies English.',
        targetSentence: target,
        acceptedAnswers: accepted,
        tenseName: 'Simple Present Tense',
      );

      expect(res.isCorrect, isFalse);
      expect(
        res.specificCorrections.any((c) => c.contains('belum lengkap')),
        isTrue,
      );
    });
  });
}
