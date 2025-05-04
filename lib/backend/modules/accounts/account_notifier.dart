import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'accounts_state.dart';

class AccountNotifier extends StateNotifier<AccountsState> {
  final AccountService service;

  AccountNotifier(this.service) : super(AccountsState.initial()) {
    _fetchTotalCount();
    _fetchPageData();
  }

  void _fetchTotalCount() async {
    final count = await service.getTotalAccountsCount();
    state = state.copyWith(
        totalItems: count, totalPages: (count / state.itemsPerPage).ceil());
  }

  void _fetchPageData() async {
    final items = await service.fetchAccounts(
      page: state.currentPage,
      limit: state.itemsPerPage,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );
    state = state.copyWith(accounts: items);
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchPageData();
  }

  void sort(String column) {
    final isSameColumn = state.sortBy == column;
    final ascending = isSameColumn ? !state.ascending : true;
    state =
        state.copyWith(sortBy: column, ascending: ascending, currentPage: 1);
    _fetchPageData();
  }
}
