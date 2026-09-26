import 'package:flutter/material.dart';
import '../models/verb.dart';
import '../services/tts_service.dart';
import '../services/verb_repository.dart';
import '../theme/app_theme.dart';
import 'verb_badge.dart';
import 'verb_detail_sheet.dart';

class VerbCard extends StatelessWidget {
  final Verb verb;

  const VerbCard({super.key, required this.verb});

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final isFav = repo.isFavorite(verb.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: InkWell(
            onTap: () => VerbDetailSheet.show(context, verb),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Verb 1 title, badges, and actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              verb.v1,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: verb.isIrregular
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : Colors.blue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                verb.isIrregular ? 'Irregular' : 'Regular',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: verb.isIrregular ? Colors.deepOrange : Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pronounce V1 button
                      IconButton(
                        tooltip: 'Dengarkan pengucapan',
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        color: AppTheme.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          TtsService.instance.speak('${verb.v1}, ${verb.v2}, ${verb.v3}');
                        },
                      ),
                      const SizedBox(width: 12),
                      // Favorite button
                      IconButton(
                        tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFav ? Colors.redAccent : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => repo.toggleFavorite(verb.id),
                      ),
                    ],
                  ),

                  // Indonesian translation
                  const SizedBox(height: 4),
                  Text(
                    verb.meaning,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Verb 1, Verb 2, Verb 3 badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      VerbBadge(
                        label: 'V1',
                        value: verb.v1,
                        color: AppTheme.v1Color,
                        onSpeak: () => TtsService.instance.speak(verb.v1),
                      ),
                      VerbBadge(
                        label: 'V2',
                        value: verb.v2,
                        color: AppTheme.v2Color,
                        onSpeak: () => TtsService.instance.speak(verb.v2),
                      ),
                      VerbBadge(
                        label: 'V3',
                        value: verb.v3,
                        color: AppTheme.v3Color,
                        onSpeak: () => TtsService.instance.speak(verb.v3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
