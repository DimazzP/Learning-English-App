class WordComparison {
  final String userWord;
  final String targetWord;
  final bool isMatch;
  final bool isMissing;
  final bool isExtra;

  WordComparison({
    required this.userWord,
    required this.targetWord,
    required this.isMatch,
    this.isMissing = false,
    this.isExtra = false,
  });
}

class TranslationAnalysis {
  final bool isCorrect;
  final String userText;
  final String targetText;
  final String feedbackMessage;
  final List<WordComparison> comparisons;
  final List<String> specificCorrections;

  TranslationAnalysis({
    required this.isCorrect,
    required this.userText,
    required this.targetText,
    required this.feedbackMessage,
    required this.comparisons,
    required this.specificCorrections,
  });
}

class TranslationChecker {
  static String _cleanPunctuation(String text) {
    return text.replaceAll(RegExp(r'[.,!?;:"]'), '').trim();
  }

  static TranslationAnalysis analyze({
    required String userInput,
    required String targetSentence,
    required List<String> acceptedAnswers,
    required String tenseName,
  }) {
    final cleanUser = _cleanPunctuation(userInput).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final cleanTargets = acceptedAnswers
        .map((a) => _cleanPunctuation(a).toLowerCase().replaceAll(RegExp(r'\s+'), ' '))
        .toList();

    // Check exact match with any accepted answer
    if (cleanTargets.contains(cleanUser)) {
      return TranslationAnalysis(
        isCorrect: true,
        userText: userInput.trim(),
        targetText: targetSentence,
        feedbackMessage: 'Luar biasa! Penulisan terjemahan bahasa Inggris Anda 100% tepat.',
        comparisons: [],
        specificCorrections: [],
      );
    }

    // Otherwise analyze mismatch word by word with targetSentence
    final targetClean = _cleanPunctuation(targetSentence);
    final userClean = _cleanPunctuation(userInput);

    final uWords = userClean.isEmpty ? <String>[] : userClean.split(RegExp(r'\s+'));
    final tWords = targetClean.split(RegExp(r'\s+'));

    final comparisons = <WordComparison>[];
    final corrections = <String>[];

    final maxLen = uWords.length > tWords.length ? uWords.length : tWords.length;

    for (int i = 0; i < maxLen; i++) {
      if (i < uWords.length && i < tWords.length) {
        final uw = uWords[i];
        final tw = tWords[i];
        final match = uw.toLowerCase() == tw.toLowerCase();

        comparisons.add(WordComparison(
          userWord: uw,
          targetWord: tw,
          isMatch: match,
        ));

        if (!match) {
          corrections.add("Kata ke-${i + 1}: Anda menulis '$uw' ➔ seharusnya '$tw'.");
        }
      } else if (i >= uWords.length) {
        // Missing words from user
        final tw = tWords[i];
        comparisons.add(WordComparison(
          userWord: '',
          targetWord: tw,
          isMatch: false,
          isMissing: true,
        ));
        corrections.add("Kata ke-${i + 1}: Kurang kata '$tw'.");
      } else {
        // Extra words from user
        final uw = uWords[i];
        comparisons.add(WordComparison(
          userWord: uw,
          targetWord: '',
          isMatch: false,
          isExtra: true,
        ));
        corrections.add("Kata ke-${i + 1}: Kata tambahan '$uw' tidak diperlukan.");
      }
    }

    if (uWords.length < tWords.length) {
      final diff = tWords.length - uWords.length;
      corrections.insert(0, 'Kalimat Anda belum lengkap (kurang $diff kata).');
    } else if (uWords.length > tWords.length) {
      final diff = uWords.length - tWords.length;
      corrections.insert(0, 'Kalimat Anda memiliki $diff kata berlebih.');
    }

    return TranslationAnalysis(
      isCorrect: false,
      userText: userInput.trim(),
      targetText: targetSentence,
      feedbackMessage: 'Ada kesalahan penulisan dalam terjemahan Anda.',
      comparisons: comparisons,
      specificCorrections: corrections,
    );
  }
}
