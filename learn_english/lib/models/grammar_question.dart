class GrammarQuestion {
  final String id;
  final String category;
  final String level; // 'beginner', 'intermediate', 'expert'
  final String tenseType; // 'present', 'past', 'future', 'past_future'
  final String tenseName;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String translation;
  final String targetSentence;
  final String indonesianPrompt;
  final List<String> acceptedAnswers;

  const GrammarQuestion({
    required this.id,
    required this.category,
    required this.level,
    required this.tenseType,
    required this.tenseName,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.translation,
    required this.targetSentence,
    required this.indonesianPrompt,
    required this.acceptedAnswers,
  });

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    final questionText = json['question'] as String? ?? '';
    final answerText = json['correctAnswer'] as String? ?? '';
    final defaultTarget = questionText.replaceAll('_______', answerText);

    return GrammarQuestion(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'grammarly',
      level: json['level'] as String? ?? 'beginner',
      tenseType: json['tenseType'] as String? ?? 'present',
      tenseName: json['tenseName'] as String? ?? '',
      question: questionText,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer: answerText,
      explanation: json['explanation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      targetSentence: json['targetSentence'] as String? ?? defaultTarget,
      indonesianPrompt: json['indonesianPrompt'] as String? ?? (json['translation'] as String? ?? ''),
      acceptedAnswers: (json['acceptedAnswers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [defaultTarget],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'level': level,
      'tenseType': tenseType,
      'tenseName': tenseName,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'translation': translation,
      'targetSentence': targetSentence,
      'indonesianPrompt': indonesianPrompt,
      'acceptedAnswers': acceptedAnswers,
    };
  }
}
