import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/kbbi_entry.dart';

class KbbiRepository extends ChangeNotifier {
  static final KbbiRepository instance = KbbiRepository._internal();
  factory KbbiRepository() => instance;

  KbbiRepository._internal();

  bool _isInitialized = false;
  bool _isLoading = false;

  int _totalWords = 115978;
  Map<String, int> _letterCounts = {};
  Map<String, int> _classCounts = {};
  int _bakuCount = 2847;
  int _antonimCount = 549;

  final Map<String, List<KbbiEntry>> _loadedShards = {};
  List<BakuNonbakuEntry> _bakuEntries = [];
  List<AntonimEntry> _antonimEntries = [];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  int get totalWords => _totalWords;
  Map<String, int> get letterCounts => _letterCounts;
  Map<String, int> get classCounts => _classCounts;
  int get bakuCount => _bakuCount;
  int get antonimCount => _antonimCount;
  List<BakuNonbakuEntry> get bakuEntries => _bakuEntries;
  List<AntonimEntry> get antonimEntries => _antonimEntries;

  Future<void> init() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      final manifestStr = await rootBundle.loadString('assets/data/kbbi/manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestStr);

      _totalWords = manifest['total_words'] as int? ?? 115978;
      _bakuCount = manifest['baku_count'] as int? ?? 2847;
      _antonimCount = manifest['antonim_count'] as int? ?? 549;

      if (manifest['letters'] is Map) {
        _letterCounts = (manifest['letters'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k.toUpperCase(), (v as num).toInt()),
        );
      }

      if (manifest['classes'] is Map) {
        _classCounts = (manifest['classes'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
      }

      // Preload letter 'A' by default so initial view renders immediately
      await loadLetter('a');
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing KbbiRepository: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<KbbiEntry>> loadLetter(String letter) async {
    final key = letter.toLowerCase();
    if (_loadedShards.containsKey(key)) {
      return _loadedShards[key]!;
    }

    try {
      final path = 'assets/data/kbbi/$key.json';
      final jsonStr = await rootBundle.loadString(path);
      final List<dynamic> rawList = json.decode(jsonStr);
      final list = rawList
          .map((item) => KbbiEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      _loadedShards[key] = list;
      notifyListeners();
      return list;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load KBBI shard for letter $letter: $e');
      }
      return [];
    }
  }

  Future<List<KbbiEntry>> getEntries({
    String letter = 'a',
    String query = '',
    String category = 'all',
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    List<KbbiEntry> baseList;

    if (cleanQuery.isNotEmpty) {
      final firstChar = cleanQuery[0];
      if (RegExp(r'[a-z]').hasMatch(firstChar)) {
        baseList = await loadLetter(firstChar);
      } else {
        baseList = await loadLetter(letter);
      }
    } else {
      baseList = await loadLetter(letter);
    }

    Iterable<KbbiEntry> filtered = baseList;

    if (category != 'all') {
      filtered = filtered.where((entry) => entry.category == category);
    }

    if (cleanQuery.isEmpty) {
      return filtered.toList();
    }

    final wordBoundary = RegExp(r'\b' + RegExp.escape(cleanQuery) + r'\b');
    final scored = <({KbbiEntry entry, int score})>[];

    for (final entry in filtered) {
      final w = entry.word.toLowerCase();
      final d = entry.definition.toLowerCase();
      int score = 0;

      // 1. Exact match on word
      if (w == cleanQuery) {
        score = 10000;
      }
      // 2. Starts with query
      else if (w.startsWith(cleanQuery)) {
        final diff = w.length - cleanQuery.length;
        score = 5000 - (diff * 20).clamp(0, 2000);
      }
      // 3. Word contains query as distinct word
      else if (wordBoundary.hasMatch(w)) {
        score = 3000;
      }
      // 4. Word contains query substring
      else if (w.contains(cleanQuery)) {
        final diff = w.length - cleanQuery.length;
        score = 2000 - diff.clamp(0, 1000);
      }
      // 5. Definition contains query as distinct word
      else if (wordBoundary.hasMatch(d)) {
        score = 500;
      }
      // 6. Definition contains query substring
      else if (d.contains(cleanQuery)) {
        score = 200;
      }

      if (score > 0) {
        scored.add((entry: entry, score: score));
      }
    }

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      final lenCmp = a.entry.word.length.compareTo(b.entry.word.length);
      if (lenCmp != 0) return lenCmp;
      return a.entry.word.compareTo(b.entry.word);
    });

    return scored.map((e) => e.entry).toList();
  }

  Future<List<BakuNonbakuEntry>> loadBakuEntries() async {
    if (_bakuEntries.isNotEmpty) return _bakuEntries;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/kbbi/baku_nonbaku.json');
      final List<dynamic> rawList = json.decode(jsonStr);
      _bakuEntries = rawList
          .map((item) => BakuNonbakuEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
      return _bakuEntries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading baku_nonbaku: $e');
      }
      return [];
    }
  }

  List<BakuNonbakuEntry> searchBaku(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _bakuEntries;

    final scored = <({BakuNonbakuEntry entry, int score})>[];
    for (final entry in _bakuEntries) {
      final w = entry.word.toLowerCase();
      final wrong = entry.wrong.toLowerCase();
      final exp = entry.explain.toLowerCase();
      int score = 0;

      if (w == q || wrong == q) {
        score = 10000;
      } else if (w.startsWith(q) || wrong.startsWith(q)) {
        score = 5000;
      } else if (w.contains(q) || wrong.contains(q)) {
        score = 2000;
      } else if (exp.contains(q)) {
        score = 500;
      }

      if (score > 0) {
        scored.add((entry: entry, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.entry).toList();
  }

  Future<List<AntonimEntry>> loadAntonimEntries() async {
    if (_antonimEntries.isNotEmpty) return _antonimEntries;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/kbbi/antonim.json');
      final List<dynamic> rawList = json.decode(jsonStr);
      _antonimEntries = rawList
          .map((item) => AntonimEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
      return _antonimEntries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading antonim: $e');
      }
      return [];
    }
  }

  List<AntonimEntry> searchAntonim(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _antonimEntries;

    final scored = <({AntonimEntry entry, int score})>[];
    for (final entry in _antonimEntries) {
      final a = entry.kataA.toLowerCase();
      final b = entry.kataB.toLowerCase();
      final exp = entry.penjelasan.toLowerCase();
      int score = 0;

      if (a == q || b == q) {
        score = 10000;
      } else if (a.startsWith(q) || b.startsWith(q)) {
        score = 5000;
      } else if (a.contains(q) || b.contains(q)) {
        score = 2000;
      } else if (exp.contains(q)) {
        score = 500;
      }

      if (score > 0) {
        scored.add((entry: entry, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.entry).toList();
  }
}
