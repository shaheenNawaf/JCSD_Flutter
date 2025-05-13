import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import service, state, and notifier
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_notifiers.dart';

import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart'; // For dropdown provider type

/// Provider that creates and exposes an instance of [ManufacturersService].
final manufacturersServiceProvider = Provider<ManufacturersService>((ref) {
  return ManufacturersService();
});

/// Notifier provider for managing Manufacturers (Active/Archived).
/// Family param bool: true=Active, false=Archived.
final manufacturersNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
    ManufacturersNotifier, ManufacturersState, bool>(
  () => ManufacturersNotifier(),
);

final activeManufacturersForDropdownProvider =
    FutureProvider.autoDispose<List<ManufacturersData>>((ref) async {
  final service = ref.watch(manufacturersServiceProvider);
  return service.getAllManufacturersForSelect(activeOnly: true);
});
