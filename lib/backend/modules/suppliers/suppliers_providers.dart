import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';

// Provider for the SuppliersService
final suppliersServiceProvider = Provider<SuppliersService>((ref) {
  return SuppliersService();
});

// Provider to fetch all active suppliers for dropdowns
final activeSuppliersForDropdownProvider =
    FutureProvider<List<SuppliersData>>((ref) async {
  final suppliersService = ref.watch(suppliersServiceProvider);
  return suppliersService.getAllSuppliersForSelect(activeOnly: true);
});
