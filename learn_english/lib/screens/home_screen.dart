import 'package:flutter/material.dart';
import '../services/kbbi_repository.dart';
import '../services/verb_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/verb_detail_sheet.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/flashcards_tab.dart';
import 'tabs/grammar_guide_tab.dart';
import 'tabs/quiz_tab.dart';
import 'tabs/universal_dictionary_tab.dart';
import 'tabs/verb_list_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Top navigation active item:
  // 'kamus' (Kamus Verbs), 'kamus_universal' (Kamus Universal KBBI),
  // 'tata_bahasa', 'kuis', 'hafalan', 'favorit', 'split'
  String _activeNav = 'kamus';

  // Customizable Split Screen Configuration:
  // Number of features to split: 2, 3, or 4
  int _splitCount = 3;

  // Layout mode for split screen:
  // For 2 panes: '2_cols' (Kiri & Kanan), '2_rows' (Atas & Bawah)
  // For 3 panes: '3_left_main' (Kiri Full, Kanan Atas & Bawah - default),
  //              '3_right_main' (Kanan Full, Kiri Atas & Bawah),
  //              '3_cols' (3 Kolom Sejajar),
  //              '3_top_main' (Atas Full, Bawah Kiri & Kanan)
  // For 4 panes: '4_grid' (Grid 2x2), '4_cols' (4 Kolom Sejajar)
  String _splitLayoutType = '3_left_main';

  // Selected features for each pane:
  // Options: 'kamus', 'kamus_universal', 'tata_bahasa', 'kuis', 'hafalan', 'favorit'
  String _pane1Feature = 'tata_bahasa'; // Default Left: Tata Bahasa
  String _pane2Feature = 'kamus'; // Default Top Right: Kamus Verb
  String _pane3Feature = 'kuis'; // Default Bottom Right: Kuis
  String _pane4Feature = 'kamus_universal'; // Default 4th pane: Kamus Universal

  // Maximize a specific pane inside split mode (or null)
  int? _maximizedPaneIndex;

  static const Map<String, ({String label, IconData icon, Color color})> _featureMeta = {
    'kamus': (
      label: 'Kamus Verbs (V1, V2, V3)',
      icon: Icons.menu_book_rounded,
      color: Colors.blue,
    ),
    'kamus_universal': (
      label: 'Kamus Universal & Terjemahan',
      icon: Icons.auto_stories_rounded,
      color: Colors.teal,
    ),
    'tata_bahasa': (
      label: 'Tata Bahasa & 16 Tenses',
      icon: Icons.school_rounded,
      color: Colors.indigo,
    ),
    'kuis': (
      label: 'Kuis & Latihan',
      icon: Icons.quiz_rounded,
      color: Colors.deepOrange,
    ),
    'hafalan': (
      label: 'Hafalan (Flashcards)',
      icon: Icons.style_rounded,
      color: Colors.teal,
    ),
    'favorit': (
      label: 'Kata Kerja Favorit',
      icon: Icons.favorite_rounded,
      color: Colors.redAccent,
    ),
  };

  void _showRandomVerb(BuildContext context) {
    final repo = VerbRepository.instance;
    final randomVerb = repo.getRandomVerb();
    if (randomVerb != null) {
      VerbDetailSheet.show(context, randomVerb);
    }
  }

  void _showAboutDialog(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.translate_rounded, color: AppTheme.primary),
            SizedBox(width: 10),
            Text('Belajar Verbs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aplikasi Pembelajaran Bahasa Inggris Terpadu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aplikasi ini mendukung navigasi fitur lengkap (Kamus, Tata Bahasa, Kuis, Hafalan, Favorit) dan fitur Split Tampilan yang dapat dikustomisasi sesuka hati (2 fitur, 3 fitur, atau 4 fitur secara simultan mirip Windows/Android multitasking).',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Total Kata Kerja (Verbs):', '${repo.allVerbs.length} kata kerja'),
                  const SizedBox(height: 4),
                  _buildStatRow('Irregular Verbs:', '${repo.irregularVerbs.length} kata kerja'),
                  const SizedBox(height: 4),
                  _buildStatRow('Regular Verbs:', '${repo.regularVerbs.length} kata kerja'),
                  const SizedBox(height: 4),
                  _buildStatRow('Kamus Universal (KBBI):', '${KbbiRepository.instance.totalWords} kosakata'),
                  const SizedBox(height: 4),
                  _buildStatRow('Kata Baku & Nonbaku:', '${KbbiRepository.instance.bakuCount} pasangan'),
                  const SizedBox(height: 4),
                  _buildStatRow('Antonim (Lawan Kata):', '${KbbiRepository.instance.antonimCount} entri'),
                  const SizedBox(height: 4),
                  _buildStatRow('Panduan Tenses:', '${repo.allTenses.length} tenses komprehensif'),
                  const SizedBox(height: 4),
                  _buildStatRow('Bank Soal:', '${repo.allGrammarQuestions.length} soal grammar'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _getFeatureWidget(String featureKey) {
    switch (featureKey) {
      case 'kamus':
        return const VerbListTab();
      case 'kamus_universal':
        return const UniversalDictionaryTab();
      case 'tata_bahasa':
        return const GrammarGuideTab();
      case 'kuis':
        return const QuizTab();
      case 'hafalan':
        return const FlashcardsTab();
      case 'favorit':
        return FavoritesTab(onExplore: () => setState(() => _activeNav = 'kamus'));
      default:
        return const VerbListTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return Scaffold(
          // TOP NAVIGATION BAR (DI SISI PALING ATAS)
          appBar: _buildTopNavigationBar(context, repo, isDark),

          // MAIN BODY:
          // If 'split' is selected, show the customizable split screen workspace.
          // Otherwise, show the selected single feature in FULL VIEW (default: 'kamus').
          body: _activeNav == 'split'
              ? _buildCustomSplitWorkspace(context, isDark)
              : _getFeatureWidget(_activeNav),
        );
      },
    );
  }

  // WIDGET: TOP NAVIGATION BAR ACROSS THE TOP
  PreferredSizeWidget _buildTopNavigationBar(
    BuildContext context,
    VerbRepository repo,
    bool isDark,
  ) {
    return AppBar(
      titleSpacing: 16,
      toolbarHeight: 64,
      title: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Belajar Verbs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'V1 • V2 • V3 & 16 Tenses',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // 6 Nav Items in Top Bar
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 1. Kamus Verbs (English)
                  _buildNavTabButton(
                    id: 'kamus',
                    label: 'Kamus Verbs',
                    icon: Icons.menu_book_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // 2. Kamus Universal (KBBI)
                  _buildNavTabButton(
                    id: 'kamus_universal',
                    label: 'Kamus Universal',
                    icon: Icons.auto_stories_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // 2. Tata Bahasa
                  _buildNavTabButton(
                    id: 'tata_bahasa',
                    label: 'Tata Bahasa',
                    icon: Icons.school_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // 3. Kuis
                  _buildNavTabButton(
                    id: 'kuis',
                    label: 'Kuis',
                    icon: Icons.quiz_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // 4. Hafalan
                  _buildNavTabButton(
                    id: 'hafalan',
                    label: 'Hafalan',
                    icon: Icons.style_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // 5. Favorit
                  _buildNavTabButton(
                    id: 'favorit',
                    label: 'Favorit (${repo.favoriteVerbs.length})',
                    icon: Icons.favorite_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),

                  // 6. Split Tampilan (Special button)
                  InkWell(
                    onTap: () => setState(() => _activeNav = 'split'),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _activeNav == 'split'
                            ? const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                              )
                            : null,
                        color: _activeNav == 'split'
                            ? null
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _activeNav == 'split'
                              ? Colors.transparent
                              : const Color(0xFF818CF8),
                          width: 1.5,
                        ),
                        boxShadow: _activeNav == 'split'
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.splitscreen_rounded,
                            size: 16,
                            color: _activeNav == 'split' ? Colors.white : AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Split Tampilan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeNav == 'split' ? Colors.white : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Dark / Light Mode Toggle
        IconButton(
          tooltip: repo.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
          icon: Icon(
            repo.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
          ),
          onPressed: () => repo.toggleThemeMode(),
        ),

        // Random Verb
        IconButton(
          tooltip: 'Kata Kerja Acak',
          icon: const Icon(Icons.casino_rounded, size: 20),
          onPressed: () => _showRandomVerb(context),
        ),

        // Info dialog
        IconButton(
          tooltip: 'Info Aplikasi',
          icon: const Icon(Icons.info_outline_rounded, size: 20),
          onPressed: () => _showAboutDialog(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNavTabButton({
    required String id,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _activeNav == id;

    return InkWell(
      onTap: () => setState(() => _activeNav = id),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF1E293B) : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: CUSTOMIZABLE MULTITASKING SPLIT SCREEN WORKSPACE
  Widget _buildCustomSplitWorkspace(BuildContext context, bool isDark) {
    // If a pane is temporarily maximized
    if (_maximizedPaneIndex != null) {
      String feature = _getPaneFeatureByIndex(_maximizedPaneIndex!);
      return Column(
        children: [
          _buildSplitControlBar(isDark),
          Expanded(
            child: _buildPaneWidget(
              paneIndex: _maximizedPaneIndex!,
              paneLabel: 'Panel ${_maximizedPaneIndex!}',
              featureKey: feature,
              isMaximized: true,
              isDark: isDark,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // 1. Split Control & Layout Customization Bar
        _buildSplitControlBar(isDark),

        // 2. The Dynamic Split Workspace Layout
        Expanded(
          child: _buildDynamicPanesLayout(isDark),
        ),
      ],
    );
  }

  String _getPaneFeatureByIndex(int index) {
    switch (index) {
      case 1:
        return _pane1Feature;
      case 2:
        return _pane2Feature;
      case 3:
        return _pane3Feature;
      case 4:
        return _pane4Feature;
      default:
        return _pane1Feature;
    }
  }

  void _setPaneFeatureByIndex(int index, String newFeature) {
    setState(() {
      switch (index) {
        case 1:
          _pane1Feature = newFeature;
          break;
        case 2:
          _pane2Feature = newFeature;
          break;
        case 3:
          _pane3Feature = newFeature;
          break;
        case 4:
          _pane4Feature = newFeature;
          break;
      }
    });
  }

  // CONTROL BAR: Customize 2, 3, or 4 Panes + Layout Options
  Widget _buildSplitControlBar(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.view_quilt_rounded, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Kustomisasi Split Tampilan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 14),

            // Number of Panes Selector (2, 3, 4 Fitur)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildCountChip(2, '2 Fitur', isDark),
                  _buildCountChip(3, '3 Fitur', isDark),
                  _buildCountChip(4, '4 Fitur', isDark),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Layout Mode Selector Dropdown based on split count
            Text(
              'Model Layout:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _splitLayoutType,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  items: _getAvailableLayoutItems(),
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() => _splitLayoutType = newVal);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Quick Preset Reset Button
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset Standar (3 Fitur)', style: TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() {
                  _splitCount = 3;
                  _splitLayoutType = '3_left_main';
                  _pane1Feature = 'tata_bahasa';
                  _pane2Feature = 'kamus';
                  _pane3Feature = 'kuis';
                  _maximizedPaneIndex = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(int count, String label, bool isDark) {
    final isSelected = _splitCount == count;

    return InkWell(
      onTap: () {
        setState(() {
          _splitCount = count;
          _maximizedPaneIndex = null;
          if (count == 2) {
            _splitLayoutType = '2_cols';
          } else if (count == 3) {
            _splitLayoutType = '3_left_main';
          } else {
            _splitLayoutType = '4_grid';
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getAvailableLayoutItems() {
    if (_splitCount == 2) {
      return const [
        DropdownMenuItem(value: '2_cols', child: Text('Sampingan (Kiri & Kanan)')),
        DropdownMenuItem(value: '2_rows', child: Text('Bertumpuk (Atas & Bawah)')),
      ];
    } else if (_splitCount == 3) {
      return const [
        DropdownMenuItem(value: '3_left_main', child: Text('Kiri Full + Kanan Atas & Bawah (Standar)')),
        DropdownMenuItem(value: '3_right_main', child: Text('Kanan Full + Kiri Atas & Bawah')),
        DropdownMenuItem(value: '3_cols', child: Text('3 Kolom Berjejer')),
        DropdownMenuItem(value: '3_top_main', child: Text('Atas Full + Bawah Kiri & Kanan')),
      ];
    } else {
      return const [
        DropdownMenuItem(value: '4_grid', child: Text('Grid 2x2 (4 Kuadran)')),
        DropdownMenuItem(value: '4_cols', child: Text('4 Kolom Sejajar')),
      ];
    }
  }

  // WIDGET: DYNAMIC PANES LAYOUT (2, 3, or 4 Panes)
  Widget _buildDynamicPanesLayout(bool isDark) {
    if (_splitCount == 2) {
      // 2 PANES
      if (_splitLayoutType == '2_rows') {
        return Column(
          children: [
            Expanded(child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Panel Atas', featureKey: _pane1Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: true, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Panel Bawah', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
          ],
        );
      } else {
        // 2 Columns
        return Row(
          children: [
            Expanded(child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Panel Kiri', featureKey: _pane1Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Panel Kanan', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
          ],
        );
      }
    } else if (_splitCount == 3) {
      // 3 PANES
      if (_splitLayoutType == '3_cols') {
        return Row(
          children: [
            Expanded(child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Kolom 1', featureKey: _pane1Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Kolom 2', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 3, paneLabel: 'Kolom 3', featureKey: _pane3Feature, isMaximized: false, isDark: isDark)),
          ],
        );
      } else if (_splitLayoutType == '3_right_main') {
        return Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Kiri Atas', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
                  _buildDivider(isHorizontal: true, isDark: isDark),
                  Expanded(child: _buildPaneWidget(paneIndex: 3, paneLabel: 'Kiri Bawah', featureKey: _pane3Feature, isMaximized: false, isDark: isDark)),
                ],
              ),
            ),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(
              flex: 5,
              child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Kanan (Utama)', featureKey: _pane1Feature, isMaximized: false, isDark: isDark),
            ),
          ],
        );
      } else if (_splitLayoutType == '3_top_main') {
        return Column(
          children: [
            Expanded(
              flex: 5,
              child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Atas (Utama)', featureKey: _pane1Feature, isMaximized: false, isDark: isDark),
            ),
            _buildDivider(isHorizontal: true, isDark: isDark),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Bawah Kiri', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
                  _buildDivider(isHorizontal: false, isDark: isDark),
                  Expanded(child: _buildPaneWidget(paneIndex: 3, paneLabel: 'Bawah Kanan', featureKey: _pane3Feature, isMaximized: false, isDark: isDark)),
                ],
              ),
            ),
          ],
        );
      } else {
        // DEFAULT 3-PANE LAYOUT:
        // Sisi Kiri (Full Height) = Tata Bahasa
        // Sisi Kanan Atas = Kamus
        // Sisi Kanan Bawah = Kuis
        return Row(
          children: [
            // Left Pane (Full Height)
            Expanded(
              flex: 5,
              child: _buildPaneWidget(
                paneIndex: 1,
                paneLabel: 'Sisi Kiri',
                featureKey: _pane1Feature,
                isMaximized: false,
                isDark: isDark,
              ),
            ),
            _buildDivider(isHorizontal: false, isDark: isDark),
            // Right Column
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Top Right
                  Expanded(
                    child: _buildPaneWidget(
                      paneIndex: 2,
                      paneLabel: 'Kanan Atas',
                      featureKey: _pane2Feature,
                      isMaximized: false,
                      isDark: isDark,
                    ),
                  ),
                  _buildDivider(isHorizontal: true, isDark: isDark),
                  // Bottom Right
                  Expanded(
                    child: _buildPaneWidget(
                      paneIndex: 3,
                      paneLabel: 'Kanan Bawah',
                      featureKey: _pane3Feature,
                      isMaximized: false,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    } else {
      // 4 PANES
      if (_splitLayoutType == '4_cols') {
        return Row(
          children: [
            Expanded(child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Panel 1', featureKey: _pane1Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Panel 2', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 3, paneLabel: 'Panel 3', featureKey: _pane3Feature, isMaximized: false, isDark: isDark)),
            _buildDivider(isHorizontal: false, isDark: isDark),
            Expanded(child: _buildPaneWidget(paneIndex: 4, paneLabel: 'Panel 4', featureKey: _pane4Feature, isMaximized: false, isDark: isDark)),
          ],
        );
      } else {
        // 4 Panes 2x2 Grid (Kiri Atas, Kanan Atas, Kiri Bawah, Kanan Bawah)
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPaneWidget(paneIndex: 1, paneLabel: 'Kiri Atas', featureKey: _pane1Feature, isMaximized: false, isDark: isDark)),
                  _buildDivider(isHorizontal: false, isDark: isDark),
                  Expanded(child: _buildPaneWidget(paneIndex: 2, paneLabel: 'Kanan Atas', featureKey: _pane2Feature, isMaximized: false, isDark: isDark)),
                ],
              ),
            ),
            _buildDivider(isHorizontal: true, isDark: isDark),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPaneWidget(paneIndex: 3, paneLabel: 'Kiri Bawah', featureKey: _pane3Feature, isMaximized: false, isDark: isDark)),
                  _buildDivider(isHorizontal: false, isDark: isDark),
                  Expanded(child: _buildPaneWidget(paneIndex: 4, paneLabel: 'Kanan Bawah', featureKey: _pane4Feature, isMaximized: false, isDark: isDark)),
                ],
              ),
            ),
          ],
        );
      }
    }
  }

  Widget _buildDivider({required bool isHorizontal, required bool isDark}) {
    if (isHorizontal) {
      return Divider(
        height: 2,
        thickness: 2,
        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
      );
    } else {
      return VerticalDivider(
        width: 2,
        thickness: 2,
        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
      );
    }
  }

  // WIDGET: INDIVIDUAL PANE WITH ITS OWN SELECTOR HEADER & BODY
  Widget _buildPaneWidget({
    required int paneIndex,
    required String paneLabel,
    required String featureKey,
    required bool isMaximized,
    required bool isDark,
  }) {
    final meta = _featureMeta[featureKey] ?? _featureMeta['kamus']!;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header of this pane
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                // Pane position badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    paneLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: meta.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Icon(meta.icon, size: 16, color: meta.color),
                const SizedBox(width: 6),

                // Dropdown to change the feature inside this pane
                Expanded(
                  child: PopupMenuButton<String>(
                    tooltip: 'Ganti fitur untuk $paneLabel',
                    onSelected: (newFeature) => _setPaneFeatureByIndex(paneIndex, newFeature),
                    itemBuilder: (ctx) => _featureMeta.entries.map((entry) {
                      final isSelected = entry.key == featureKey;
                      return PopupMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(
                              entry.value.icon,
                              size: 18,
                              color: isSelected ? AppTheme.primary : entry.value.color,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primary : null,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_rounded, size: 16, color: AppTheme.primary),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            meta.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                // Maximize / Restore Button for this pane
                IconButton(
                  tooltip: isMaximized ? 'Kembalikan ke Split Screen' : 'Perbesar Penuh Panel Ini',
                  icon: Icon(
                    isMaximized ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isMaximized) {
                        _maximizedPaneIndex = null;
                      } else {
                        _maximizedPaneIndex = paneIndex;
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Pane Body
          Expanded(
            child: _getFeatureWidget(featureKey),
          ),
        ],
      ),
    );
  }
}
