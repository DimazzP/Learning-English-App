import 'package:flutter/material.dart';
import '../../models/tense.dart';
import '../../services/tts_service.dart';
import '../../services/verb_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tense_detail_sheet.dart';

class GrammarGuideTab extends StatefulWidget {
  const GrammarGuideTab({super.key});

  @override
  State<GrammarGuideTab> createState() => _GrammarGuideTabState();
}

class _GrammarGuideTabState extends State<GrammarGuideTab> {
  String _selectedCategory = 'All'; // 'All', 'Present', 'Past', 'Future', 'Past Future'
  String _viewMode = 'compare'; // 'compare' (tabel komparasi), 'grid_table' (data table), 'cards' (kartu detail)

  // Standard unified comparative examples using the verb "write"
  static const Map<String, Map<String, String>> _comparativeExamples = {
    'simple_present': {
      'sentence': 'She writes a letter.',
      'meaning': 'Dia menulis surat (kebiasaan/rutinitas).',
      'formula': 'S + V1 (s/es) + O',
      'verbForm': 'V1 (writes)',
    },
    'present_continuous': {
      'sentence': 'She is writing a letter.',
      'meaning': 'Dia sedang menulis surat (saat ini).',
      'formula': 'S + is/am/are + V-ing + O',
      'verbForm': 'is + V-ing',
    },
    'present_perfect': {
      'sentence': 'She has written a letter.',
      'meaning': 'Dia sudah menulis surat (selesai).',
      'formula': 'S + have/has + V3 + O',
      'verbForm': 'has + V3 (written)',
    },
    'present_perfect_continuous': {
      'sentence': 'She has been writing a letter for 2 hours.',
      'meaning': 'Dia telah sedang menulis surat selama 2 jam.',
      'formula': 'S + have/has + been + V-ing + O',
      'verbForm': 'has been + V-ing',
    },
    'simple_past': {
      'sentence': 'She wrote a letter yesterday.',
      'meaning': 'Dia menulis surat kemarin (lampau).',
      'formula': 'S + V2 + O',
      'verbForm': 'V2 (wrote)',
    },
    'past_continuous': {
      'sentence': 'She was writing a letter when I arrived.',
      'meaning': 'Dia sedang menulis surat ketika saya tiba.',
      'formula': 'S + was/were + V-ing + O',
      'verbForm': 'was + V-ing',
    },
    'past_perfect': {
      'sentence': 'She had written a letter before she slept.',
      'meaning': 'Dia sudah menulis surat sebelum dia tidur.',
      'formula': 'S + had + V3 + O',
      'verbForm': 'had + V3 (written)',
    },
    'past_perfect_continuous': {
      'sentence': 'She had been writing a letter for an hour before the power cut.',
      'meaning': 'Dia telah sedang menulis surat sebelum listrik padam.',
      'formula': 'S + had + been + V-ing + O',
      'verbForm': 'had been + V-ing',
    },
    'simple_future': {
      'sentence': 'She will write a letter tomorrow.',
      'meaning': 'Dia akan menulis surat besok.',
      'formula': 'S + will + V1 + O',
      'verbForm': 'will + V1 (write)',
    },
    'future_continuous': {
      'sentence': 'She will be writing a letter at 8 AM tomorrow.',
      'meaning': 'Dia akan sedang menulis surat pukul 8 pagi besok.',
      'formula': 'S + will + be + V-ing + O',
      'verbForm': 'will be + V-ing',
    },
    'future_perfect': {
      'sentence': 'She will have written a letter by noon.',
      'meaning': 'Dia akan sudah selesai menulis surat menjelang siang.',
      'formula': 'S + will + have + V3 + O',
      'verbForm': 'will have + V3 (written)',
    },
    'future_perfect_continuous': {
      'sentence': 'She will have been writing a letter for 3 hours by 5 PM.',
      'meaning': 'Dia akan telah sedang menulis surat selama 3 jam menjelang jam 5.',
      'formula': 'S + will + have + been + V-ing + O',
      'verbForm': 'will have been + V-ing',
    },
    'past_future': {
      'sentence': 'She would write a letter if she had time.',
      'meaning': 'Dia tadinya akan menulis surat jika punya waktu.',
      'formula': 'S + would + V1 + O',
      'verbForm': 'would + V1 (write)',
    },
    'past_future_continuous': {
      'sentence': 'She would be writing a letter if she were not sick.',
      'meaning': 'Dia tadinya akan sedang menulis surat jika tidak sakit.',
      'formula': 'S + would + be + V-ing + O',
      'verbForm': 'would be + V-ing',
    },
    'past_future_perfect': {
      'sentence': 'She would have written a letter if she had known the news.',
      'meaning': 'Dia semestinya sudah menulis surat jika tahu kabar itu.',
      'formula': 'S + would + have + V3 + O',
      'verbForm': 'would have + V3 (written)',
    },
    'past_future_perfect_continuous': {
      'sentence': 'She would have been writing a letter for an hour if you had not called.',
      'meaning': 'Dia semestinya telah sedang menulis surat seandainya kamu tidak menelepon.',
      'formula': 'S + would + have + been + V-ing + O',
      'verbForm': 'would have been + V-ing',
    },
  };

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'present':
        return Colors.blue;
      case 'past':
        return Colors.amber.shade800;
      case 'future':
        return Colors.teal;
      case 'past future':
        return Colors.purple;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTenses = repo.allTenses.where((t) {
      if (_selectedCategory == 'All') return true;
      return t.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembelajaran 16 Tenses',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tabel perbandingan kalimat, rumus, bentuk kata kerja & contoh',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // View Mode Selector (Segmented buttons - no overflow)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModeButton(
                      label: 'Tabel Perbandingan',
                      icon: Icons.table_rows_rounded,
                      selected: _viewMode == 'compare',
                      onTap: () => setState(() => _viewMode = 'compare'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      label: 'Tabel Grid Lengkap',
                      icon: Icons.grid_on_rounded,
                      selected: _viewMode == 'grid_table',
                      onTap: () => setState(() => _viewMode = 'grid_table'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      label: 'Kartu Penjelasan',
                      icon: Icons.dashboard_rounded,
                      selected: _viewMode == 'cards',
                      onTap: () => setState(() => _viewMode = 'cards'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category Selector Chips (All, Present, Past, Future, Past Future)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('Semua (${repo.allTenses.length})'),
                      selected: _selectedCategory == 'All',
                      onSelected: (val) => setState(() => _selectedCategory = 'All'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Present (4)'),
                      selected: _selectedCategory == 'Present',
                      onSelected: (val) => setState(() => _selectedCategory = 'Present'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Past (4)'),
                      selected: _selectedCategory == 'Past',
                      onSelected: (val) => setState(() => _selectedCategory = 'Past'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Future (4)'),
                      selected: _selectedCategory == 'Future',
                      onSelected: (val) => setState(() => _selectedCategory = 'Future'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Past Future (4)'),
                      selected: _selectedCategory == 'Past Future',
                      onSelected: (val) => setState(() => _selectedCategory = 'Past Future'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // MAIN CONTENT ACCORDING TO VIEW MODE
              if (_viewMode == 'compare') ...[
                // Comparative Table List (Name, Formula, Example & Audio in each row)
                _buildComparisonListView(context, filteredTenses, isDark),
              ] else if (_viewMode == 'grid_table') ...[
                // Full Raw Horizontal Data Table
                _buildFullDataTable(context, filteredTenses, isDark),
              ] else ...[
                // 16 Tenses Cards Grid / List
                _buildTenseCardsGrid(context, filteredTenses, isDark),
              ],

              const SizedBox(height: 32),

              // Section: Hubungan Tenses dengan Verb 1, 2, dan 3
              _buildCard(
                context,
                title: '📌 Hubungan 16 Tenses dengan Verb 1, Verb 2, dan Verb 3',
                child: Column(
                  children: [
                    _buildVerbExplanationRow(
                      badge: 'Verb 1',
                      badgeColor: AppTheme.v1Color,
                      name: 'Infinitive / Base Form',
                      usage: 'Digunakan pada: Simple Present, Simple Future (will + V1), dan Past Future (would + V1).',
                      formula: 'S + V1 (s/es) | S + will + V1 | S + would + V1',
                      example: 'I study English every day.',
                      exampleMeaning: 'Saya belajar bahasa Inggris setiap hari.',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildVerbExplanationRow(
                      badge: 'Verb 2',
                      badgeColor: AppTheme.v2Color,
                      name: 'Past Simple',
                      usage: 'Digunakan KHUSUS pada: Simple Past Tense untuk aksi yang telah tuntas di masa lampau.',
                      formula: 'Subject + V2 + Complement',
                      example: 'I studied English yesterday.',
                      exampleMeaning: 'Saya belajar bahasa Inggris kemarin.',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildVerbExplanationRow(
                      badge: 'Verb 3',
                      badgeColor: AppTheme.v3Color,
                      name: 'Past Participle',
                      usage: 'Digunakan pada SEMUA Perfect Tenses (Present Perfect, Past Perfect, Future Perfect, Past Future Perfect) dan Kalimat Pasif.',
                      formula: 'have / has / had / will have / would have + Verb 3',
                      example: 'I have studied English for three years.',
                      exampleMeaning: 'Saya telah belajar bahasa Inggris selama tiga tahun.',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildVerbExplanationRow(
                      badge: 'V-ing',
                      badgeColor: AppTheme.vIngColor,
                      name: 'Present Participle',
                      usage: 'Digunakan pada SEMUA Continuous Tenses (Present, Past, Future, Perfect Continuous).',
                      formula: 'to be + Verb-ing',
                      example: 'I am studying English right now.',
                      exampleMeaning: 'Saya sedang belajar bahasa Inggris saat ini.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Regular Verbs Rules
              _buildCard(
                context,
                title: '📘 Pola Regular Verbs (Kata Kerja Beraturan)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kata kerja beraturan (Regular Verbs) selalu memiliki akhiran yang konsisten (-ed atau -d) pada Verb 2 dan Verb 3.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      ruleNumber: '1',
                      ruleName: 'Umum (+ed)',
                      desc: 'Sebagian besar kata kerja cukup ditambahkan -ed.',
                      examples: 'walk ➔ walked ➔ walked\nvisit ➔ visited ➔ visited\nclean ➔ cleaned ➔ cleaned',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildRuleItem(
                      ruleNumber: '2',
                      ruleName: 'Berakhiran huruf -e (+d)',
                      desc: 'Jika kata kerja sudah berakhiran huruf e, cukup tambahkan huruf -d.',
                      examples: 'like ➔ liked ➔ liked\nclose ➔ closed ➔ closed\nlive ➔ lived ➔ lived',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildRuleItem(
                      ruleNumber: '3',
                      ruleName: 'Konsonan + y (y ➔ -ied)',
                      desc: 'Jika berakhiran huruf konsonan + y, ubah y menjadi i lalu tambahkan -ed.',
                      examples: 'study ➔ studied ➔ studied\ncry ➔ cried ➔ cried\ncarry ➔ carried ➔ carried',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildRuleItem(
                      ruleNumber: '4',
                      ruleName: 'Penggandaan Konsonan Akhir',
                      desc: 'Kata 1 suku kata dengan pola konsonan-vokal-konsonan, huruf akhir digandakan.',
                      examples: 'stop ➔ stopped ➔ stopped\nplan ➔ planned ➔ planned\ndrop ➔ dropped ➔ dropped',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Irregular Verbs Patterns
              _buildCard(
                context,
                title: '📙 5 Tipe Pola Irregular Verbs (Kata Kerja Tak Beraturan)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meskipun disebut "tak beraturan", sebagian besar kata kerja ini memiliki 5 kelompok pola yang memudahkan hafalan:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _buildPatternBox(
                      number: 'Pola 1',
                      title: 'Ketiga Bentuk Sama Persis (V1 = V2 = V3)',
                      desc: 'Bentuk kata kerja tidak mengalami perubahan sama sekali.',
                      examples: [
                        'cut ➔ cut ➔ cut (memotong)',
                        'put ➔ put ➔ put (menaruh)',
                        'hit ➔ hit ➔ hit (memukul)',
                        'hurt ➔ hurt ➔ hurt (melukai)',
                        'cost ➔ cost ➔ cost (berharga)',
                      ],
                      color: Colors.teal,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPatternBox(
                      number: 'Pola 2',
                      title: 'Verb 2 dan Verb 3 Sama (V2 = V3)',
                      desc: 'Bentuk lampau dan past participle memiliki ejaan yang sama.',
                      examples: [
                        'bring ➔ brought ➔ brought (membawa)',
                        'buy ➔ bought ➔ bought (membeli)',
                        'teach ➔ taught ➔ taught (mengajar)',
                        'feel ➔ felt ➔ felt (merasa)',
                      ],
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPatternBox(
                      number: 'Pola 3',
                      title: 'Verb 1 dan Verb 3 Sama (V1 = V3)',
                      desc: 'Bentuk V1 dan V3 identik, hanya V2 yang berbeda.',
                      examples: [
                        'come ➔ came ➔ come (datang)',
                        'become ➔ became ➔ become (menjadi)',
                        'run ➔ ran ➔ run (berlari)',
                      ],
                      color: Colors.indigo,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPatternBox(
                      number: 'Pola 4',
                      title: 'Perubahan Vokal i ➔ a ➔ u',
                      desc: 'Pola fonetis berirama yang sangat khas.',
                      examples: [
                        'sing ➔ sang ➔ sung (bernyanyi)',
                        'ring ➔ rang ➔ rung (berdering)',
                        'drink ➔ drank ➔ drunk (minum)',
                        'swim ➔ swam ➔ swum (berenang)',
                      ],
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPatternBox(
                      number: 'Pola 5',
                      title: 'Verb 3 Berakhiran -en atau -n',
                      desc: 'Bentuk past participle diakhiri dengan huruf -en atau -n.',
                      examples: [
                        'write ➔ wrote ➔ written (menulis)',
                        'speak ➔ spoke ➔ spoken (berbicara)',
                        'break ➔ broke ➔ broken (merusak)',
                        'choose ➔ chose ➔ chosen (memilih)',
                      ],
                      color: Colors.deepPurple,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET 1: Comparative Table List (Name, Formula, Comparative Example, Audio, Meaning)
  Widget _buildComparisonListView(
    BuildContext context,
    List<Tense> tenses,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.compare_arrows_rounded, color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tabel Perbandingan Kalimat (16 Tenses)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Membandingkan kalimat menggunakan subjek "She" dan kata kerja "write" (menulis)',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tenses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tense = tenses[index];
              final comp = _comparativeExamples[tense.id] ?? {
                'sentence': tense.examples.isNotEmpty ? tense.examples.first.sentence : '',
                'meaning': tense.examples.isNotEmpty ? tense.examples.first.meaning : '',
                'formula': tense.formulas.verbal['positive'] ?? '',
                'verbForm': tense.verbFormUsed,
              };
              final catColor = _getCategoryColor(tense.category);

              return InkWell(
                onTap: () => TenseDetailSheet.show(context, tense),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: Number + Tense Name + Category badge + Audio button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tense.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  tense.category,
                                  style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Dengarkan kalimat',
                            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                            onPressed: () => TtsService.instance.speak(comp['sentence']!),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Rumus (Formula) pill
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Rumus: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                comp['formula']!,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.cyanAccent : Colors.indigo.shade800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                comp['verbForm']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Contoh Kalimat (Example Sentence)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${comp['sentence']!}"',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comp['meaning']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // WIDGET 2: Full Raw Horizontal Data Table
  Widget _buildFullDataTable(
    BuildContext context,
    List<Tense> tenses,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.grid_on_rounded, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tabel Grid Seluruh 16 Tenses (Geser ke samping untuk melihat semua kolom)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              ),
              columnSpacing: 20,
              horizontalMargin: 16,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Nama Tenses')),
                DataColumn(label: Text('Rumus Utama')),
                DataColumn(label: Text('Bentuk Verb')),
                DataColumn(label: Text('Contoh Kalimat')),
                DataColumn(label: Text('Arti Bahasa Indonesia')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: tenses.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final tense = entry.value;
                final comp = _comparativeExamples[tense.id] ?? {
                  'sentence': tense.examples.isNotEmpty ? tense.examples.first.sentence : '',
                  'meaning': tense.examples.isNotEmpty ? tense.examples.first.meaning : '',
                  'formula': tense.formulas.verbal['positive'] ?? '',
                  'verbForm': tense.verbFormUsed,
                };
                final catColor = _getCategoryColor(tense.category);

                return DataRow(
                  onSelectChanged: (_) => TenseDetailSheet.show(context, tense),
                  cells: [
                    DataCell(Text('$index', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tense.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(tense.category, style: TextStyle(fontSize: 10, color: catColor)),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        comp['formula']!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.cyanAccent : Colors.indigo.shade800,
                        ),
                      ),
                    ),
                    DataCell(Text(comp['verbForm']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                    DataCell(Text(comp['sentence']!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))),
                    DataCell(Text(comp['meaning']!, style: const TextStyle(fontSize: 11))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.primary),
                            onPressed: () => TtsService.instance.speak(comp['sentence']!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new_rounded, size: 16),
                            onPressed: () => TenseDetailSheet.show(context, tense),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET 3: 16 Tenses Cards Grid
  Widget _buildTenseCardsGrid(
    BuildContext context,
    List<Tense> tenses,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: tenses.length,
            itemBuilder: (context, index) {
              return _buildTenseCard(context, tenses[index], isDark);
            },
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildTenseCard(context, tenses[index], isDark);
            },
          );
        }
      },
    );
  }

  Widget _buildTenseCard(BuildContext context, Tense tense, bool isDark) {
    final catColor = _getCategoryColor(tense.category);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => TenseDetailSheet.show(context, tense),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tense.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tense.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tense.shortSummary,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Kata Kerja: ${tense.verbFormUsed}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildVerbExplanationRow({
    required String badge,
    required Color badgeColor,
    required String name,
    required String usage,
    required String formula,
    required String example,
    required String exampleMeaning,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          usage,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Rumus: $formula',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.cyanAccent : Colors.indigo.shade800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Contoh: "$example" ($exampleMeaning)',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.volume_up_rounded, size: 16, color: AppTheme.primary),
              onPressed: () => TtsService.instance.speak(example),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required String ruleNumber,
    required String ruleName,
    required String desc,
    required String examples,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.primary,
            child: Text(
              ruleNumber,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ruleName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    examples,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternBox({
    required String number,
    required String title,
    required String desc,
    required List<String> examples,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: examples.map((ex) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(
                  ex,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
