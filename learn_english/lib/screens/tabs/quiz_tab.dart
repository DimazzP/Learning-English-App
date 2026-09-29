import 'package:flutter/material.dart';
import '../../models/grammar_question.dart';
import '../../services/translation_checker.dart';
import '../../services/tts_service.dart';
import '../../services/verb_repository.dart';
import '../../theme/app_theme.dart';

class QuizTab extends StatefulWidget {
  const QuizTab({super.key});

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  // Category: 'grammarly' (Grammar 16 Tenses) vs 'verbs' (Kata Kerja V1, V2, V3)
  String _quizCategory = 'grammarly';

  // For Grammarly:
  // Sub-mode: 'translate' (Terjemahkan Indonesia ➔ Inggris) vs 'choice' (Pilihan Ganda)
  String _grammarlyMode = 'translate';

  // Level filter: 'all', 'beginner', 'intermediate', 'expert'
  // Default to 'beginner' for friendly learning curve!
  String _levelFilter = 'beginner';

  // Tense types: 'all', 'present', 'past', 'future', 'past_future'
  String _tenseTypeFilter = 'all';
  GrammarQuizQuestion? _currentGrammarQuestion;
  final TextEditingController _translationController = TextEditingController();
  TranslationAnalysis? _translationAnalysis;

  // Track skipped question IDs for the current session (shuffle button)
  final Set<String> _sessionSkippedGrammarIds = <String>{};
  final Set<String> _sessionSkippedVerbIds = <String>{};

  // For Verb mode:
  String _verbMode = 'v2';
  QuizQuestion? _currentVerbQuestion;

  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextQuestion();
    });
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    final repo = VerbRepository.instance;

    setState(() {
      _selectedOption = null;
      _isAnswered = false;
      _translationAnalysis = null;
      _translationController.clear();

      if (_quizCategory == 'grammarly') {
        if (repo.allGrammarQuestions.isNotEmpty) {
          final combinedExclusions = <String>{
            ...repo.answeredGrammarQuestionIds,
            ..._sessionSkippedGrammarIds,
          };

          var q = repo.generateGrammarQuizQuestion(
            tenseType: _tenseTypeFilter,
            level: _levelFilter,
            excludeIds: combinedExclusions,
          );

          if (q == null && _sessionSkippedGrammarIds.isNotEmpty) {
            _sessionSkippedGrammarIds.clear();
            q = repo.generateGrammarQuizQuestion(
              tenseType: _tenseTypeFilter,
              level: _levelFilter,
              excludeIds: repo.answeredGrammarQuestionIds,
            );
          }

          _currentGrammarQuestion = q;
        }
      } else {
        if (repo.allVerbs.isNotEmpty) {
          final answeredIds = repo.getAnsweredVerbIds(_verbMode);
          final combinedExclusions = <String>{
            ...answeredIds,
            ..._sessionSkippedVerbIds,
          };

          if (repo.isVerbPoolExhausted(_verbMode)) {
            _currentVerbQuestion = null;
          } else {
            var q = repo.generateQuizQuestion(
              mode: _verbMode,
              excludeIds: combinedExclusions,
            );

            if (answeredIds.contains(q.verb.id) && _sessionSkippedVerbIds.isNotEmpty) {
              _sessionSkippedVerbIds.clear();
              q = repo.generateQuizQuestion(
                mode: _verbMode,
                excludeIds: answeredIds,
              );
            }
            _currentVerbQuestion = q;
          }
        }
      }
    });
  }

  void _skipCurrentQuestion() {
    if (_quizCategory == 'grammarly' && _currentGrammarQuestion != null && !_isAnswered) {
      _sessionSkippedGrammarIds.add(_currentGrammarQuestion!.question.id);
    } else if (_quizCategory == 'verbs' && _currentVerbQuestion != null && !_isAnswered) {
      _sessionSkippedVerbIds.add(_currentVerbQuestion!.verb.id);
    }
    _loadNextQuestion();
  }

  void _selectChoiceAnswer(String option) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    final repo = VerbRepository.instance;
    if (_quizCategory == 'grammarly' && _currentGrammarQuestion != null) {
      repo.markGrammarQuestionAnswered(_currentGrammarQuestion!.question.id);
    } else if (_quizCategory == 'verbs' && _currentVerbQuestion != null) {
      repo.markVerbAnswered(mode: _verbMode, verbId: _currentVerbQuestion!.verb.id);
    }
  }

  void _checkTranslationAnswer() {
    if (_currentGrammarQuestion == null || _isAnswered) return;

    final q = _currentGrammarQuestion!.question;
    final userText = _translationController.text;

    if (userText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ketik terjemahan bahasa Inggris terlebih dahulu.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final analysis = TranslationChecker.analyze(
      userInput: userText,
      targetSentence: q.targetSentence,
      acceptedAnswers: q.acceptedAnswers,
      tenseName: q.tenseName,
    );

    setState(() {
      _translationAnalysis = analysis;
      _isAnswered = true;
    });

    final repo = VerbRepository.instance;
    repo.markGrammarQuestionAnswered(q.id);
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'expert':
        return Colors.red;
      default:
        return AppTheme.primary;
    }
  }

  String _formatLevelLabel(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Beginner (Dasar)';
      case 'intermediate':
        return 'Intermediate (Menengah)';
      case 'expert':
        return 'Expert (Lanjut)';
      default:
        return 'Semua Level';
    }
  }

  Color _getTenseTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'present':
        return Colors.blue;
      case 'past':
        return Colors.amber.shade800;
      case 'future':
        return Colors.teal;
      case 'past_future':
        return Colors.purple;
      default:
        return AppTheme.primary;
    }
  }

  String _formatTenseTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'past':
        return 'Past';
      case 'future':
        return 'Future';
      case 'past_future':
        return 'Past Future';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (repo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Main Category Switcher (Grammarly vs Kamus Verb)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_quizCategory != 'grammarly') {
                            setState(() {
                              _quizCategory = 'grammarly';
                              _loadNextQuestion();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quizCategory == 'grammarly'
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _quizCategory == 'grammarly'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 16,
                                color: _quizCategory == 'grammarly' ? AppTheme.primary : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Grammarly (${repo.allGrammarQuestions.length} Soal)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _quizCategory == 'grammarly'
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_quizCategory != 'verbs') {
                            setState(() {
                              _quizCategory = 'verbs';
                              _loadNextQuestion();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _quizCategory == 'verbs'
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _quizCategory == 'verbs'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 16,
                                color: _quizCategory == 'verbs' ? AppTheme.primary : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kamus Verb (V1, V2, V3)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _quizCategory == 'verbs'
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Sub-mode Selector for Grammarly (Terjemahkan Kalimat vs Pilihan Ganda)
              if (_quizCategory == 'grammarly') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Terjemahkan Indonesia ➔ Inggris'),
                        ],
                      ),
                      selected: _grammarlyMode == 'translate',
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _grammarlyMode = 'translate';
                            _loadNextQuestion();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radio_button_checked_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Pilihan Ganda'),
                        ],
                      ),
                      selected: _grammarlyMode == 'choice',
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _grammarlyMode = 'choice';
                            _loadNextQuestion();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Level Filter Selector: Beginner, Intermediate, Expert
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Tingkat Kesulitan:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildLevelFilterChip('beginner', 'Beginner', Colors.green),
                              const SizedBox(width: 6),
                              _buildLevelFilterChip('intermediate', 'Intermediate', Colors.orange),
                              const SizedBox(width: 6),
                              _buildLevelFilterChip('expert', 'Expert', Colors.red),
                              const SizedBox(width: 6),
                              _buildLevelFilterChip('all', 'Semua Level', Colors.blue),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Filter by Tense Type (4 types: Present, Past, Future, Past Future)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Semua Tenses'),
                        selected: _tenseTypeFilter == 'all',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _tenseTypeFilter = 'all';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Present'),
                        selected: _tenseTypeFilter == 'present',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _tenseTypeFilter = 'present';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Past'),
                        selected: _tenseTypeFilter == 'past',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _tenseTypeFilter = 'past';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Future'),
                        selected: _tenseTypeFilter == 'future',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _tenseTypeFilter = 'future';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Past Future'),
                        selected: _tenseTypeFilter == 'past_future',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _tenseTypeFilter = 'past_future';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Sub-modes for Verb Quiz
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Tebak V2'),
                        selected: _verbMode == 'v2',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _verbMode = 'v2';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Tebak V3'),
                        selected: _verbMode == 'v3',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _verbMode = 'v3';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Tebak Arti'),
                        selected: _verbMode == 'meaning',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _verbMode = 'meaning';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Campuran'),
                        selected: _verbMode == 'mixed',
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _verbMode = 'mixed';
                            });
                            _loadNextQuestion();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // 4.5. PROGRESS BAR & RESET ACTION
              _buildProgressBar(context, repo, isDark),

              // 5. MAIN QUESTION AREA
              if (_quizCategory == 'grammarly') ...[
                if (_currentGrammarQuestion != null) ...[
                  if (_grammarlyMode == 'translate') ...[
                    // MODE A: Indonesian -> English Text Translation & Error Checking
                    _buildTranslationExercise(
                      context,
                      _currentGrammarQuestion!.question,
                      isDark,
                    ),
                  ] else ...[
                    // MODE B: Multiple Choice Grammarly
                    _buildGrammarChoiceExercise(
                      context,
                      _currentGrammarQuestion!.question,
                      _currentGrammarQuestion!.shuffledOptions,
                      isDark,
                    ),
                  ],
                ] else ...[
                  _buildGrammarCompletionCard(context, isDark, repo),
                ],
              ] else if (_quizCategory == 'verbs') ...[
                if (_currentVerbQuestion != null) ...[
                  // MODE C: Verb Multiple Choice
                  _buildVerbChoiceExercise(
                    context,
                    _currentVerbQuestion!,
                    isDark,
                  ),
                ] else ...[
                  _buildVerbCompletionCard(context, isDark, repo),
                ],
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelFilterChip(String levelKey, String label, Color color) {
    final isSelected = _levelFilter == levelKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _levelFilter = levelKey;
            _loadNextQuestion();
          });
        }
      },
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? color : null,
      ),
    );
  }

  // WIDGET: Indonesian -> English Translation Input
  // IMPORTANT: DO NOT show tense name in question! Only show it AFTER answering!
  Widget _buildTranslationExercise(
    BuildContext context,
    GrammarQuestion q,
    bool isDark,
  ) {
    final levelColor = _getLevelColor(q.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Box (Indonesian sentence)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shows ONLY Level badge and Shuffle button (NO TENSE NAME)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _formatLevelLabel(q.level),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Muat soal lain',
                    icon: const Icon(Icons.shuffle_rounded, size: 20),
                    onPressed: _skipCurrentQuestion,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Terjemahkan kalimat berikut ke dalam Bahasa Inggris:',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '"${q.indonesianPrompt}"',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Text input field
              TextField(
                controller: _translationController,
                enabled: !_isAnswered,
                maxLines: 2,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isAnswered) _checkTranslationAnswer();
                },
                decoration: InputDecoration(
                  hintText: 'Ketik terjemahan bahasa Inggris Anda di sini...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  suffixIcon: _translationController.text.isNotEmpty && !_isAnswered
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _translationController.clear()),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              // Submit check button
              if (!_isAnswered)
                FilledButton.icon(
                  onPressed: _checkTranslationAnswer,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Periksa Jawaban'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),

        // Result & Deep Correction Box (Tense Name is REVEALED HERE!)
        if (_isAnswered && _translationAnalysis != null) ...[
          const SizedBox(height: 16),
          _buildCorrectionDetailsCard(_translationAnalysis!, q, isDark),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _loadNextQuestion,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Soal Berikutnya (Acak)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  // WIDGET: Detailed Correction Display
  // Reveals the Tense Name, word by word corrections, and grammar rules
  Widget _buildCorrectionDetailsCard(
    TranslationAnalysis analysis,
    GrammarQuestion q,
    bool isDark,
  ) {
    final isCorrect = analysis.isCorrect;
    final tenseColor = _getTenseTypeColor(q.tenseType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status + Audio button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Penulisan Benar!' : 'Ada Kesalahan Penulisan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dengarkan kalimat bahasa Inggris yang benar',
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 22),
                onPressed: () => TtsService.instance.speak(q.targetSentence),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TENSE REVEAL BADGE: Shows the exact tense used!
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tenseColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tenseColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, size: 16, color: tenseColor),
                const SizedBox(width: 8),
                Text(
                  'Tense yang Digunakan: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${q.tenseName} (${_formatTenseTypeLabel(q.tenseType)})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tenseColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Visual word breakdown if wrong
          if (!isCorrect && analysis.comparisons.isNotEmpty) ...[
            const Text(
              'Pemeriksaan Kata per Kata (Tulisan Anda):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: analysis.comparisons.map((c) {
                if (c.isMissing) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange, style: BorderStyle.solid),
                    ),
                    child: Text(
                      '+ kurang "${c.targetWord}"',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                  );
                } else if (c.isExtra) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      c.userWord,
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (c.isMatch) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      c.userWord,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.greenAccent : Colors.green.shade800,
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c.userWord,
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '➔ ${c.targetWord}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.greenAccent : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Correct sentence
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kalimat yang Benar:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.volume_up_rounded, size: 16, color: AppTheme.primary),
                      onPressed: () => TtsService.instance.speak(q.targetSentence),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${q.targetSentence}"',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.greenAccent : Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Specific bullet points of corrections
          if (analysis.specificCorrections.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.build_circle_rounded, size: 15, color: Colors.amber),
                      SizedBox(width: 6),
                      Text(
                        'Rincian Koreksi:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...analysis.specificCorrections.map((corr) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              corr,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Grammar rule explanation
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aturan Tata Bahasa (${q.tenseName}):',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        q.explanation,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Grammarly Multiple Choice Exercise (Hides Tense Name before answering)
  Widget _buildGrammarChoiceExercise(
    BuildContext context,
    GrammarQuestion q,
    List<String> options,
    bool isDark,
  ) {
    final levelColor = _getLevelColor(q.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shows ONLY Level badge (NO TENSE NAME BEFORE ANSWERING)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _formatLevelLabel(q.level),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: levelColor),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Muat soal lain',
                        icon: const Icon(Icons.shuffle_rounded, color: AppTheme.primary, size: 20),
                        onPressed: _isAnswered ? null : _skipCurrentQuestion,
                      ),
                      IconButton(
                        tooltip: 'Dengarkan kalimat soal',
                        icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                        onPressed: () => TtsService.instance.speak(q.question.replaceAll('_______', 'blank')),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                q.question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Arti: "${q.translation}"',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Options
        ...options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildChoiceOptionButton(
              option: opt,
              correctAnswer: q.correctAnswer,
              isDark: isDark,
            ),
          );
        }),

        // Feedback reveals the Tense name!
        if (_isAnswered) ...[
          const SizedBox(height: 10),
          _buildGrammarChoiceFeedbackBox(q, isDark),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _loadNextQuestion,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Soal Berikutnya (Acak)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  // WIDGET: Verb Multiple Choice Exercise
  Widget _buildVerbChoiceExercise(
    BuildContext context,
    QuizQuestion q,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Text(
                q.prompt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      q.questionText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Muat soal lain',
                    icon: const Icon(Icons.shuffle_rounded, color: AppTheme.primary, size: 20),
                    onPressed: _isAnswered ? null : _skipCurrentQuestion,
                  ),
                  IconButton(
                    tooltip: 'Dengarkan',
                    icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                    onPressed: () => TtsService.instance.speak(q.verb.v1),
                  ),
                ],
              ),
              if (_verbMode != 'meaning') ...[
                const SizedBox(height: 6),
                Text(
                  'Arti: ${q.verb.meaning}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...q.options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildChoiceOptionButton(
              option: opt,
              correctAnswer: q.correctAnswer,
              isDark: isDark,
            ),
          );
        }),

        if (_isAnswered) ...[
          const SizedBox(height: 10),
          _buildVerbChoiceFeedbackBox(q, isDark),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _loadNextQuestion,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Soal Berikutnya (Acak)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceOptionButton({
    required String option,
    required String correctAnswer,
    required bool isDark,
  }) {
    Color? borderColor;
    Color? bgColor;
    Color? textColor;

    final isCorrect = option.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    final isSelected = _selectedOption == option;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: isDark ? 0.25 : 0.12);
        textColor = isDark ? Colors.greenAccent : Colors.green.shade800;
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: isDark ? 0.25 : 0.12);
        textColor = isDark ? Colors.redAccent : Colors.red.shade800;
      }
    }

    return InkWell(
      onTap: _isAnswered ? null : () => _selectChoiceAnswer(option),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected || (_isAnswered && isCorrect) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
            if (_isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
            else if (_isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarChoiceFeedbackBox(GrammarQuestion q, bool isDark) {
    final isCorrect = _selectedOption?.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
    final fullSentence = q.targetSentence;
    final tenseColor = _getTenseTypeColor(q.tenseType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Jawaban Benar!' : 'Jawaban Salah!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dengarkan kalimat lengkap',
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                onPressed: () => TtsService.instance.speak(fullSentence),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // TENSE REVEALED
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tenseColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tenseColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, size: 16, color: tenseColor),
                const SizedBox(width: 8),
                Text(
                  'Tense yang Digunakan: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${q.tenseName} (${_formatTenseTypeLabel(q.tenseType)})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tenseColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Text(
            '"$fullSentence"',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4),
          Text(
            'Arti: ${q.translation}',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.explanation,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerbChoiceFeedbackBox(QuizQuestion q, bool isDark) {
    final isCorrect = _selectedOption?.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
    final verb = q.verb;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Jawaban Benar!' : 'Jawaban Salah!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Lengkap: ${verb.v1} (V1) ➔ ${verb.v2} (V2) ➔ ${verb.v3} (V3)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                tooltip: 'Dengarkan pengucapan kata kerja',
                onPressed: () => TtsService.instance.speak('${verb.v1}, ${verb.v2}, ${verb.v3}'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Arti: ${verb.meaning}',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
          if (verb.tip.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '💡 ${verb.tip}',
              style: TextStyle(fontSize: 11, color: Colors.amber.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, VerbRepository repo, bool isDark) {
    if (_quizCategory == 'grammarly') {
      final total = repo.getTotalGrammarCount(tenseType: _tenseTypeFilter, level: _levelFilter);
      final answered = repo.getAnsweredGrammarCount(tenseType: _tenseTypeFilter, level: _levelFilter);
      final percent = total > 0 ? (answered / total).clamp(0.0, 1.0) : 0.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 16,
                      color: answered == total && total > 0 ? Colors.green : AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Progres Selesai: $answered / $total Soal (${(percent * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                if (answered > 0)
                  InkWell(
                    onTap: () => _confirmResetGrammarProgress(context, repo),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  answered == total && total > 0 ? Colors.green : AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final total = repo.getTotalVerbCount();
      final answered = repo.getAnsweredVerbCount(_verbMode);
      final percent = total > 0 ? (answered / total).clamp(0.0, 1.0) : 0.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 16,
                      color: answered == total && total > 0 ? Colors.green : AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Progres Kata Kerja (${_verbMode.toUpperCase()}): $answered / $total (${(percent * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                if (answered > 0)
                  InkWell(
                    onTap: () => _confirmResetVerbProgress(context, repo),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  answered == total && total > 0 ? Colors.green : AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildGrammarCompletionCard(BuildContext context, bool isDark, VerbRepository repo) {
    final total = repo.getTotalGrammarCount(tenseType: _tenseTypeFilter, level: _levelFilter);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Luar Biasa! Kategori Telah Selesai',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda telah berhasil menjawab seluruh $total soal pada filter ${_formatLevelLabel(_levelFilter)} - ${_formatTenseTypeLabel(_tenseTypeFilter)}. Soal yang sama tidak akan diulang agar Anda dapat fokus ke materi lainnya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await repo.resetGrammarProgress(tenseType: _tenseTypeFilter, level: _levelFilter);
              _loadNextQuestion();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Ulangi Latihan Kategori Ini (Reset)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerbCompletionCard(BuildContext context, bool isDark, VerbRepository repo) {
    final total = repo.getTotalVerbCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Luar Biasa! Semua Verb Telah Selesai',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda telah menyelesaikan latihan untuk seluruh $total kata kerja pada mode ${_verbMode.toUpperCase()}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await repo.resetVerbProgress(_verbMode);
              _loadNextQuestion();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Ulangi Latihan Verb (${_verbMode.toUpperCase()})'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetGrammarProgress(BuildContext context, VerbRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progres Kuis?'),
        content: Text(
          'Apakah Anda ingin mengulang progres untuk kategori ${_formatLevelLabel(_levelFilter)} - ${_formatTenseTypeLabel(_tenseTypeFilter)}? Soal yang telah diselesaikan akan dapat muncul kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.resetGrammarProgress(tenseType: _tenseTypeFilter, level: _levelFilter);
              _loadNextQuestion();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmResetVerbProgress(BuildContext context, VerbRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progres Verb?'),
        content: Text(
          'Apakah Anda ingin mengulang progres untuk mode ${_verbMode.toUpperCase()}? Kata kerja yang telah dijawab akan dapat muncul kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.resetVerbProgress(_verbMode);
              _loadNextQuestion();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
