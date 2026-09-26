class KbbiEntry {
  final String word;
  final String category;
  final String definition;

  const KbbiEntry({
    required this.word,
    required this.category,
    required this.definition,
  });

  factory KbbiEntry.fromJson(Map<String, dynamic> json) {
    return KbbiEntry(
      word: json['w'] as String? ?? '',
      category: json['c'] as String? ?? 'Lainnya',
      definition: json['d'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'w': word,
      'c': category,
      'd': definition,
    };
  }
}

class BakuNonbakuEntry {
  final int id;
  final String word;
  final String wrong;
  final String explain;
  final String clue;

  const BakuNonbakuEntry({
    required this.id,
    required this.word,
    required this.wrong,
    required this.explain,
    required this.clue,
  });

  factory BakuNonbakuEntry.fromJson(Map<String, dynamic> json) {
    return BakuNonbakuEntry(
      id: json['id'] as int? ?? 0,
      word: json['word'] as String? ?? '',
      wrong: json['wrong'] as String? ?? '',
      explain: json['explain'] as String? ?? '',
      clue: json['clue'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'wrong': wrong,
      'explain': explain,
      'clue': clue,
    };
  }
}

class AntonimEntry {
  final int id;
  final String kataA;
  final String kataB;
  final String jenisOposisi;
  final String bidang;
  final String penjelasan;

  const AntonimEntry({
    required this.id,
    required this.kataA,
    required this.kataB,
    required this.jenisOposisi,
    required this.bidang,
    required this.penjelasan,
  });

  factory AntonimEntry.fromJson(Map<String, dynamic> json) {
    return AntonimEntry(
      id: json['id'] as int? ?? 0,
      kataA: json['kata_a'] as String? ?? '',
      kataB: json['kata_b'] as String? ?? '',
      jenisOposisi: json['jenis_oposisi'] as String? ?? '',
      bidang: json['bidang'] as String? ?? '',
      penjelasan: json['penjelasan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kata_a': kataA,
      'kata_b': kataB,
      'jenis_oposisi': jenisOposisi,
      'bidang': bidang,
      'penjelasan': penjelasan,
    };
  }
}
