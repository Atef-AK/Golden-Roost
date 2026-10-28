import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/poultry_product.dart';
import '../../providers/product_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/empty_state_view.dart';

class ProductsCatalogueScreen extends ConsumerWidget {
  const ProductsCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(productCategoryFilterProvider);
    final settings = ref.watch(settingsProvider);
    final langCode = settings.language;
    final currency = settings.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {'id': null, 'label': 'All Equipment'},
      {'id': 'incubators', 'label': 'Incubators'},
      {'id': 'brooders', 'label': 'Brooders'},
      {'id': 'candlers', 'label': 'Candlers'},
      {'id': 'drinkers', 'label': 'Drinkers & Feeders'},
      {'id': 'hygrometers', 'label': 'Sensors & Gauges'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('products_title')), elevation: 0),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: Column(
          children: [
            // Mandatory Commercial / Affiliate Disclosure Banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Affiliate Transparency: Golden Roost may earn a commission if you purchase through these links, at no extra cost to you. Equipment is curated for farm suitability.',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Chips
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
                      ref.read(productCategoryFilterProvider.notifier).state =
                          selected ? cat['id'] : null;
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Products Grid / List
            Expanded(
              child: products.isEmpty
                  ? EmptyStateView(
                      icon: Icons.storefront_outlined,
                      title: 'No products found',
                      description: 'No active products in this category yet.',
                    )
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 210,
                              ),
                          itemCount: products.length,
                          itemBuilder: (ctx, index) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              langCode: langCode,
                              currency: currency,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PoultryProduct product;
  final String langCode;
  final String currency;

  const _ProductCard({
    required this.product,
    required this.langCode,
    required this.currency,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.merchantName,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.localizedName(langCode),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              product.localizedDescription(langCode),
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.price > 0
                    ? AppFormatters.formatCurrency(
                        product.price,
                        product.currency,
                      )
                    : 'Check Merchant',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.semanticSuccess,
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.open_in_new, size: 13),
                label: const Text('View Deal', style: TextStyle(fontSize: 11)),
                onPressed: () => _launchUrl(context, product.effectiveUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
