import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Default Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vro_enums.dart';

import '../../../../backend/modules/accounts/account_notifier.dart'; // For userProvider

//Backend Imports
//Suppliers Data and Providers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';

//VRO
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';
import '../../../../backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';

//Generic
import 'package:jcsd_flutter/widgets/header.dart';

//Inventory
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/create_vro_modal.dart';
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/view_vro_modal.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

class CreateBasicVROModal extends ConsumerStatefulWidget {
  final PurchaseOrderData originalPurchaseOrder;
  final PurchaseOrderItemData purchaseOrderItemToReturn;
  final String serialNumberOfItemToReturn;

  const CreateBasicVROModal({
    super.key,
    required this.originalPurchaseOrder,
    required this.purchaseOrderItemToReturn,
    required this.serialNumberOfItemToReturn,
  });

  @override
  ConsumerState<CreateBasicVROModal> createState() =>
      _CreateBasicVROModalState();
}

class _CreateBasicVROModalState extends ConsumerState<CreateBasicVROModal> {
  final _formKey = GlobalKey<FormState>();
  late BasicVROFormParams _formArgs;

  @override
  void initState() {
    super.initState();
    _formArgs = BasicVROFormParams(
      originalPurchaseOrder: widget.originalPurchaseOrder,
      purchaseOrderItemToReturn: widget.purchaseOrderItemToReturn,
      serialNumberOfItemToReturn: widget.serialNumberOfItemToReturn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(basicVroFormNotifierProvider(_formArgs).notifier);
    final state = ref.watch(basicVroFormNotifierProvider(_formArgs));

    return AlertDialog(
      title: const Text('Process Item Return'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${widget.purchaseOrderItemToReturn.prodDefID}'),
              Text('Serial to Return: ${widget.serialNumberOfItemToReturn}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Reason for Return',
                    border: OutlineInputBorder()),
                value: state.reasonForReturn,
                items: kBasicReturnReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => notifier.setReason(val!),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Reason is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BasicReturnAction>(
                decoration: const InputDecoration(
                    labelText: 'Action / Status', border: OutlineInputBorder()),
                value: state.returnAction,
                items: BasicReturnAction.values
                    .map((act) =>
                        DropdownMenuItem(value: act, child: Text(act.name)))
                    .toList(),
                onChanged: (val) => notifier.setAction(val!),
                validator: (val) => val == null ? 'Action is required' : null,
              ),
              const SizedBox(height: 16),
              if (state.returnAction == BasicReturnAction.UpgradeReceived)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Select Upgraded Product',
                      border: OutlineInputBorder()),
                  value: state.selectedUpgradeProductId,
                  items: state.availableProductsForUpgrade
                      .map((p) => DropdownMenuItem(
                          value: p.prodDefID, child: Text(p.prodDefName)))
                      .toList(),
                  onChanged: (val) => notifier.setSelectedUpgradeProductId(val),
                  validator: (val) =>
                      state.returnAction == BasicReturnAction.UpgradeReceived &&
                              (val == null || val.isEmpty)
                          ? 'Product is required for upgrade'
                          : null,
                ),
              if (state.returnAction == BasicReturnAction.UpgradeReceived)
                const SizedBox(height: 16),
              if (state.returnAction == BasicReturnAction.ReplacementReceived ||
                  state.returnAction == BasicReturnAction.UpgradeReceived)
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'New Received Serial Number',
                      border: OutlineInputBorder()),
                  initialValue: state.newReceivedSerialNumber,
                  onChanged: (val) => notifier.setNewReceivedSerial(val),
                  validator: (val) => (state.returnAction ==
                                  BasicReturnAction.ReplacementReceived ||
                              state.returnAction ==
                                  BasicReturnAction.UpgradeReceived) &&
                          (val == null || val.isEmpty)
                      ? 'New serial is required'
                      : null,
                ),
              if (state.returnAction == BasicReturnAction.ReplacementReceived ||
                  state.returnAction == BasicReturnAction.UpgradeReceived)
                const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder()),
                initialValue: state.notes,
                onChanged: (val) => notifier.setNotes(val),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await notifier.submitBasicReturn();
                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Return processed successfully!'),
                            backgroundColor: Colors.green,
                          ));
                          Navigator.of(context).pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.errorMessage ??
                                'Failed to process return.'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    }
                  },
                  child: const Text('Submit Return'),
                ),
              if (state.errorMessage != null && !state.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(state.errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'))
      ],
    );
  }
}
