// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_state.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

final accountWithPositionProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final accountsService = ref.read(accountServiceProvider);
  final employeeList = await ref.watch(fetchAllEmployeesProvider.future);
  final accounts = await accountsService.fetchAccounts();

  return accounts.map((account) {
    final matchingEmployee = employeeList.where(
      (emp) => emp.userID == account.userID,
    );

    if (matchingEmployee.isEmpty) {
      return {
        'account': account,
        'position': 'Client',
      };
    }

    final employee = matchingEmployee.first;
    final position = employee.isAdmin ? 'Admin' : 'Employee';

    return {
      'account': account,
      'position': position,
    };
  }).toList();
});

class AccountListPage extends ConsumerStatefulWidget {
  const AccountListPage({super.key});

  @override
  ConsumerState<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends ConsumerState<AccountListPage> {
  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 350,
                            height: 40,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFABABAB),
                                  fontFamily: 'NunitoSans',
                                ),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildDataTable()),
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

  Widget _buildDataTable() {
    final accountAsync = ref.watch(accountWithPositionProvider);

    return accountAsync.when(
      data: (users) => _buildUserTable(users),
      loading: () => _buildShimmer(),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildUserTable(List<Map<String, dynamic>> users) {
    return Container(
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
      child: ListView(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
            columns: [
              DataColumn(label: _buildHeaderText('Name')),
              DataColumn(label: _buildHeaderText('Position')),
              DataColumn(label: _buildHeaderText('Contact Info')),
              DataColumn(label: _buildHeaderText('Action', center: true)),
            ],
            rows: users.map((map) => _buildDataRow(map)).toList(),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> data) {
    final user = data['account'] as AccountsData;
    final position = data['position'] as String;

    String safe(String? value) =>
        (value == null || value.trim().isEmpty) ? 'N/A' : value;

    return DataRow(
      cells: [
        DataCell(Text(
          '${safe(user.firstName)} ${safe(user.middleName)}. ${safe(user.lastname)}',
          style: const TextStyle(fontFamily: 'NunitoSans'),
        )),
        DataCell(Text(
          position,
          style: const TextStyle(fontFamily: 'NunitoSans'),
        )),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              safe(user.email),
              style: const TextStyle(fontFamily: 'NunitoSans'),
            ),
            Text(
              safe(user.contactNumber),
              style: const TextStyle(fontFamily: 'NunitoSans'),
            ),
          ],
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
      ],
    );
  }

  static Widget _buildHeaderText(String text, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 207, 233, 255),
      highlightColor: const Color.fromARGB(255, 114, 190, 253),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}
