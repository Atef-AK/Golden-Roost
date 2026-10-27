import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<void> syncRemoteArticles({
    String baseUrl = 'https://goldenroost.com',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/articles');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          for (final item in data['data']) {
            final translations = (item['translations'] as List?) ?? [];
            String titleEn = '';
            String titleFr = '';
            String titleAr = '';
            String summaryEn = '';
            String summaryFr = '';
            String summaryAr = '';
            String bodyEn = item['content'] ?? '';
            String bodyFr = '';
            String bodyAr = '';

            for (final t in translations) {
              if (t['locale'] == 'en') {
                titleEn = t['title'] ?? '';
                summaryEn = t['summary'] ?? '';
                if (t['content'] != null && (t['content'] as String).isNotEmpty) {
                  bodyEn = t['content'];
                }
              } else if (t['locale'] == 'fr') {
                titleFr = t['title'] ?? '';
                summaryFr = t['summary'] ?? '';
                bodyFr = t['content'] ?? '';
              } else if (t['locale'] == 'ar') {
                titleAr = t['title'] ?? '';
                summaryAr = t['summary'] ?? '';
                bodyAr = t['content'] ?? '';
              }
            }

            final article = Article(
              id: item['id'] ?? item['slug'],
              slug: item['slug'] ?? '',
              titleEn: titleEn.isNotEmpty ? titleEn : (item['title'] ?? ''),
              titleFr: titleFr,
              titleAr: titleAr,
              summaryEn: summaryEn.isNotEmpty ? summaryEn : (item['summary'] ?? ''),
              summaryFr: summaryFr,
              summaryAr: summaryAr,
              bodyEn: bodyEn,
              bodyFr: bodyFr,
              bodyAr: bodyAr,
              category: item['category'] ?? 'health',
              imageUrl: item['featuredImageUrl'] ?? '',
              isPublished: item['isPublished'] ?? true,
              publishedAt:
                  DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
            );

            await DatabaseHelper.instance.insertArticle(article);
          }
          await loadArticles();
        }
      }
    } catch (_) {
      // Offline fallback: Keep existing offline articles untouched
    }
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
