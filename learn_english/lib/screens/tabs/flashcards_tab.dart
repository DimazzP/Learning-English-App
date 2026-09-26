import 'package:flutter/material.dart';
import '../../models/verb.dart';
import '../../services/tts_service.dart';
import '../../services/verb_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/verb_badge.dart';

class FlashcardsTab extends StatefulWidget {
  const FlashcardsTab({super.key});

  @override
  State<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _category = 'irregular'; // 'irregular', 'regular', 'all', 'favorites'

  List<Verb> _getVerbs(VerbRepository repo) {
    if (_category == 'irregular') return repo.irregularVerbs;
    if (_category == 'regular') return repo.regularVerbs;
    if (_category == 'favorites') return repo.favoriteVerbs;
    return repo.allVerbs;
  }

  void _nextCard(int total) {
    if (total == 0) return;
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  void _prevCard(int total) {
    if (total == 0) return;
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex - 1 + total) % total;
    });
  }

  void _shuffleCards(int total) {
    if (total == 0) return;
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex + 7) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        if (repo.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final verbs = _getVerbs(repo);
        final total = verbs.length;

        if (_currentIndex >= total && total > 0) {
          _currentIndex = 0;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Category selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Irregular'),
                          selected: _category == 'irregular',
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _category = 'irregular';
                                _currentIndex = 0;
                                _isFlipped = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Regular'),
                          selected: _category == 'regular',
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _category = 'regular';
                                _currentIndex = 0;
                                _isFlipped = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: _category == 'all',
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _category = 'all';
                                _currentIndex = 0;
                                _isFlipped = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Favorit (${repo.favoriteVerbs.length})'),
                          selected: _category == 'favorites',
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _category = 'favorites';
                                _currentIndex = 0;
                                _isFlipped = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (total == 0)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada kata kerja di kategori ini',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tandai kata kerja favorit Anda dengan ikon hati di kamus.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kartu ${_currentIndex + 1} dari $total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Acak kartu',
                              icon: const Icon(Icons.shuffle_rounded, size: 20),
                              onPressed: () => _shuffleCards(total),
                            ),
                            IconButton(
                              tooltip: repo.isFavorite(verbs[_currentIndex].id)
                                  ? 'Hapus dari favorit'
                                  : 'Simpan ke favorit',
                              icon: Icon(
                                repo.isFavorite(verbs[_currentIndex].id)
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                                color: repo.isFavorite(verbs[_currentIndex].id)
                                    ? Colors.redAccent
                                    : null,
                              ),
                              onPressed: () => repo.toggleFavorite(verbs[_currentIndex].id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Linear progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / total,
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Flashcard Box
                    GestureDetector(
                      onTap: () => setState(() => _isFlipped = !_isFlipped),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 340),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isFlipped
                                ? AppTheme.primary.withValues(alpha: 0.5)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _isFlipped
                            ? _buildCardBack(verbs[_currentIndex], isDark)
                            : _buildCardFront(verbs[_currentIndex], isDark),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Control buttons: Previous, Flip, Next
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _prevCard(total),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Sebelumnya'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => setState(() => _isFlipped = !_isFlipped),
                          icon: Icon(_isFlipped ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                          label: Text(_isFlipped ? 'Tutup Jawaban' : 'Buka Jawaban'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _nextCard(total),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Berikutnya'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(Verb verb, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: verb.isIrregular
                    ? Colors.orange.withValues(alpha: 0.15)
                    : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                verb.isIrregular ? 'Irregular Verb' : 'Regular Verb',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: verb.isIrregular ? Colors.deepOrange : Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Dengarkan V1',
              icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary),
              onPressed: () => TtsService.instance.speak(verb.v1),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          verb.v1,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Arti: ${verb.meaning}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_rounded, size: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Ketuk kartu untuk melihat V2 & V3',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack(Verb verb, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              verb.v1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              tooltip: 'Dengarkan V1, V2, V3',
              icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary),
              onPressed: () => TtsService.instance.speak('${verb.v1}, ${verb.v2}, ${verb.v3}'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Arti: ${verb.meaning}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        const Divider(height: 24),

        // Forms V1, V2, V3
        Row(
          children: [
            Expanded(
              child: VerbBadge(
                label: 'V1',
                value: verb.v1,
                color: AppTheme.v1Color,
                onSpeak: () => TtsService.instance.speak(verb.v1),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: VerbBadge(
                label: 'V2',
                value: verb.v2,
                color: AppTheme.v2Color,
                onSpeak: () => TtsService.instance.speak(verb.v2),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: VerbBadge(
                label: 'V3',
                value: verb.v3,
                color: AppTheme.v3Color,
                onSpeak: () => TtsService.instance.speak(verb.v3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Example sentence
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Contoh Kalimat:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.volume_up_rounded, size: 16, color: AppTheme.primary),
                    onPressed: () => TtsService.instance.speak(verb.exampleSentence),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '"${verb.exampleSentence}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text(
                verb.exampleMeaning,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (verb.tip.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '💡 Pola: ${verb.tip}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ],
    );
  }
}
