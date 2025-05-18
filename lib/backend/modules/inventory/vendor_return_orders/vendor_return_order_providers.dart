import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_service.dart';

final vendorReturnOrderServiceProvider =
    Provider<VendorReturnOrderService>((ref) {
  return VendorReturnOrderService();
});

final vendorReturnOrderNotifierProvider =
    AsyncNotifierProvider<VendorReturnOrderNotifier, VendorReturnOrderState>(
        () {
  return VendorReturnOrderNotifier();
});

final vroListProvider = Provider<AsyncValue<List<VendorReturnOrder>>>((ref) {
  return ref.watch(vendorReturnOrderNotifierProvider.select((asyncState) {
    return asyncState.when(
      data: (vroState) => vroState.vroList,
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    );
  }));
});

final selectedVROProvider = Provider<AsyncValue<VendorReturnOrder?>>((ref) {
  return ref.watch(vendorReturnOrderNotifierProvider.select((asyncState) {
    return asyncState.when(
      data: (vroState) => vroState.selectedVRO,
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    );
  }));
});

final defectiveSerialsForSelectedPOProvider =
    Provider<AsyncValue<List<SerializedItem>>>((ref) {
  return ref.watch(vendorReturnOrderNotifierProvider.select((asyncState) {
    return asyncState.when(
      data: (vroState) => vroState.defectiveSerialsForSelectedPO,
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    );
  }));
});
