class TenseFunction {
  final String title;
  final String explanation;
  final String example;
  final String meaning;

  const TenseFunction({
    required this.title,
    required this.explanation,
    required this.example,
    required this.meaning,
  });

  factory TenseFunction.fromJson(Map<String, dynamic> json) {
    return TenseFunction(
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      example: json['example'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
    );
  }
}

class TenseFormulas {
  final Map<String, String> verbal;
  final Map<String, String> nominal;

  const TenseFormulas({
    required this.verbal,
    required this.nominal,
  });

  factory TenseFormulas.fromJson(Map<String, dynamic> json) {
    final verbalMap = (json['verbal'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {};
    final nominalMap = (json['nominal'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {};

    return TenseFormulas(
      verbal: verbalMap,
      nominal: nominalMap,
    );
  }
}

class TenseExample {
  final String type;
  final String sentence;
  final String meaning;

  const TenseExample({
    required this.type,
    required this.sentence,
    required this.meaning,
  });

  factory TenseExample.fromJson(Map<String, dynamic> json) {
    return TenseExample(
      type: json['type'] as String? ?? '',
      sentence: json['sentence'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
    );
  }
}

class Tense {
  final String id;
  final String name;
  final String category; // Present, Past, Future, Past Future
  final String shortSummary;
  final String description;
  final String verbFormUsed;
  final List<TenseFunction> functions;
  final TenseFormulas formulas;
  final List<String> timeSignals;
  final List<TenseExample> examples;
  final String tips;

  const Tense({
    required this.id,
    required this.name,
    required this.category,
    required this.shortSummary,
    required this.description,
    required this.verbFormUsed,
    required this.functions,
    required this.formulas,
    required this.timeSignals,
    required this.examples,
    required this.tips,
  });

  factory Tense.fromJson(Map<String, dynamic> json) {
    return Tense(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shortSummary: json['shortSummary'] as String? ?? '',
      description: json['description'] as String? ?? '',
      verbFormUsed: json['verbFormUsed'] as String? ?? '',
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => TenseFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      formulas: TenseFormulas.fromJson(json['formulas'] as Map<String, dynamic>? ?? {}),
      timeSignals: (json['timeSignals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => TenseExample.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tips: json['tips'] as String? ?? '',
    );
  }
}
