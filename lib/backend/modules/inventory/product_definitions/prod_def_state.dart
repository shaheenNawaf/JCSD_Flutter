import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart'; 
import 'package:flutter/foundation.dart';

@immutable
class ProductDefinitionState {
  final List<ProductDefinitionData> productDefinitions;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final String sortBy;
  final bool ascending;

  const ProductDefinitionState({
    this.productDefinitions = const [], // Start with empty list
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1, // Default to 1 page until calculated
    this.itemsPerPage = 10, // Or get from config
    this.sortBy = 'prodDefName', // Default sort by name now? Or prodDefID
    this.ascending = true,
  });

   ProductDefinitionState copyWith({
    List<ProductDefinitionData>? productDefinitions,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
  }) {
    return ProductDefinitionState(
      productDefinitions: productDefinitions ?? this.productDefinitions,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }


  //Data Checking only
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductDefinitionState &&
      listEquals(other.productDefinitions, productDefinitions) &&
      other.searchText == searchText &&
      other.currentPage == currentPage &&
      other.totalPages == totalPages &&
      other.itemsPerPage == itemsPerPage &&
      other.sortBy == sortBy &&
      other.ascending == ascending;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(productDefinitions), // Use Object.hashAll for lists
      searchText,
      currentPage,
      totalPages,
      itemsPerPage,
      sortBy,
      ascending,
    );
  }

    //TY Gemini - mainly for debugging rani and to check if the data has been pushed thru
   @override
   String toString() {
     return 'ProductDefinitionState(productDefinitions: ${productDefinitions.length} items, searchText: $searchText, currentPage: $currentPage, totalPages: $totalPages, itemsPerPage: $itemsPerPage, sortBy: $sortBy, ascending: $ascending)';
   }
}