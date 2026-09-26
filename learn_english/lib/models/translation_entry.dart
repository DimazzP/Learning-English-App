class TranslationEntry {
  final String word;
  final String translation;

  const TranslationEntry({
    required this.word,
    required this.translation,
  });

  factory TranslationEntry.fromJson(Map<String, dynamic> json) {
    return TranslationEntry(
      word: json['w'] as String? ?? '',
      translation: json['t'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'w': word,
      't': translation,
    };
  }
}
