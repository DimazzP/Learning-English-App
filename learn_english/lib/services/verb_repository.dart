import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grammar_question.dart';
import '../models/tense.dart';
import '../models/verb.dart';

class VerbRepository extends ChangeNotifier {
  static final VerbRepository instance = VerbRepository._internal();
  factory VerbRepository() => instance;

  VerbRepository._internal();

  List<Verb> _allVerbs = [];
  List<Tense> _allTenses = [];
  List<GrammarQuestion> _allGrammarQuestions = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  int _quizHighScore = 0;
  bool _isDarkMode = false;

  List<Verb> get allVerbs => _allVerbs;
  List<Tense> get allTenses => _allTenses;
  List<GrammarQuestion> get allGrammarQuestions => _allGrammarQuestions;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  int get quizHighScore => _quizHighScore;
  bool get isDarkMode => _isDarkMode;

  List<Verb> get irregularVerbs => _allVerbs.where((v) => v.isIrregular).toList();
  List<Verb> get regularVerbs => _allVerbs.where((v) => v.isRegular).toList();
  List<Verb> get favoriteVerbs => _allVerbs.where((v) => _favoriteIds.contains(v.id)).toList();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_verb_ids') ?? [];
      _favoriteIds = favList.toSet();
      _quizHighScore = prefs.getInt('quiz_high_score') ?? 0;
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

      final jsonString = await rootBundle.loadString('assets/data/verbs.json');
      final List<dynamic> list = json.decode(jsonString);
      _allVerbs = list.map((item) => Verb.fromJson(item as Map<String, dynamic>)).toList();

      final tensesJsonString = await rootBundle.loadString('assets/data/tenses.json');
      final List<dynamic> tensesList = json.decode(tensesJsonString);
      _allTenses = tensesList.map((item) => Tense.fromJson(item as Map<String, dynamic>)).toList();

      final manifestStr = await rootBundle.loadString('assets/data/questions/manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestStr);
      final List<dynamic> filesList = manifest['files'] as List<dynamic>? ?? [];
      final List<GrammarQuestion> loadedQuestions = [];

      for (final item in filesList) {
        final filePath = item['file'] as String;
        final contentStr = await rootBundle.loadString(filePath);
        final List<dynamic> qList = json.decode(contentStr);
        loadedQuestions.addAll(
          qList.map((q) => GrammarQuestion.fromJson(q as Map<String, dynamic>)),
        );
      }
      _allGrammarQuestions = loadedQuestions;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading verbs: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_verb_ids', _favoriteIds.toList());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving favorites: $e');
      }
    }
  }

  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving theme: $e');
      }
    }
  }

  Future<void> updateHighScore(int score) async {
    if (score > _quizHighScore) {
      _quizHighScore = score;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('quiz_high_score', _quizHighScore);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error saving high score: $e');
        }
      }
    }
  }

  List<Verb> filter({
    String query = '',
    String typeFilter = 'all', // 'all', 'irregular', 'regular', 'favorites'
    String letterFilter = 'ALL',
    String difficultyFilter = 'all',
    String languageFilter = 'all', // 'all', 'en', 'id'
  }) {
    final cleanQuery = query.trim().toLowerCase();

    final filtered = _allVerbs.where((verb) {
      // Type filter
      if (typeFilter == 'irregular' && !verb.isIrregular) return false;
      if (typeFilter == 'regular' && !verb.isRegular) return false;
      if (typeFilter == 'favorites' && !_favoriteIds.contains(verb.id)) return false;

      // Letter filter
      if (letterFilter != 'ALL') {
        if (verb.firstLetter != letterFilter.toUpperCase()) {
          return false;
        }
      }

      // Difficulty filter
      if (difficultyFilter != 'all') {
        if (verb.difficulty.toLowerCase() != difficultyFilter.toLowerCase()) {
          return false;
        }
      }

      // Search query pre-check
      if (cleanQuery.isNotEmpty) {
        final v1 = verb.v1.toLowerCase();
        final v2 = verb.v2.toLowerCase();
        final v3 = verb.v3.toLowerCase();
        final vIng = verb.vIng.toLowerCase();
        final meaning = verb.meaning.toLowerCase();

        final enMatches = v1.contains(cleanQuery) ||
            v2.contains(cleanQuery) ||
            v3.contains(cleanQuery) ||
            vIng.contains(cleanQuery);
        final idMatches = meaning.contains(cleanQuery);

        if (languageFilter == 'en' && !enMatches) return false;
        if (languageFilter == 'id' && !idMatches) return false;
        if (languageFilter == 'all' && !enMatches && !idMatches) return false;
      }

      return true;
    }).toList();

    if (cleanQuery.isEmpty) {
      return filtered;
    }

    final wordBoundary = RegExp(r'\b' + RegExp.escape(cleanQuery) + r'\b');
    final scored = <({Verb verb, int score})>[];

    for (final verb in filtered) {
      final v1 = verb.v1.toLowerCase();
      final v2 = verb.v2.toLowerCase();
      final v3 = verb.v3.toLowerCase();
      final vIng = verb.vIng.toLowerCase();
      final meaning = verb.meaning.toLowerCase();
      int score = 0;

      // 1. Exact match on V1 (English)
      if (v1 == cleanQuery) {
        score = 10000;
      }
      // 2. Exact match on V2 or V3
      else if (v2 == cleanQuery || v3 == cleanQuery || vIng == cleanQuery) {
        score = 8000;
      }
      // 3. Exact match on Indonesian meaning
      else if (meaning == cleanQuery) {
        score = 7000;
      }
      // 4. Exact word boundary in meaning
      else if (wordBoundary.hasMatch(meaning)) {
        score = 5000;
      }
      // 5. V1 starts with query
      else if (v1.startsWith(cleanQuery)) {
        final diff = v1.length - cleanQuery.length;
        score = 4000 - (diff * 20).clamp(0, 1000);
      }
      // 6. Meaning starts with query
      else if (meaning.startsWith(cleanQuery)) {
        final diff = meaning.length - cleanQuery.length;
        score = 3000 - (diff * 10).clamp(0, 1000);
      }
      // 7. English forms contain query
      else if (v1.contains(cleanQuery) || v2.contains(cleanQuery) || v3.contains(cleanQuery)) {
        score = 2000;
      }
      // 8. Meaning contains query
      else if (meaning.contains(cleanQuery)) {
        score = 1000;
      }

      if (score > 0) {
        scored.add((verb: verb, score: score));
      }
    }

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.verb.v1.compareTo(b.verb.v1);
    });

    return scored.map((e) => e.verb).toList();
  }

  Verb? getRandomVerb() {
    if (_allVerbs.isEmpty) return null;
    final random = Random();
    return _allVerbs[random.nextInt(_allVerbs.length)];
  }

  QuizQuestion generateQuizQuestion({
    String mode = 'v2',
    Set<String>? excludeIds,
  }) {
    final random = Random();
    final sourceList = _allVerbs.isNotEmpty ? _allVerbs : <Verb>[];
    if (sourceList.isEmpty) {
      return QuizQuestion(
        prompt: 'No verbs available',
        questionText: '',
        correctAnswer: '',
        options: [],
        verb: const Verb(
          id: '',
          v1: '',
          v2: '',
          v3: '',
          vIng: '',
          vS: '',
          meaning: '',
          type: 'regular',
          difficulty: 'Basic',
          exampleSentence: '',
          exampleMeaning: '',
          tip: '',
        ),
      );
    }

    // Filter available pool excluding already used verb IDs
    List<Verb> candidateList = sourceList;
    if (excludeIds != null && excludeIds.isNotEmpty) {
      final unspent = sourceList.where((v) => !excludeIds.contains(v.id)).toList();
      if (unspent.isNotEmpty) {
        candidateList = unspent;
      } else {
        excludeIds.removeAll(sourceList.map((v) => v.id));
        candidateList = sourceList;
      }
    }

    // Pick a target verb from candidate pool
    final targetVerb = candidateList[random.nextInt(candidateList.length)];
    String prompt = '';
    String questionText = '';
    String correctAnswer = '';

    if (mode == 'v2') {
      prompt = 'Bentuk Verb 2 (Past Simple) dari:';
      questionText = targetVerb.v1;
      correctAnswer = targetVerb.v2;
    } else if (mode == 'v3') {
      prompt = 'Bentuk Verb 3 (Past Participle) dari:';
      questionText = targetVerb.v1;
      correctAnswer = targetVerb.v3;
    } else if (mode == 'meaning') {
      prompt = 'Arti dalam Bahasa Indonesia dari:';
      questionText = '${targetVerb.v1} (${targetVerb.v2} / ${targetVerb.v3})';
      correctAnswer = targetVerb.meaning;
    } else {
      // Mixed mode
      final subModes = ['v2', 'v3', 'meaning'];
      final chosen = subModes[random.nextInt(subModes.length)];
      return generateQuizQuestion(mode: chosen, excludeIds: excludeIds);
    }

    // Pick 3 distractor answers
    final options = <String>{correctAnswer};
    int attempts = 0;
    while (options.length < 4 && attempts < 50) {
      attempts++;
      final otherVerb = sourceList[random.nextInt(sourceList.length)];
      if (otherVerb.id == targetVerb.id) continue;

      String optionCandidate = '';
      if (mode == 'v2') {
        optionCandidate = otherVerb.v2;
      } else if (mode == 'v3') {
        optionCandidate = otherVerb.v3;
      } else {
        optionCandidate = otherVerb.meaning;
      }

      if (optionCandidate.isNotEmpty && optionCandidate != correctAnswer) {
        options.add(optionCandidate);
      }
    }

    final shuffledOptions = options.toList()..shuffle();

    return QuizQuestion(
      prompt: prompt,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: shuffledOptions,
      verb: targetVerb,
    );
  }

  GrammarQuizQuestion? generateGrammarQuizQuestion({
    String tenseType = 'all',
    String level = 'all',
    Set<String>? excludeIds,
  }) {
    final filtered = _allGrammarQuestions.where((q) {
      if (tenseType != 'all' && q.tenseType.toLowerCase() != tenseType.toLowerCase()) {
        return false;
      }
      if (level != 'all' && q.level.toLowerCase() != level.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    List<GrammarQuestion> pool = filtered;
    if (pool.isEmpty) {
      // Fallback if specific combo is empty
      if (_allGrammarQuestions.isEmpty) return null;
      final fallbackFiltered = _allGrammarQuestions.where((q) {
        if (level != 'all' && q.level.toLowerCase() != level.toLowerCase()) {
          return false;
        }
        return true;
      }).toList();
      pool = fallbackFiltered.isNotEmpty ? fallbackFiltered : _allGrammarQuestions;
    }

    // Apply exclusion to avoid repeating recently seen questions
    List<GrammarQuestion> available = pool;
    if (excludeIds != null && excludeIds.isNotEmpty) {
      final unspent = pool.where((q) => !excludeIds.contains(q.id)).toList();
      if (unspent.isNotEmpty) {
        available = unspent;
      } else {
        excludeIds.removeAll(pool.map((q) => q.id));
        available = pool;
      }
    }

    final random = Random();
    final question = available[random.nextInt(available.length)];
    final shuffledOptions = List<String>.from(question.options)..shuffle();

    return GrammarQuizQuestion(
      question: question,
      shuffledOptions: shuffledOptions,
    );
  }
}

class GrammarQuizQuestion {
  final GrammarQuestion question;
  final List<String> shuffledOptions;

  GrammarQuizQuestion({
    required this.question,
    required this.shuffledOptions,
  });
}

class QuizQuestion {
  final String prompt;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final Verb verb;

  QuizQuestion({
    required this.prompt,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.verb,
  });
}
