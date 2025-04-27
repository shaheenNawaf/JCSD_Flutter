import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the service class
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_services.dart';

/// Provider that creates and exposes an instance of [ProductDefinitionServices].
final productDefinitionServiceProv = Provider<ProductDefinitionServices>((ref) {
  return ProductDefinitionServices(); // Creates a new instance of the service
});

