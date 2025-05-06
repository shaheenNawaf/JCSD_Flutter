// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Default Imports for Audit Logs
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Imports for the Backend fetching the Audit Logs
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_state.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_data.dart';

class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends ConsumerState<AuditLogPage> {
  final String _activeSubItem = '/auditLog';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(
                  title: 'Audit Log',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildWebView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
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
        Expanded(
          child: _buildDataTable(context),
        ),
      ],
    );
  }

  //Shimmer Row
  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Item Row
  Widget _buildItemRow(List<AuditData> auditItem, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              auditItem[index].auditUUID,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              auditItem[index].employeeID.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              auditItem[index].actionType,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              auditItem[index].userAction,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  //Header Row
  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Audit UUID',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Employee ID',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Action Type',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'User Action',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final fetchAudit = ref.watch(fetchAuditLog);

    return fetchAudit.when(
        data: (items) {
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
                )
              ],
            ),
            child: Column(
              children: [
                _buildHeaderRow(),
                const Divider(
                    height: 1, color: Color.fromARGB(255, 188, 188, 188)),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemRow(items, index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, stackTrace) =>
            Text('Error fetching data from table: $err'),
        loading: () => Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 207, 233, 255),
              highlightColor: const Color.fromARGB(255, 114, 190, 253),
              child: Column(
                children: [
                  _buildShimmerRow(),
                  const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 188, 188, 188),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildShimmerRow();
                        }),
                  ),
                ],
              ),
            ));
  }

  //TODO : ADD COLORS for "ACTION TYPE"
}
