import 'package:flutter/material.dart';
import '../../models/to_be_lesson.dart';
import '../../services/tts_service.dart';

class ToBeGuideTab extends StatefulWidget {
  const ToBeGuideTab({super.key});

  @override
  State<ToBeGuideTab> createState() => _ToBeGuideTabState();
}

class _ToBeGuideTabState extends State<ToBeGuideTab> {
  // 'rules' (Pondasi & Aturan), 'matrix' (Matriks Subjek), 'mistakes' (Kesalahan Umum), 'quiz' (Latihan Soal)
  String _activeSection = 'rules';

  // Quiz state
  int _currentQuizIndex = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  int _score = 0;
  final Set<String> _answeredQuestions = {};

  void _resetQuiz() {
    setState(() {
      _currentQuizIndex = 0;
      _selectedAnswer = null;
      _hasAnswered = false;
      _score = 0;
      _answeredQuestions.clear();
    });
  }

  void _handleAnswerSelect(String option, ToBeQuizQuestion q) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswer = option;
      _hasAnswered = true;
      if (option == q.correctAnswer) {
        _score++;
      }
      _answeredQuestions.add(q.id);
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuizIndex < totalQuestions - 1) {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              _buildHeader(isDark),
              const SizedBox(height: 16),

              // Filter Segment Bar
              _buildSegmentBar(isDark),
              const SizedBox(height: 20),

              // Dynamic Body based on active section
              if (_activeSection == 'rules') _buildRulesSection(isDark),
              if (_activeSection == 'matrix') _buildMatrixSection(isDark),
              if (_activeSection == 'mistakes') _buildMistakesSection(isDark),
              if (_activeSection == 'quiz') _buildQuizSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.psychology_rounded, color: Colors.purple, size: 28),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Belajar To Be (Am, Is, Are, Was, Were, Been, Being)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'Pahami konsep kalimat nominal, pasangan subjek, dan hindari kesalahan fatal seperti "I am agree".',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentBar(bool isDark) {
    final segments = [
      (id: 'rules', label: 'Pondasi & Rumus', icon: Icons.rule_rounded),
      (id: 'matrix', label: 'Matriks Subjek', icon: Icons.grid_view_rounded),
      (id: 'mistakes', label: 'Kesalahan Umum', icon: Icons.warning_amber_rounded),
      (id: 'quiz', label: 'Latihan Soal', icon: Icons.quiz_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: segments.map((seg) {
          final isSelected = _activeSection == seg.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                seg.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
              label: Text(
                seg.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : null,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.purple,
              checkmarkColor: Colors.white,
              onSelected: (_) => setState(() => _activeSection = seg.id),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== SECTION 1: RULES & FOUNDATIONS ====================
  Widget _buildRulesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Golden Rule Highlight Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF4338CA) : const Color(0xFFD8B4FE),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Aturan Emas: Nominal vs Verbal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Kalimat Nominal: Wajib pakai To Be jika predikatnya BUKAN kata kerja aksi, melainkan ANA (Adjective/Kata Sifat, Noun/Kata Benda, Adverb/Keterangan Tempat).\n'
                '2. Kalimat Verbal: JANGAN pakai to be (is/am/are) sebelum kata kerja bentuk pertama! (Contoh: "I agree", BUKAN "I am agree").',
                style: TextStyle(fontSize: 13.5, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rules Cards
        ...ToBeData.coreRules.map((rule) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rule.description,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),

                  // Formula Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      rule.formula,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rule.explanation,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Contoh Kalimat:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ...rule.examples.map((ex) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 20, color: Colors.purple),
                            tooltip: 'Dengar pelafalan audio',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => TtsService.instance.speak(ex.english),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.english,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ex.indonesian,
                                  style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '💡 ${ex.note}',
                                  style: const TextStyle(fontSize: 11.5, color: Colors.purple),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==================== SECTION 2: SUBJECT MATRIX ====================
  Widget _buildMatrixSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Pasangan To Be Berdasarkan Subjek & Waktu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gunakan tabel terstruktur di bawah ini untuk melihat to be yang tepat untuk masa sekarang (Present), lampau (Past), dan masa selesai (Perfect).',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 14),

        ...ToBeData.subjectMatrix.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${item.subjectIndo})',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3 Badge Forms (Present, Past, Perfect)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTenseBadge('Present:', item.present, Colors.blue),
                      _buildTenseBadge('Past:', item.past, Colors.amber.shade800),
                      _buildTenseBadge('Perfect:', item.perfect, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Example Sentence with Speaker
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18, color: Colors.purple),
                        tooltip: 'Dengar contoh audio',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => TtsService.instance.speak(item.exampleEn),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.exampleEn,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              item.exampleId,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTenseBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 3: COMMON MISTAKES ====================
  Widget _buildMistakesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Kesalahan Umum (Common Mistakes)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bandingkan kalimat yang salah dengan kalimat yang benar agar tidak mengulangi kebiasaan salah saat berbicara atau menulis.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 14),

        ...ToBeData.commonMistakes.map((mistake) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrong Sentence
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mistake.wrong,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Correct Sentence
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mistake.correct,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 18, color: Colors.green),
                          tooltip: 'Dengar kalimat benar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => TtsService.instance.speak(mistake.correct),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Why Wrong Explanation
                  Text(
                    'Mengapa salah? ${mistake.whyWrong}',
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 4),

                  // Tip
                  Text(
                    '💡 Tips: ${mistake.tip}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==================== SECTION 4: PRACTICE QUIZ ====================
  Widget _buildQuizSection(bool isDark) {
    final questions = ToBeData.practiceQuestions;
    final total = questions.length;
    final isFinished = _currentQuizIndex >= total;

    if (isFinished) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Latihan Selesai!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Skor Anda: $_score dari $total soal benar',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Ulangi Latihan'),
                onPressed: _resetQuiz,
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[_currentQuizIndex];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${_currentQuizIndex + 1} dari $total',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 14),
                ),
                Text(
                  'Skor: $_score',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuizIndex + 1) / total,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              color: Colors.purple,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 20),

            // Question Text
            Text(
              q.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              q.translation,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            const SizedBox(height: 20),

            // 4 Options
            ...q.options.map((option) {
              final isCorrect = option == q.correctAnswer;
              final isSelected = _selectedAnswer == option;

              Color? btnBgColor;
              Color? btnTextColor;
              BorderSide borderSide = BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              );

              if (_hasAnswered) {
                if (isCorrect) {
                  btnBgColor = Colors.green.withValues(alpha: 0.15);
                  btnTextColor = Colors.green;
                  borderSide = const BorderSide(color: Colors.green, width: 1.5);
                } else if (isSelected) {
                  btnBgColor = Colors.red.withValues(alpha: 0.15);
                  btnTextColor = Colors.red;
                  borderSide = const BorderSide(color: Colors.red, width: 1.5);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: btnBgColor,
                      foregroundColor: btnTextColor,
                      side: borderSide,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => _handleAnswerSelect(option, q),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (_hasAnswered && isCorrect)
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        if (_hasAnswered && isSelected && !isCorrect)
                          const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Explanation & Next Button after answering
            if (_hasAnswered) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.purple, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Penjelasan:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.explanation,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(_currentQuizIndex < total - 1 ? 'Soal Berikutnya' : 'Lihat Hasil'),
                  onPressed: () => _nextQuestion(total),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
