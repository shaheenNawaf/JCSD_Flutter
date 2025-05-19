import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the service class
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_services.dart';

/// Provider that creates and exposes an instance of [ProductDefinitionServices].
final productDefinitionServiceProv = Provider<ProductDefinitionServices>((ref) {
  return ProductDefinitionServices(); // Creates a new instance of the service
});

final dashboardLowStockItemsProvider =
    FutureProvider.autoDispose<List<ProductDefinitionData>>((ref) async {
  final productService = ref.watch(productDefinitionServiceProv);

  // Fetch a reasonable number of active products.
  // If you have thousands of products, consider more optimized ways or a dedicated backend endpoint.
  // For a typical dashboard, fetching up to a few hundred and filtering in Dart is often acceptable.
  final allActiveProducts = await productService.fetchProductDefinitions(
    isVisible: true, // Only fetch active products
    itemsPerPage: 200, // Adjust this number based on your total product count
    page: 1,
    // Default sorting is fine, we will sort by "lowness" in Dart
  );

  if (allActiveProducts.isEmpty) {
    return [];
  }

  // Filter for low stock items in Dart
  List<ProductDefinitionData> lowStockItems = allActiveProducts.where((pd) {
    final currentStock = pd.serialsCount ?? 0;
    final desiredStock = pd.desiredStockLevel ?? 0;
    // A product is low on stock if its desired stock is positive AND current stock is below desired
    return desiredStock > 0 && currentStock < desiredStock;
  }).toList();

  // Sort by the "lowness" - for example, by the deficit (desired - current) in descending order
  // This will show items with the largest need first.
  // Alternatively, sort by currentStock ascending.
  lowStockItems.sort((a, b) {
    final deficitA = (a.desiredStockLevel ?? 0) - (a.serialsCount ?? 0);
    final deficitB = (b.desiredStockLevel ?? 0) - (b.serialsCount ?? 0);
    return deficitB.compareTo(deficitA); // Sorts by largest deficit first
    // To sort by smallest current stock first:
    // final stockA = a.serialsCount ?? 0;
    // final stockB = b.serialsCount ?? 0;
    // return stockA.compareTo(stockB);
  });

  // Return the top 5 (or fewer if less than 5 are low)
  return lowStockItems.take(5).toList();
});
