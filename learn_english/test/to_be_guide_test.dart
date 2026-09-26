import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english/models/to_be_lesson.dart';

void main() {
  group('ToBeLesson and Data Tests', () {
    test('Core rules are loaded with valid structure and examples', () {
      expect(ToBeData.coreRules.isNotEmpty, isTrue);
      for (final rule in ToBeData.coreRules) {
        expect(rule.title.isNotEmpty, isTrue);
        expect(rule.formula.isNotEmpty, isTrue);
        expect(rule.examples.isNotEmpty, isTrue);
        for (final ex in rule.examples) {
          expect(ex.english.isNotEmpty, isTrue);
          expect(ex.indonesian.isNotEmpty, isTrue);
        }
      }
    });

    test('Subject matrix contains all primary personal pronouns', () {
      expect(ToBeData.subjectMatrix.length, 7);
      final subjects = ToBeData.subjectMatrix.map((e) => e.subject).toList();
      expect(subjects, containsAll(['I', 'You', 'We', 'They', 'He', 'She', 'It']));

      final iEntry = ToBeData.subjectMatrix.firstWhere((e) => e.subject == 'I');
      expect(iEntry.present, 'am');
      expect(iEntry.past, 'was');

      final theyEntry = ToBeData.subjectMatrix.firstWhere((e) => e.subject == 'They');
      expect(theyEntry.present, 'are');
      expect(theyEntry.past, 'were');
    });

    test('Common mistakes list has clear wrong and correct examples', () {
      expect(ToBeData.commonMistakes.isNotEmpty, isTrue);
      for (final item in ToBeData.commonMistakes) {
        expect(item.wrong.isNotEmpty, isTrue);
        expect(item.correct.isNotEmpty, isTrue);
        expect(item.whyWrong.isNotEmpty, isTrue);
        expect(item.tip.isNotEmpty, isTrue);
      }
      expect(ToBeData.commonMistakes.any((m) => m.wrong.contains('agree')), isTrue);
    });

    test('Practice questions has 30 items with valid options and single correct answer', () {
      expect(ToBeData.practiceQuestions.length, 30);
      for (final q in ToBeData.practiceQuestions) {
        expect(q.id.isNotEmpty, isTrue);
        expect(q.question.contains('_______'), isTrue);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
        expect(q.translation.isNotEmpty, isTrue);
      }
    });
  });
}
