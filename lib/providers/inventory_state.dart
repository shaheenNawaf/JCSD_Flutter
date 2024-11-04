import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/models/inventory_data.dart';
import 'package:jcsd_flutter/services/inventory_service.dart';
// Notes:
//

// Provider for the Inventory System -- One instance for the entire application
final inventoryServiceProd = Provider<InventoryService>((ref){
  return InventoryService();
});

  
