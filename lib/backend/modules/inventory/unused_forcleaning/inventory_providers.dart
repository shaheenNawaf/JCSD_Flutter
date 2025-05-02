// Provider for the Inventory System -- USED FOR THE ENTIRE STATE MANAGEMENT -- DON'T TOUCH
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_name_id.dart';

final inventoryServiceProv = Provider<InventoryService>((ref) {
  return InventoryService();
});

//Entire Provider used for the Notifier
final InventoryNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
  InventoryNotifier,
  InventoryState, 
  bool
>(InventoryNotifier.new);

//Active Items List
final activeInventoryListProvider = FutureProvider.autoDispose<List<ItemNameID>>((ref) async {
  final baseService = ref.watch(inventoryServiceProv);
  return baseService.getActiveItemNamesAndID();
});