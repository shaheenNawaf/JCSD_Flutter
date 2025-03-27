// Provider for the Inventory System -- USED FOR THE ENTIRE STATE MANAGEMENT -- DON'T TOUCH
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';

final inventoryServiceProv = Provider<InventoryService>((ref) {
  return InventoryService();
});

//Fetching items
final inventoryProvider = ChangeNotifierProvider<InventoryNotifier>((ref) {
  final service = ref.read(inventoryServiceProv);
  return InventoryNotifier(service)..fetchInventoryItems();
});

// TY GPT - Just to indicate it's loading, nothing else. Visual lang.
final inventoryLoadingStateProvider = StateProvider<bool>((ref) => false);
