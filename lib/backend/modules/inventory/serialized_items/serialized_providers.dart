import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import service, state, notifier, and data model
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
// No need to import SerializedItem data model here if only used in state/notifier

/// Provider that creates and exposes an instance of [SerialitemService].
final serialitemServiceProvider = Provider<SerialitemService>((ref) {
  return SerialitemService(); // Creates a new instance of the service
});

/// Notifier provider for managing Serialized Items for a specific Product Definition.
/// Family param String: The prodDefID (UUID) of the Product Definition.
final serializedItemNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
    SerializedItemNotifier, SerializedItemState, String>(
  () => SerializedItemNotifier(),
);

/// FutureProvider specifically for fetching all available item statuses for dropdowns.
final allItemStatusesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  // Reads the service provider to access the service method
  final service = ref.watch(serialitemServiceProvider);
  return service.getAllItemStatuses(); // Calls the method added in Step 1
});