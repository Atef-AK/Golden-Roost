import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../models/article.dart';
import '../../providers/article_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/empty_state_view.dart';
import 'article_detail_screen.dart';

class ArticlesListScreen extends ConsumerWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(filteredArticlesProvider);
    final selectedCategory = ref.watch(articleCategoryFilterProvider);
    final searchController = TextEditingController(
      text: ref.watch(articleSearchQueryProvider),
    );
    final settings = ref.watch(settingsProvider);
    final langCode = settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {'id': null, 'label': 'All Categories'},
      {'id': 'health', 'label': 'Health & Vaccines'},
      {'id': 'brooding', 'label': 'Brooding'},
      {'id': 'nutrition', 'label': 'Nutrition & Eggs'},
      {'id': 'biosecurity', 'label': 'Biosecurity'},
      {'id': 'quail', 'label': 'Quail Care'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('articles_title')), elevation: 0),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: Column(
          children: [
            // Search & Category Ribbon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: context.tr('articles_search'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            ref
                                    .read(articleSearchQueryProvider.notifier)
                                    .state =
                                '';
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  ref.read(articleSearchQueryProvider.notifier).state = val;
                },
              ),
            ),

            // Horizontal Category Filter Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat['id'];
                  return ChoiceChip(
                    label: Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryTeal,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      ref.read(articleCategoryFilterProvider.notifier).state =
                          selected ? cat['id'] : null;
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Offline Caching Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.offline_pin_outlined,
                    size: 14,
                    color: AppColors.semanticSuccess,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stored locally for offline farm access',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Articles List with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(articlesProvider.notifier).syncRemoteArticles(),
                child: articles.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 60),
                          EmptyStateView(
                            icon: Icons.menu_book_outlined,
                            title: 'No articles found',
                            description:
                                'Try adjusting your search query or category filter.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: articles.length,
                        itemBuilder: (ctx, index) {
                          final article = articles[index];
                          return _ArticleCard(
                            article: article,
                            langCode: langCode,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ArticleDetailScreen(article: article),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final String langCode;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${article.readingTimeMinutes} min read',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              article.localizedTitle(langCode),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article.localizedSummary(langCode),
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 13,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Reviewed by ${article.reviewer}',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: AppColors.primaryTeal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
