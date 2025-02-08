// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Packages for Usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Pages
import 'package:jcsd_flutter/view/suppliers/modals/addsupplier.dart';
import 'package:jcsd_flutter/view/suppliers/modals/archivesupplier.dart';
import 'package:jcsd_flutter/view/suppliers/modals/editsupplier.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

// Suppliers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';

class SupplierPage extends ConsumerStatefulWidget {
  const SupplierPage({super.key});

  @override
  ConsumerState createState() => _SupplierPageState();
}

class _SupplierPageState extends ConsumerState<SupplierPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddSupplierModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddSupplierModal();
      },
    );
  }

  _showEditSupplierModal(SuppliersData suppliers, int supplierID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditSupplierModal(
            supplierData: suppliers, supplierID: supplierID);
      },
    );
  }

  _showArchiveSupplierModal(SuppliersData suppliers, int supplierID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ArchiveSupplierModal(
            supplierData: suppliers, supplierID: supplierID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/suppliers'),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suppliers',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                          fontSize: 20,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/avatars/cat2.jpg'),
                      ),
                    ],
                  ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
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
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddSupplierModal,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(context),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final fetchSuppliers = ref.watch(fetchAvailableSuppliers);

    return fetchSuppliers.when(
      data: (suppliers) {
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
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  itemCount: suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildSuppliersRow(suppliers, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (err, stackTrace) => Text('Error fetching data from table: $err'),
      loading: () => const LinearProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 134, 239, 1),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Supplier ID',
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
              'Name',
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
              'Email',
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
              'Contact Number',
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
              'Actions',
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

  Widget _buildSuppliersRow(List<SuppliersData> suppliers, int index) {
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
              suppliers[index].supplierID.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              suppliers[index].supplierName.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              suppliers[index].supplierEmail.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              suppliers[index].contactNumber.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => _showEditSupplierModal(
                        suppliers[index], suppliers[index].supplierID),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => _showArchiveSupplierModal(
                        suppliers[index], suppliers[index].supplierID),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Archive',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                        fontSize: 8,
                      ),
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
}
