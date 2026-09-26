import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kbbi_entry.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class KbbiDetailSheet extends StatelessWidget {
  final KbbiEntry entry;

  const KbbiDetailSheet({super.key, required this.entry});

  static void show(BuildContext context, KbbiEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KbbiDetailSheet(entry: entry),
    );
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
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = _getCategoryColor(entry.category);

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

          // Header: Word + Category + Actions
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
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: catColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        entry.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Audio TTS button (Indonesian language)
              IconButton.filledTonal(
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Dengarkan Pengucapan',
                onPressed: () {
                  TtsService.instance.speak(entry.word, language: 'id-ID');
                },
              ),
              const SizedBox(width: 8),

              // Copy button
              IconButton.outlined(
                icon: const Icon(Icons.copy_rounded, size: 20),
                tooltip: 'Salin Definisi',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '${entry.word} (${entry.category}):\n${entry.definition}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Definisi disalin ke papan klip'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Definition label
          const Text(
            'Makna & Penjelasan (KBBI)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Definition body
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: SelectableText(
                  entry.definition,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }
}
