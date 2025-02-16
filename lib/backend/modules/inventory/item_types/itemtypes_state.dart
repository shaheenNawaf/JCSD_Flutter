// Base Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';

//Base Provider - One instance of the entire itemTypes service
final itemTypesProvider = Provider<ItemtypesService>((ref){
  return ItemtypesService();
});

//Fetch all Items
final fetchItemTypesList = FutureProvider<List<ItemTypesData>>((ref) async {
  final baseTypes = ref.read(itemTypesProvider);

  List<ItemTypesData> allItemTypes = await baseTypes.displayAllItemTypes();
  return allItemTypes;
});

//Fetching Active Item Types
final fetchActiveTypes = FutureProvider<List<ItemTypesData>>((ref) async {
  final baseTypes = ref.read(itemTypesProvider);

  List<ItemTypesData> allItemTypes = await baseTypes.activeItemTypes();
  return allItemTypes;
});

//Fetching Archived Item Types
final fetchArchivedTypes = FutureProvider<List<ItemTypesData>>((ref) async {
  final baseTypes = ref.read(itemTypesProvider);

  List<ItemTypesData> allItemTypes = await baseTypes.archivedItemTypes();
  return allItemTypes;
});