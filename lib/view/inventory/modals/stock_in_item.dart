// stock_in_item.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Base Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_name_id.dart';
import 'package:jcsd_flutter/view/generic/dialogs/generic_dialog.dart';


class StockInItemModal extends ConsumerStatefulWidget {
  const StockInItemModal({super.key});

  @override
  ConsumerState<StockInItemModal> createState() => _StockInItemModalState();
}

class _StockInItemModalState extends ConsumerState<StockInItemModal> {
  int? _selectedItemId;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _stockInItem() async {
    if (!_formKey.currentState!.validate()) {
      showCustomNotificationDialog(
          context: context,
          headerBar: 'Invalid Input',
          messageText: 'Please select an item and enter a valid quantity.');
      return;
    }

    final int quantityToAdd = int.parse(_quantityController.text);

    setState(() => _isSaving = true);

    try {
      const bool isVisibleContext = true;
      await ref.read(InventoryNotifierProvider(isVisibleContext).notifier)
               .stockInItem(_selectedItemId!, quantityToAdd);

      // Optional: Audit Log Call

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock added successfully!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Error adding stock for item $_selectedItemId: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add stock: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 400 ? 450 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Center(
                  child: Text('Stock In Item', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildItemListDropdown(),
                      const SizedBox(height: 16),
                      _buildQuantityField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Color(0xFF00AEEF))),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Color(0xFF00AEEF))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _stockInItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Submit', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemListDropdown() {
    final activeItemsAsyncValue = ref.watch(activeInventoryListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text(
            "Item to Stock In"
          ),
          Text(
            '*', 
            style: TextStyle(
              color: Colors.red
              )
            )
          ]
        ),
        const SizedBox(height: 5),
        activeItemsAsyncValue.when(
          data: (itemList) {
            final isValidSelection = _selectedItemId != null && itemList.any((item) => item.itemID == _selectedItemId);
            final currentValue = isValidSelection ? _selectedItemId : null;

            return DropdownButtonFormField<int>(
              value: currentValue,
              hint: const Text("Select an item", style: TextStyle(fontSize: 12, color: Colors.grey)),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              isExpanded: true,
              items: itemList.map((item) => DropdownMenuItem<int>(
                    value: item.itemID,
                    child: Text(item.itemName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                 )).toList(),
              onChanged: (int? newValue) => setState(() => _selectedItemId = newValue),
              selectedItemBuilder: (BuildContext context) => itemList.map<Widget>((ItemNameID item) => Row(
                 children: [
                    Expanded(child: Text(item.itemName, overflow: TextOverflow.ellipsis)),
                    if (_selectedItemId == item.itemID) const Icon(Icons.check, color: Colors.green, size: 20),
                 ],
              )).toList(),
              validator: (value) => value == null ? 'Please select an item' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            );
          },
          loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          error: (error, stack) => Text('Error loading items: ${error.toString()}', style: const TextStyle(color: Colors.red, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [Text('Quantity to Add'), Text('*', style: TextStyle(color: Colors.red)) ]),
        const SizedBox(height: 5),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Enter quantity',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: TextStyle(fontSize: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Quantity is required';
            final int? quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) return 'Enter a positive number';
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}