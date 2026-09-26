import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/translation_entry.dart';
import '../services/translation_repository.dart';
import '../services/tts_service.dart';

class TranslationDetailSheet extends StatelessWidget {
  final TranslationEntry entry;
  final TranslationDirection direction;

  const TranslationDetailSheet({
    super.key,
    required this.entry,
    required this.direction,
  });

  static void show(
    BuildContext context,
    TranslationEntry entry,
    TranslationDirection direction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TranslationDetailSheet(entry: entry, direction: direction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnToId = direction == TranslationDirection.enToId;

    final sourceLangLabel = isEnToId ? 'Bahasa Inggris' : 'Bahasa Indonesia';
    final targetLangLabel = isEnToId ? 'Bahasa Indonesia' : 'Bahasa Inggris';
    final headwordLangCode = isEnToId ? 'en-US' : 'id-ID';
    final transLangCode = isEnToId ? 'id-ID' : 'en-US';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Word + Direction badge + Action buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEnToId
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEnToId
                              ? Colors.blue.withValues(alpha: 0.4)
                              : Colors.teal.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isEnToId ? '🇬🇧 Inggris ➔ 🇮🇩 Indonesia' : '🇮🇩 Indonesia ➔ 🇬🇧 Inggris',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isEnToId ? Colors.blue : Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Audio TTS button for headword
              IconButton.filledTonal(
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Dengarkan $sourceLangLabel',
                onPressed: () {
                  TtsService.instance.speak(entry.word, language: headwordLangCode);
                },
              ),
              const SizedBox(width: 8),

              // Copy button
              IconButton.outlined(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Salin Kata & Arti',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${entry.word}\n(${isEnToId ? "EN" : "ID"})\n\n${entry.translation}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teks berhasil disalin ke clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Translation container
          Text(
            'Terjemahan ($targetLangLabel)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  entry.translation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        TtsService.instance.speak(
                          entry.translation,
                          language: transLangCode,
                        );
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 16),
                      label: Text(
                        'Dengarkan Terjemahan ($targetLangLabel)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
