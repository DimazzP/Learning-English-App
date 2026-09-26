class Verb {
  final String id;
  final String v1;
  final String v2;
  final String v3;
  final String vIng;
  final String vS;
  final String meaning;
  final String type; // 'regular' or 'irregular'
  final String difficulty; // 'Basic', 'Intermediate', 'Advanced'
  final String exampleSentence;
  final String exampleMeaning;
  final String tip;

  const Verb({
    required this.id,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.vIng,
    required this.vS,
    required this.meaning,
    required this.type,
    required this.difficulty,
    required this.exampleSentence,
    required this.exampleMeaning,
    required this.tip,
  });

  bool get isIrregular => type.toLowerCase() == 'irregular';
  bool get isRegular => type.toLowerCase() == 'regular';

  String get firstLetter {
    if (v1.isEmpty) return '#';
    final char = v1[0].toUpperCase();
    if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
      return char;
    }
    return '#';
  }

  factory Verb.fromJson(Map<String, dynamic> json) {
    return Verb(
      id: json['id'] as String? ?? '',
      v1: json['v1'] as String? ?? '',
      v2: json['v2'] as String? ?? '',
      v3: json['v3'] as String? ?? '',
      vIng: json['vIng'] as String? ?? '',
      vS: json['vS'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      type: json['type'] as String? ?? 'regular',
      difficulty: json['difficulty'] as String? ?? 'Basic',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      exampleMeaning: json['exampleMeaning'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'vIng': vIng,
      'vS': vS,
      'meaning': meaning,
      'type': type,
      'difficulty': difficulty,
      'exampleSentence': exampleSentence,
      'exampleMeaning': exampleMeaning,
      'tip': tip,
    };
  }
}
