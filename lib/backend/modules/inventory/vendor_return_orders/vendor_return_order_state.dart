import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';

class VendorReturnOrderState {
  final AsyncValue<List<VendorReturnOrder>> vroList;
  final AsyncValue<VendorReturnOrder?> selectedVRO;
  final AsyncValue<List<SerializedItem>> defectiveSerialsForSelectedPO;

  const VendorReturnOrderState({
    required this.vroList,
    required this.selectedVRO,
    required this.defectiveSerialsForSelectedPO,
  });

  VendorReturnOrderState.initial()
      : vroList = const AsyncValue.loading(),
        selectedVRO = const AsyncValue.data(null),
        defectiveSerialsForSelectedPO = const AsyncValue.data([]);

  VendorReturnOrderState copyWith({
    AsyncValue<List<VendorReturnOrder>>? vroList,
    AsyncValue<VendorReturnOrder?>? selectedVRO,
    AsyncValue<List<SerializedItem>>? defectiveSerialsForSelectedPO,
  }) {
    return VendorReturnOrderState(
      vroList: vroList ?? this.vroList,
      selectedVRO: selectedVRO ?? this.selectedVRO,
      defectiveSerialsForSelectedPO:
          defectiveSerialsForSelectedPO ?? this.defectiveSerialsForSelectedPO,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorReturnOrderState &&
        other.vroList == vroList &&
        other.selectedVRO == selectedVRO &&
        other.defectiveSerialsForSelectedPO == defectiveSerialsForSelectedPO;
  }

  @override
  int get hashCode =>
      Object.hash(vroList, selectedVRO, defectiveSerialsForSelectedPO);
}
