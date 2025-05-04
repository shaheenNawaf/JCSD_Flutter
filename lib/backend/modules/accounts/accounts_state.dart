import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

class AccountsState {
  final List<AccountsData> accounts;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;
  final String sortBy;
  final bool ascending;

  AccountsState({
    required this.accounts,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
    required this.sortBy,
    required this.ascending,
  });

  factory AccountsState.initial() => AccountsState(
        accounts: [],
        currentPage: 1,
        itemsPerPage: 10,
        totalItems: 0,
        totalPages: 0,
        searchQuery: '',
        sortBy: 'email',
        ascending: true,
      );

  AccountsState copyWith({
    List<AccountsData>? accounts,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
  }) {
    return AccountsState(
      accounts: accounts ?? this.accounts,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}
