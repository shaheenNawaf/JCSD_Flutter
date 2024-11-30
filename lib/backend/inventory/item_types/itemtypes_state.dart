import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/models/itemtypes_data.dart';
import 'package:jcsd_flutter/backend/services/itemtypes_service.dart';

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

//Adding an Item Type

//Updating an Item Type