import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/verb.dart';
import '../services/tts_service.dart';
import '../services/verb_repository.dart';
import '../theme/app_theme.dart';

class VerbDetailSheet extends StatelessWidget {
  final Verb verb;

  const VerbDetailSheet({super.key, required this.verb});

  static void show(BuildContext context, Verb verb) {
    final width = MediaQuery.of(context).size.width;
    if (width > 640) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
            child: VerbDetailSheet(verb: verb),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: VerbDetailSheet(verb: verb),
        ),
      );
    }
  }

  void _copyAllForms(BuildContext context) {
    final text = 'V1: ${verb.v1}\n'
        'V2: ${verb.v2}\n'
        'V3: ${verb.v3}\n'
        'V-ing: ${verb.vIng}\n'
        'Arti: ${verb.meaning}\n'
        'Contoh: ${verb.exampleSentence} (${verb.exampleMeaning})';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disalin ke papan klip!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final isFav = repo.isFavorite(verb.id);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              verb.v1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              IconButton(
                tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : null,
                ),
                onPressed: () => repo.toggleFavorite(verb.id),
              ),
              IconButton(
                tooltip: 'Salin detail kata kerja',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => _copyAllForms(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge row
                Row(
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
                        verb.isIrregular ? 'Irregular Verb (Tak Beraturan)' : 'Regular Verb (Beraturan)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: verb.isIrregular ? Colors.deepOrange : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        verb.difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Meaning in Indonesian
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : Colors.indigo.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arti dalam Bahasa Indonesia:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade400 : Colors.indigo.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verb.meaning,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Verb Forms Matrix
                const Text(
                  'Bentuk Perubahan Kata Kerja (Conjugation)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                _buildFormItem(
                  context,
                  title: 'Verb 1 (Infinitive / Base Form)',
                  value: verb.v1,
                  usage: 'Digunakan pada Simple Present, setelah Modal (can, will, must), dan To-infinitive.',
                  color: AppTheme.v1Color,
                  onSpeak: () => TtsService.instance.speak(verb.v1),
                ),
                const SizedBox(height: 10),

                _buildFormItem(
                  context,
                  title: 'Verb 2 (Past Simple)',
                  value: verb.v2,
                  usage: 'Digunakan pada kalimat masa lampau (Simple Past Tense).',
                  color: AppTheme.v2Color,
                  onSpeak: () => TtsService.instance.speak(verb.v2),
                ),
                const SizedBox(height: 10),

                _buildFormItem(
                  context,
                  title: 'Verb 3 (Past Participle)',
                  value: verb.v3,
                  usage: 'Digunakan pada Perfect Tenses (have/has/had + V3) dan Kalimat Pasif (Passive Voice).',
                  color: AppTheme.v3Color,
                  onSpeak: () => TtsService.instance.speak(verb.v3),
                ),
                const SizedBox(height: 10),

                // Other forms: V-ing and 3rd person singular
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniFormItem(
                        context,
                        title: 'Verb-ing (Present Participle)',
                        value: verb.vIng,
                        color: AppTheme.vIngColor,
                        onSpeak: () => TtsService.instance.speak(verb.vIng),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniFormItem(
                        context,
                        title: '3rd Person (He/She/It)',
                        value: verb.vS,
                        color: Colors.teal,
                        onSpeak: () => TtsService.instance.speak(verb.vS),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grammar pattern / Tips
                if (verb.tip.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catatan Pola / Aturan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                verb.tip,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Example Sentence
                const Text(
                  'Contoh Penggunaan dalam Kalimat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '"${verb.exampleSentence}"',
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                            onPressed: () => TtsService.instance.speak(verb.exampleSentence),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        verb.exampleMeaning,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormItem(
    BuildContext context, {
    required String title,
    required String value,
    required String usage,
    required Color color,
    required VoidCallback onSpeak,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.volume_up_rounded, size: 18, color: color),
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            usage,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFormItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required VoidCallback onSpeak,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.volume_up_rounded, size: 16, color: color),
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
