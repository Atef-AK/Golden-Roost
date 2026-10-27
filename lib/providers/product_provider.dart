import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/database/sample_products.dart';
import '../models/poultry_product.dart';

final poultryProductsProvider =
    StateNotifierProvider<PoultryProductsNotifier, List<PoultryProduct>>((ref) {
      return PoultryProductsNotifier();
    });

final productCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider = Provider<List<PoultryProduct>>((ref) {
  final products = ref.watch(poultryProductsProvider);
  final category = ref.watch(productCategoryFilterProvider);

  return products.where((product) {
    if (!product.isActive) return false;
    if (category != null && product.category != category) return false;
    return true;
  }).toList();
});

class PoultryProductsNotifier extends StateNotifier<List<PoultryProduct>> {
  PoultryProductsNotifier() : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    var list = await DatabaseHelper.instance.getPoultryProducts();
    if (list.isEmpty) {
      // Seed with curated initial poultry products
      for (final product in samplePoultryProducts) {
        await DatabaseHelper.instance.insertPoultryProduct(product);
      }
      list = await DatabaseHelper.instance.getPoultryProducts();
    }
    state = list;
  }

  Future<void> addProduct(PoultryProduct product) async {
    await DatabaseHelper.instance.insertPoultryProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(PoultryProduct product) async {
    await DatabaseHelper.instance.updatePoultryProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await DatabaseHelper.instance.deletePoultryProduct(id);
    await loadProducts();
  }
}
