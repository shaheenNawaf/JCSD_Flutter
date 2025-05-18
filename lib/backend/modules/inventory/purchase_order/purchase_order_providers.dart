//Default Imports
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

//Backend Imports
//Purchase Sub-System
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/purchase_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/services/purchase_order_service.dart';

//Serialized Items
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService();
});

final serialItemServiceProviderForPO = Provider<SerialitemService>((ref) {
  return SerialitemService();
});

// Notifier Provider
final purchaseOrderListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PurchaseOrderListNotifier, PurchaseOrderListState>(
  () => PurchaseOrderListNotifier(),
);
