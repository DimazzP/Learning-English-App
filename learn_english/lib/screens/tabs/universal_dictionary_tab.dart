import 'package:flutter/material.dart';
import '../../models/kbbi_entry.dart';
import '../../models/translation_entry.dart';
import '../../services/kbbi_repository.dart';
import '../../services/translation_repository.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kbbi_detail_sheet.dart';
import '../../widgets/translation_detail_sheet.dart';

class UniversalDictionaryTab extends StatefulWidget {
  const UniversalDictionaryTab({super.key});

  @override
  State<UniversalDictionaryTab> createState() => _UniversalDictionaryTabState();
}

class _UniversalDictionaryTabState extends State<UniversalDictionaryTab> {
  final TextEditingController _searchController = TextEditingController();

  // Active sub-mode: 'terjemahan', 'kamus', 'baku', 'antonim'
  String _activeMode = 'terjemahan';

  // Translation settings
  TranslationDirection _translationDirection = TranslationDirection.idToEn;
  List<TranslationEntry> _currentTranslations = [];

  // Kamus KBBI filters
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'Nomina',
    'Verba',
    'Adjektiva',
    'Adverbia',
    'Partikel',
    'Numeralia',
    'Pronomina',
    'Lainnya',
  ];

  List<KbbiEntry> _currentEntries = [];
  bool _isLoadingEntries = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoadingEntries = true);

    if (_activeMode == 'terjemahan') {
      final transRepo = TranslationRepository.instance;
      final results = await transRepo.search(
        query: _searchController.text,
        direction: _translationDirection,
      );
      if (mounted) {
        setState(() {
          _currentTranslations = results;
          _isLoadingEntries = false;
        });
      }
    } else if (_activeMode == 'kamus') {
      final repo = KbbiRepository.instance;
      final results = await repo.getEntries(
        query: _searchController.text,
        category: _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _currentEntries = results;
          _isLoadingEntries = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingEntries = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_activeMode == 'terjemahan' || _activeMode == 'kamus') {
      _loadEntries();
    } else {
      setState(() {});
    }
  }

  void _toggleTranslationDirection() {
    setState(() {
      _translationDirection = _translationDirection == TranslationDirection.idToEn
          ? TranslationDirection.enToId
          : TranslationDirection.idToEn;
    });
    _loadEntries();
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Nomina':
        return Colors.blue;
      case 'Verba':
        return Colors.orange;
      case 'Adjektiva':
        return Colors.green;
      case 'Adverbia':
        return Colors.purple;
      case 'Partikel':
        return Colors.amber.shade800;
      case 'Numeralia':
        return Colors.teal;
      case 'Pronomina':
        return Colors.indigo;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = KbbiRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;

            return Column(
              children: [
                // Top control bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Sub-navigation segmented buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildModeButton(
                              id: 'terjemahan',
                              label: 'Terjemahan En ⇄ Id (54.073)',
                              icon: Icons.translate_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildModeButton(
                              id: 'kamus',
                              label: 'Kamus KBBI (115.978)',
                              icon: Icons.menu_book_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildModeButton(
                              id: 'baku',
                              label: 'Baku vs Nonbaku (2.847)',
                              icon: Icons.spellcheck_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildModeButton(
                              id: 'antonim',
                              label: 'Lawan Kata (549)',
                              icon: Icons.swap_horiz_rounded,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Translation direction filter bar (Only in 'terjemahan' mode)
                      if (_activeMode == 'terjemahan') ...[
                        _buildTranslationDirectionFilter(isDark),
                        const SizedBox(height: 10),
                      ],

                      // Search input
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: _getSearchHint(),
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                        ),
                      ),

                      // Category selector for Kamus KBBI mode
                      if (_activeMode == 'kamus') ...[
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              final label = cat == 'all' ? 'Semua Kelas' : cat;

                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(label, style: const TextStyle(fontSize: 11)),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() => _selectedCategory = cat);
                                    _loadEntries();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Main Content View
                Expanded(
                  child: _activeMode == 'terjemahan'
                      ? _buildTranslationView(isDark, isWide)
                      : (_activeMode == 'kamus'
                          ? _buildKamusView(isDark, isWide)
                          : (_activeMode == 'baku'
                              ? _buildBakuView(repo, isDark, isWide)
                              : _buildAntonimView(repo, isDark, isWide))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getSearchHint() {
    if (_activeMode == 'terjemahan') {
      return _translationDirection == TranslationDirection.idToEn
          ? 'Cari kata Indonesia (contoh: nikah, makan, cinta)...'
          : 'Cari kata Bahasa Inggris (contoh: marry, eat, love)...';
    } else if (_activeMode == 'kamus') {
      return 'Cari kata di KBBI (contoh: nikah, bahagia, ilmu)...';
    } else if (_activeMode == 'baku') {
      return 'Cari kata baku atau tidak baku (contoh: apotek, izin)...';
    } else {
      return 'Cari lawan kata / antonim (contoh: baik, tinggi)...';
    }
  }

  Widget _buildModeButton({
    required String id,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _activeMode == id;

    return InkWell(
      onTap: () {
        setState(() {
          _activeMode = id;
          if (id == 'baku') {
            KbbiRepository.instance.loadBakuEntries();
          } else if (id == 'antonim') {
            KbbiRepository.instance.loadAntonimEntries();
          }
        });
        _loadEntries();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationDirectionFilter(bool isDark) {
    final isIdToEn = _translationDirection == TranslationDirection.idToEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Indonesia -> Inggris chip
          Expanded(
            child: InkWell(
              onTap: () {
                if (!isIdToEn) {
                  setState(() => _translationDirection = TranslationDirection.idToEn);
                  _loadEntries();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isIdToEn
                      ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isIdToEn
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🇮🇩 Indonesia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isIdToEn ? FontWeight.bold : FontWeight.w500,
                        color: isIdToEn ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isIdToEn ? AppTheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '🇬🇧 Inggris',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isIdToEn ? FontWeight.bold : FontWeight.w500,
                        color: isIdToEn ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Swap icon button
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            tooltip: 'Tukar Arah Bahasa',
            color: AppTheme.primary,
            visualDensity: VisualDensity.compact,
            onPressed: _toggleTranslationDirection,
          ),

          // Inggris -> Indonesia chip
          Expanded(
            child: InkWell(
              onTap: () {
                if (isIdToEn) {
                  setState(() => _translationDirection = TranslationDirection.enToId);
                  _loadEntries();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !isIdToEn
                      ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isIdToEn
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🇬🇧 Inggris',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: !isIdToEn ? FontWeight.bold : FontWeight.w500,
                        color: !isIdToEn ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: !isIdToEn ? AppTheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '🇮🇩 Indonesia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: !isIdToEn ? FontWeight.bold : FontWeight.w500,
                        color: !isIdToEn ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationView(bool isDark, bool isWide) {
    if (_isLoadingEntries) {
      return const Center(child: CircularProgressIndicator());
    }

    final isEnToId = _translationDirection == TranslationDirection.enToId;
    final sourceLangLabel = isEnToId ? 'Bahasa Inggris' : 'Bahasa Indonesia';
    final targetLangLabel = isEnToId ? 'Bahasa Indonesia' : 'Bahasa Inggris';
    final headwordLangCode = isEnToId ? 'en-US' : 'id-ID';

    if (_currentTranslations.isEmpty) {
      final query = _searchController.text.trim();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(
                query.isNotEmpty
                    ? 'Tidak ada terjemahan untuk "$query" dalam mode $sourceLangLabel ➔ $targetLangLabel'
                    : 'Ketik kata yang ingin diterjemahkan',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (query.isNotEmpty) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _toggleTranslationDirection,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: Text('Cari di arah $targetLangLabel ➔ $sourceLangLabel'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 16,
      ),
      itemCount: _currentTranslations.length,
      itemBuilder: (context, index) {
        final entry = _currentTranslations[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => TranslationDetailSheet.show(context, entry, _translationDirection),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entry.word,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isEnToId
                                    ? Colors.blue.withValues(alpha: 0.12)
                                    : Colors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isEnToId
                                      ? Colors.blue.withValues(alpha: 0.3)
                                      : Colors.teal.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                isEnToId ? 'EN ➔ ID' : 'ID ➔ EN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isEnToId ? Colors.blue : Colors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.translation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Listen headword button
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Dengarkan $sourceLangLabel',
                    color: AppTheme.primary,
                    onPressed: () {
                      TtsService.instance.speak(entry.word, language: headwordLangCode);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKamusView(bool isDark, bool isWide) {
    if (_isLoadingEntries) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada kata yang sesuai dengan "${_searchController.text}"',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 16,
      ),
      itemCount: _currentEntries.length,
      itemBuilder: (context, index) {
        final entry = _currentEntries[index];
        final catColor = _getCategoryColor(entry.category);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => KbbiDetailSheet.show(context, entry),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entry.word,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: catColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                entry.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.definition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Dengarkan',
                    color: AppTheme.primary,
                    onPressed: () {
                      TtsService.instance.speak(entry.word, language: 'id-ID');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBakuView(KbbiRepository repo, bool isDark, bool isWide) {
    final filtered = repo.searchBaku(_searchController.text);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spellcheck_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada pasangan kata baku ditemukan',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Baku badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.word,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('vs', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    // Non-baku badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cancel_rounded, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.wrong,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      tooltip: 'Dengarkan Kata Baku',
                      color: AppTheme.primary,
                      onPressed: () {
                        TtsService.instance.speak(item.word, language: 'id-ID');
                      },
                    ),
                  ],
                ),
                if (item.explain.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.explain,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAntonimView(KbbiRepository repo, bool isDark, bool isWide) {
    final filtered = repo.searchAntonim(_searchController.text);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada pasangan antonim ditemukan',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.kataA,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.compare_arrows_rounded, color: Colors.purple, size: 20),
                    ),
                    Text(
                      item.kataB,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Spacer(),
                    if (item.bidang.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.bidang,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.penjelasan.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.penjelasan,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
