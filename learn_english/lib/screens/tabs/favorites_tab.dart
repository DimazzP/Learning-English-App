import 'package:flutter/material.dart';
import '../../services/verb_repository.dart';
import '../../widgets/verb_card.dart';

class FavoritesTab extends StatefulWidget {
  final VoidCallback onExplore;

  const FavoritesTab({super.key, required this.onExplore});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final favVerbs = repo.favoriteVerbs.where((v) {
          if (query.isEmpty) return true;
          return v.v1.toLowerCase().contains(query) ||
              v.v2.toLowerCase().contains(query) ||
              v.v3.toLowerCase().contains(query) ||
              v.meaning.toLowerCase().contains(query);
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Kata Kerja Favorit (${repo.favoriteVerbs.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Koleksi kata kerja yang Anda simpan untuk dipelajari lebih lanjut.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        if (repo.favoriteVerbs.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Cari di antara kata kerja favorit...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (repo.favoriteVerbs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 64,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Favorit',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tekan ikon hati pada kata kerja di kamus untuk menyimpannya di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: widget.onExplore,
                              icon: const Icon(Icons.search_rounded),
                              label: const Text('Jelajahi Kamus Kata Kerja'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isWide)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth >= 1100 ? 3 : 2,
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => VerbCard(verb: favVerbs[index]),
                        childCount: favVerbs.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => VerbCard(verb: favVerbs[index]),
                        childCount: favVerbs.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
