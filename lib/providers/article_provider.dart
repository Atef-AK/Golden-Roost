import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/database/sample_articles.dart';
import '../models/article.dart';

final articlesProvider =
    StateNotifierProvider<ArticlesNotifier, List<Article>>((ref) {
      return ArticlesNotifier();
    });

final articleCategoryFilterProvider = StateProvider<String?>((ref) => null);
final articleSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final articles = ref.watch(articlesProvider);
  final category = ref.watch(articleCategoryFilterProvider);
  final query = ref.watch(articleSearchQueryProvider).toLowerCase().trim();

  return articles.where((article) {
    if (!article.isPublished) return false;
    if (category != null && article.category != category) return false;
    if (query.isNotEmpty) {
      final matchesEn =
          article.titleEn.toLowerCase().contains(query) ||
          article.summaryEn.toLowerCase().contains(query);
      final matchesFr =
          article.titleFr.toLowerCase().contains(query) ||
          article.summaryFr.toLowerCase().contains(query);
      final matchesAr =
          article.titleAr.toLowerCase().contains(query) ||
          article.summaryAr.toLowerCase().contains(query);
      final matchesTag = article.tags.any(
        (t) => t.toLowerCase().contains(query),
      );
      if (!matchesEn && !matchesFr && !matchesAr && !matchesTag) return false;
    }
    return true;
  }).toList();
});

class ArticlesNotifier extends StateNotifier<List<Article>> {
  ArticlesNotifier() : super([]) {
    loadArticles();
  }

  Future<void> loadArticles() async {
    var list = await DatabaseHelper.instance.getArticles();
    if (list.isEmpty) {
      // Seed with curated veterinary educational articles
      for (final article in sampleArticles) {
        await DatabaseHelper.instance.insertArticle(article);
      }
      list = await DatabaseHelper.instance.getArticles();
    }
    state = list;
  }

  Future<void> addArticle(Article article) async {
    await DatabaseHelper.instance.insertArticle(article);
    await loadArticles();
  }

  Future<void> updateArticle(Article article) async {
    await DatabaseHelper.instance.updateArticle(article);
    await loadArticles();
  }

  Future<void> deleteArticle(String id) async {
    await DatabaseHelper.instance.deleteArticle(id);
    await loadArticles();
  }
}
