// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class BorrowedItems extends StatefulWidget {
  const BorrowedItems({super.key});

  @override
  _BorrowedItemsState createState() => _BorrowedItemsState();
}

class _BorrowedItemsState extends State<BorrowedItems> {
  final TextEditingController _quantityController = TextEditingController();

  final List<Map<String, dynamic>> _borrowedItems = [
    {
      'itemID': 1,
      'itemName': 'Item A',
      'itemType': 'Type 1',
      'supplier': 'Supplier X',
      'itemQuantity': 10,
      'itemPrice': 100.0,
    },
    {
      'itemID': 2,
      'itemName': 'Item B',
      'itemType': 'Type 2',
      'supplier': 'Supplier Y',
      'itemQuantity': 5,
      'itemPrice': 200.0,
    },
    {
      'itemID': 3,
      'itemName': 'Item C',
      'itemType': 'Type 3',
      'supplier': 'Supplier Z',
      'itemQuantity': 8,
      'itemPrice': 150.0,
    },
    {
      'itemID': 4,
      'itemName': 'Item D',
      'itemType': 'Type 4',
      'supplier': 'Supplier W',
      'itemQuantity': 12,
      'itemPrice': 250.0,
    },
    {
      'itemID': 5,
      'itemName': 'Item E',
      'itemType': 'Type 5',
      'supplier': 'Supplier V',
      'itemQuantity': 7,
      'itemPrice': 300.0,
    },
    {
      'itemID': 6,
      'itemName': 'Item F',
      'itemType': 'Type 6',
      'supplier': 'Supplier U',
      'itemQuantity': 9,
      'itemPrice': 350.0,
    },
    {
      'itemID': 7,
      'itemName': 'Item G',
      'itemType': 'Type 7',
      'supplier': 'Supplier T',
      'itemQuantity': 15,
      'itemPrice': 400.0,
    },
    {
      'itemID': 8,
      'itemName': 'Item H',
      'itemType': 'Type 8',
      'supplier': 'Supplier S',
      'itemQuantity': 11,
      'itemPrice': 450.0,
    },
    {
      'itemID': 9,
      'itemName': 'Item I',
      'itemType': 'Type 9',
      'supplier': 'Supplier R',
      'itemQuantity': 6,
      'itemPrice': 500.0,
    },
    {
      'itemID': 10,
      'itemName': 'Item J',
      'itemType': 'Type 10',
      'supplier': 'Supplier Q',
      'itemQuantity': 14,
      'itemPrice': 550.0,
    },
    {
      'itemID': 11,
      'itemName': 'Item K',
      'itemType': 'Type 11',
      'supplier': 'Supplier P',
      'itemQuantity': 8,
      'itemPrice': 600.0,
    },
    {
      'itemID': 12,
      'itemName': 'Item L',
      'itemType': 'Type 12',
      'supplier': 'Supplier O',
      'itemQuantity': 10,
      'itemPrice': 650.0,
    },
    {
      'itemID': 13,
      'itemName': 'Item M',
      'itemType': 'Type 13',
      'supplier': 'Supplier N',
      'itemQuantity': 13,
      'itemPrice': 700.0,
    },
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth;
    const double containerHeight = 390;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Borrowed Items',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildDataTable(_borrowedItems)),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(
                    flex: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF00AEEF),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(dynamic items) {
    return Column(
      children: [
        _buildHeaderRow(),
        const Divider(height: 1, color: Color.fromARGB(255, 188, 188, 188)),
        Expanded(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildItemRow(items, index);
              },
            ),
          ),
        ),
      ],
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
              'Item ID',
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
              'Item Name',
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
              'Item Type',
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
              'Supplier',
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
              'Quantity',
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
              'Price',
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

  Widget _buildItemRow(List<Map<String, dynamic>> items, int index) {
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
              items[index]['itemID'].toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              items[index]['itemName'].toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              items[index]['itemType'].toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              items[index]['supplier'].toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${items[index]['itemQuantity'].toString()} pcs',
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'P ${items[index]['itemPrice'].toString()}',
              style: const TextStyle(fontFamily: 'NunitoSans'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 135,
                  child: ElevatedButton(
                    onPressed: () {
                      _showReturnConfirmationDialog(
                          context, items[index]['itemID']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Return Item',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
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

void _showReturnConfirmationDialog(BuildContext context, int itemId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;
      const double containerHeight = 160;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        insetPadding:
            EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
        child: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Confirmation',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Are you sure you want to return this item?',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              color: Color(0xFF00AEEF),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00AEEF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Archive item here
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
