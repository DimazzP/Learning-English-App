import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/translation_entry.dart';

enum TranslationDirection {
  idToEn, // Indonesia -> Inggris
  enToId, // Inggris -> Indonesia
}

class TranslationRepository extends ChangeNotifier {
  static final TranslationRepository instance = TranslationRepository._internal();
  factory TranslationRepository() => instance;

  TranslationRepository._internal();

  bool _isInitialized = false;
  bool _isLoading = false;

  int _totalIdEn = 30450;
  int _totalEnId = 23623;
  Map<String, int> _idLetterCounts = {};
  Map<String, int> _enLetterCounts = {};

  final Map<String, List<TranslationEntry>> _idShards = {};
  final Map<String, List<TranslationEntry>> _enShards = {};

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  int get totalIdEn => _totalIdEn;
  int get totalEnId => _totalEnId;
  Map<String, int> get idLetterCounts => _idLetterCounts;
  Map<String, int> get enLetterCounts => _enLetterCounts;

  Future<void> init() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      final manifestStr = await rootBundle.loadString('assets/data/dict/manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestStr);

      _totalIdEn = manifest['total_id_en'] as int? ?? 30450;
      _totalEnId = manifest['total_en_id'] as int? ?? 23623;

      if (manifest['id_letter_counts'] is Map) {
        _idLetterCounts = (manifest['id_letter_counts'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k.toUpperCase(), (v as num).toInt()),
        );
      }

      if (manifest['en_letter_counts'] is Map) {
        _enLetterCounts = (manifest['en_letter_counts'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k.toUpperCase(), (v as num).toInt()),
        );
      }

      // Preload letter 'a' for both directions
      await loadLetter('a', TranslationDirection.idToEn);
      await loadLetter('a', TranslationDirection.enToId);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing TranslationRepository: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<TranslationEntry>> loadLetter(
    String letter,
    TranslationDirection direction,
  ) async {
    final key = letter.toLowerCase();
    final shards = direction == TranslationDirection.idToEn ? _idShards : _enShards;

    if (shards.containsKey(key)) {
      return shards[key]!;
    }

    final subDir = direction == TranslationDirection.idToEn ? 'id_en' : 'en_id';
    final path = 'assets/data/dict/$subDir/$key.json';

    try {
      final jsonStr = await rootBundle.loadString(path);
      final List<dynamic> rawList = json.decode(jsonStr);
      final list = rawList
          .map((item) => TranslationEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      shards[key] = list;
      notifyListeners();
      return list;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load dict shard $path: $e');
      }
      return [];
    }
  }

  Future<List<TranslationEntry>> search({
    required String query,
    required TranslationDirection direction,
    String letter = 'a',
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    List<TranslationEntry> baseList;

    if (cleanQuery.isNotEmpty) {
      final firstChar = cleanQuery[0];
      if (RegExp(r'[a-z]').hasMatch(firstChar)) {
        baseList = await loadLetter(firstChar, direction);
      } else {
        baseList = await loadLetter(letter, direction);
      }
    } else {
      baseList = await loadLetter(letter, direction);
    }

    if (cleanQuery.isEmpty) {
      return baseList;
    }

    final wordBoundary = RegExp(r'\b' + RegExp.escape(cleanQuery) + r'\b');
    final scoredEntries = <({TranslationEntry entry, int score})>[];

    for (final entry in baseList) {
      final w = entry.word.toLowerCase();
      final t = entry.translation.toLowerCase();
      int score = 0;

      // 1. Exact match
      if (w == cleanQuery) {
        score = 10000;
      }
      // 2. Starts with query
      else if (w.startsWith(cleanQuery)) {
        final diff = w.length - cleanQuery.length;
        score = 5000 - (diff * 20).clamp(0, 2000);
      }
      // 3. Word contains query as exact word boundary (e.g. "buku nikah")
      else if (wordBoundary.hasMatch(w)) {
        score = 3000;
      }
      // 4. Word contains query substring
      else if (w.contains(cleanQuery)) {
        final diff = w.length - cleanQuery.length;
        score = 2000 - diff.clamp(0, 1000);
      }
      // 5. Translation contains query as whole word
      else if (wordBoundary.hasMatch(t)) {
        score = 500;
      }
      // 6. Translation contains query substring
      else if (t.contains(cleanQuery)) {
        score = 200;
      }

      if (score > 0) {
        scoredEntries.add((entry: entry, score: score));
      }
    }

    // Sort by score descending, then word length, then alphabetical
    scoredEntries.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      final lenCmp = a.entry.word.length.compareTo(b.entry.word.length);
      if (lenCmp != 0) return lenCmp;
      return a.entry.word.compareTo(b.entry.word);
    });

    return scoredEntries.map((e) => e.entry).toList();
  }
}
