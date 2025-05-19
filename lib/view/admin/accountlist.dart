import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/accounts/account_notifier.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_state.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AccountsState>(
  (ref) => AccountNotifier(AccountService()),
);

class AccountListPage extends ConsumerStatefulWidget {
  const AccountListPage({super.key});

  @override
  ConsumerState<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends ConsumerState<AccountListPage> {
  String _searchText = '';

  List<AccountsData> _applyFilters(List<AccountsData> data) {
    if (_searchText.trim().isEmpty) return data;
    final query = _searchText.toLowerCase();
    return data.where((user) {
      final name =
          '${user.firstName ?? ''} ${user.middleName ?? ''} ${user.lastname ?? ''}'
              .toLowerCase();
      final email = (user.email ?? '').toLowerCase();
      final city = (user.city ?? '').toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          city.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    final notifier = ref.read(accountNotifierProvider.notifier);

    final filteredAccounts = _applyFilters(state.accounts);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/accountList'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Account List'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 350,
                            height: 40,
                            child: TextField(
                              controller:
                                  TextEditingController(text: _searchText)
                                    ..selection = TextSelection.collapsed(
                                        offset: _searchText.length),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFABABAB),
                                  fontFamily: 'NunitoSans',
                                ),
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchText.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchText = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildDataTable(
                              filteredAccounts, notifier, state),
                        ),
                        const SizedBox(height: 8),
                        _buildPagination(state, notifier),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
      List<AccountsData> users, AccountNotifier notifier, AccountsState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
          columnSpacing: 24,
          columns: [
            DataColumn(
                label:
                    _buildSortableHeader('Name', 'firstName', notifier, state)),
            DataColumn(
                label: _buildSortableHeader('Email', 'email', notifier, state)),
            DataColumn(
                label: _buildSortableHeader('City', 'city', notifier, state)),
            DataColumn(label: _buildHeaderText('Action', center: true)),
          ],
          rows: users.map((user) {
            return DataRow(cells: [
              DataCell(Text(
                _safe('${user.firstName} ${user.middleName} ${user.lastname}'),
                style: const TextStyle(fontFamily: 'NunitoSans'),
              )),
              DataCell(Text(
                _safe(user.email),
                style: const TextStyle(fontFamily: 'NunitoSans'),
              )),
              DataCell(Text(
                _safe(user.city),
                style: const TextStyle(fontFamily: 'NunitoSans'),
              )),
              DataCell(
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/accountList/accountDetail', extra: user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableHeader(String title, String column,
      AccountNotifier notifier, AccountsState state) {
    return InkWell(
      onTap: () => notifier.sort(column),
      child: Row(
        children: [
          _buildHeaderText(title),
          if (state.sortBy == column)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: center ? TextAlign.center : TextAlign.start,
      ),
    );
  }

  Widget _buildPagination(AccountsState state, AccountNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: state.currentPage > 1 ? () => notifier.goToPage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: state.currentPage > 1
              ? () => notifier.goToPage(state.currentPage - 1)
              : null,
        ),
        Text('Page ${state.currentPage} of ${state.totalPages}'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.totalPages)
              : null,
        ),
      ],
    );
  }

  String _safe(String? val) =>
      (val == null || val.trim().isEmpty) ? 'N/A' : val;
}
