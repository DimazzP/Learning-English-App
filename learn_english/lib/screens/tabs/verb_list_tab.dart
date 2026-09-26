import 'package:flutter/material.dart';
import '../../services/verb_repository.dart';
import '../../widgets/verb_card.dart';

class VerbListTab extends StatefulWidget {
  const VerbListTab({super.key});

  @override
  State<VerbListTab> createState() => _VerbListTabState();
}

class _VerbListTabState extends State<VerbListTab> {
  final TextEditingController _searchController = TextEditingController();
  String _typeFilter = 'all'; // 'all', 'irregular', 'regular'
  String _difficultyFilter = 'all';
  String _languageFilter = 'all'; // 'all', 'en', 'id'

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
        if (repo.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredVerbs = repo.filter(
          query: _searchController.text,
          typeFilter: _typeFilter,
          difficultyFilter: _difficultyFilter,
          languageFilter: _languageFilter,
        );

        final irregularCount = repo.irregularVerbs.length;
        final regularCount = repo.regularVerbs.length;
        final totalCount = repo.allVerbs.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;

            return CustomScrollView(
              slivers: [
                // Top Search & Filter Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: _languageFilter == 'en'
                                ? 'Cari kata kerja Inggris (V1, V2, V3, atau V-ing)...'
                                : (_languageFilter == 'id'
                                    ? 'Cari arti kata kerja dalam Bahasa Indonesia...'
                                    : 'Cari kata kerja (V1, V2, V3, atau Arti dalam BI)...'),
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
                        const SizedBox(height: 12),

                        // Language Target Filter & Type Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Language direction filter
                              _buildFilterChip(
                                label: 'Semua Bahasa',
                                selected: _languageFilter == 'all',
                                onSelected: () => setState(() => _languageFilter = 'all'),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: '🇬🇧 Inggris',
                                selected: _languageFilter == 'en',
                                onSelected: () => setState(() => _languageFilter = 'en'),
                                activeColor: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: '🇮🇩 Indonesia',
                                selected: _languageFilter == 'id',
                                onSelected: () => setState(() => _languageFilter = 'id'),
                                activeColor: Colors.teal,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 24,
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(width: 12),

                              // Filter Chips: All, Irregular, Regular
                              _buildFilterChip(
                                label: 'Semua Jenis ($totalCount)',
                                selected: _typeFilter == 'all',
                                onSelected: () => setState(() => _typeFilter = 'all'),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Irregular ($irregularCount)',
                                selected: _typeFilter == 'irregular',
                                onSelected: () => setState(() => _typeFilter = 'irregular'),
                                activeColor: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Regular ($regularCount)',
                                selected: _typeFilter == 'regular',
                                onSelected: () => setState(() => _typeFilter = 'regular'),
                                activeColor: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              // Difficulty dropdown / filter
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _difficultyFilter,
                                    isDense: true,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('Semua Level')),
                                      DropdownMenuItem(value: 'basic', child: Text('Basic')),
                                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                                      DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _difficultyFilter = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Result count info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredVerbs.length} kata kerja',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty ||
                                _typeFilter != 'all' ||
                                _difficultyFilter != 'all')
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Reset Filter', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _typeFilter = 'all';
                                    _difficultyFilter = 'all';
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Verbs List or Grid
                if (filteredVerbs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada kata kerja yang cocok',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Coba ganti kata kunci atau reset filter pencarian Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isWide)
                  // Multi-column Grid for Web / Wide screens
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
                        (context, index) => VerbCard(verb: filteredVerbs[index]),
                        childCount: filteredVerbs.length,
                      ),
                    ),
                  )
                else
                  // Standard Mobile list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => VerbCard(verb: filteredVerbs[index]),
                        childCount: filteredVerbs.length,
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : null,
      ),
      selectedColor: effectiveColor,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
