// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

//Backend Imports
//Bookings
import 'package:jcsd_flutter/view/bookings/modals/receipt.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart'; //Enums for the Status and Static types
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/view/bookings/modals/edit_booking_detail.dart';

//Accounts & Employees
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart'; // Account Data (Where we're going to get the Employee Name, and Customer deets)
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart'; // Employee List

//Booking
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_service_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';

//Inventory
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart'; // Product Def Names

//Services
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart'; // For service names

//Modals
import 'package:jcsd_flutter/modals/remove_item_list.dart';
import 'package:jcsd_flutter/modals/add_item_list.dart'; // Serialized version

//Generic UI Imports
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/api/global_variables.dart'; // For current user ID
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class BookingDetailsPage extends ConsumerWidget {
  final int? bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  final String _activeSubItem = '/bookings'; // For sidebar active state

  // --- Modal Launchers ---
  void _showEditBookingModal(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditBookingModal(booking: booking),
    );
  }

  void _showAddItemListModal(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddItemListModal(bookingId: bookingId),
    );
  }

  void _showRemoveItemModal(
      BuildContext context, int bookingId, BookingItem item) {
    // Assuming BookingItem has a name or serial for display
    String itemNameForDisplay =
        item.serialNumber; // Or fetch product name if available
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RemoveItemModal(
        bookingId: bookingId,
        bookingItemId: item.id,
        itemName: itemNameForDisplay,
      ),
    );
  }

  void _showReceiptModal(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: true, // Receipt can be dismissed
      builder: (_) => ReceiptModal(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDetailAsync =
        ref.watch(bookingDetailNotifierProvider(bookingId!));
    final currentUserRole =
        ref.watch(userRoleProvider); // Watch current user's role

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Booking Details',
                  leading: IconButton(
                    // Add a back button
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context
                            .go('/bookings'); // Fallback if no previous route
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: bookingDetailAsync.when(
                      data: (booking) {
                        if (booking == null) {
                          return const Center(
                              child: Text('Booking not found.'));
                        }
                        // Pass the role to the main view builder
                        return _buildBookingDetailView(context, ref, booking,
                            currentUserRole.asData?.value);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading booking: $err'),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(
                                  bookingDetailNotifierProvider(bookingId!)),
                              child: const Text('Retry'),
                            )
                          ],
                        ),
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

  Widget _buildBookingDetailView(
      BuildContext context, WidgetRef ref, Booking booking, String? userRole) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 700; // Adjust breakpoint as needed

    // Fetch service names for display
    final allServicesAsync = ref.watch(fetchAvailableServices);
    final serviceNameMap = allServicesAsync.asData?.value
            .fold<Map<int, String>>(
                {},
                (map, service) =>
                    map..[service.serviceID] = service.serviceName) ??
        {};

    // Fetch product names for display
    final productDefinitionsState =
        ref.watch(productDefinitionNotifierProvider(true)).asData?.value;
    final productNameMap = productDefinitionsState?.productDefinitions
            .fold<Map<String?, String>>(
                {}, (map, pd) => map..[pd.prodDefID] = pd.prodDefName) ??
        {};

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile) {
          // --- Mobile Layout: Single column scroll view ---
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildBookingInfoCard(context, booking, userRole, ref),
                const SizedBox(height: 16),
                _buildServicesCard(
                    context, booking, serviceNameMap, userRole, ref),
                const SizedBox(height: 16),
                _buildItemsCard(
                    context, booking, productNameMap, userRole, ref),
                const SizedBox(height: 16),
                _buildNotesCard(context, booking, userRole, ref),
                const SizedBox(height: 16),
                _buildPricingAndActionsCard(context, booking, userRole, ref),
              ],
            ),
          );
        } else {
          // --- Desktop Layout: Two columns ---
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2, // Left column for details
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      _buildBookingInfoCard(context, booking, userRole, ref),
                      const SizedBox(height: 16),
                      _buildServicesCard(
                          context, booking, serviceNameMap, userRole, ref),
                      const SizedBox(height: 16),
                      _buildItemsCard(
                          context, booking, productNameMap, userRole, ref),
                      const SizedBox(height: 16),
                      _buildNotesCard(context, booking, userRole, ref),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1, // Right column for pricing and actions
                child: _buildPricingAndActionsCard(
                    context, booking, userRole, ref),
              ),
            ],
          );
        }
      },
    );
  }

  // --- Reusable Card Widgets ---
  Widget _buildCard(
      {required String title, required Widget child, List<Widget>? actions}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NunitoSans')),
                if (actions != null)
                  Row(mainAxisSize: MainAxisSize.min, children: actions)
              ],
            ),
            const Divider(height: 20, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'NunitoSans'))),
          Expanded(
              child: valueWidget ??
                  Text(value ?? 'N/A',
                      style: const TextStyle(fontFamily: 'NunitoSans'))),
        ],
      ),
    );
  }

  // Details Sections

  //booking card here
  Widget _buildBookingInfoCard(
      BuildContext context, Booking booking, String? userRole, WidgetRef ref) {
    String customerName = booking.walkInCustomerName ?? "N/A";
    if (customerName == "N/A" && booking.customerUserId != null) {
      // TODO: Fetch customer name by customerUserId if needed for display
      customerName = "User ID: ${booking.customerUserId!.substring(0, 8)}...";
    }
    String assignedEmployeeNames = booking.bookingAssignments?.map((a) {
          // TODO: Fetch employee name by a.employeeId
          return 'Emp. ID: ${a.employeeId}';
        }).join(', ') ??
        'Not Assigned';

    return _buildCard(
      title: 'Booking Overview',
      actions: [
        if (userRole == 'admin' ||
            userRole == 'employee') // Condition for showing edit button
          IconButton(
            icon: const Icon(Icons.edit_note, color: Color(0xFF00AEEF)),
            tooltip: 'Edit Status/Assignment',
            onPressed: () => _showEditBookingModal(context, booking),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Booking ID', booking.id.toString()),
          _buildInfoRow('Customer', customerName),
          _buildInfoRow('Scheduled',
              DateFormat.yMMMEd().add_jm().format(booking.scheduledStartTime)),
          _buildInfoRow(
              'Booking Type',
              booking.bookingType.name
                  .replaceAllMapped(
                      RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                  .trim()),
          _buildInfoRow('Status', null,
              valueWidget: _statusChip(booking.status)),
          _buildInfoRow('Assigned To', assignedEmployeeNames),
          if (booking.actualStartTime != null)
            _buildInfoRow('Service Started',
                DateFormat.yMMMEd().add_jm().format(booking.actualStartTime!)),
          if (booking.actualEndTime != null)
            _buildInfoRow('Service Ended',
                DateFormat.yMMMEd().add_jm().format(booking.actualEndTime!)),
        ],
      ),
    );
  }

  //Services for the Bookings
  Widget _buildServicesCard(BuildContext context, Booking booking,
      Map<int, String> serviceNameMap, String? userRole, WidgetRef ref) {
    // Determine if price update is allowed (e.g., admin or employee before final approval)
    bool canUpdatePrice = (userRole == 'admin' || userRole == 'employee') &&
        (booking.status == BookingStatus.inProgress ||
            booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.pendingCustomerResponse ||
            booking.status == BookingStatus.pendingParts);

    return _buildCard(
      title: 'Services Availed',
      child: (booking.bookingServices?.isEmpty ?? true)
          ? const Text('No services selected for this booking.',
              style: TextStyle(fontFamily: 'NunitoSans'))
          : Column(
              children: booking.bookingServices!.map((serviceItem) {
                String serviceName = serviceNameMap[serviceItem.serviceId] ??
                    'Service ID: ${serviceItem.serviceId}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(serviceName,
                      style: const TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      'Est. Price: ₱${serviceItem.estimatedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontFamily: 'NunitoSans')),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          'Final: ₱${(serviceItem.finalPrice ?? serviceItem.estimatedPrice).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.bold)),
                      if (canUpdatePrice)
                        SizedBox(
                          height: 28,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8)),
                            child: const Text('Update Price',
                                style: TextStyle(fontSize: 12)),
                            onPressed: () async {
                              final newPriceString =
                                  await _showUpdatePriceDialog(
                                      context,
                                      serviceName,
                                      serviceItem.finalPrice ??
                                          serviceItem.estimatedPrice);
                              if (newPriceString != null) {
                                final newPrice =
                                    double.tryParse(newPriceString);
                                if (newPrice != null && newPrice >= 0) {
                                  try {
                                    await ref
                                        .read(bookingDetailNotifierProvider(
                                                booking.id)
                                            .notifier)
                                        .updateServicePrice(
                                            serviceItem.id, newPrice);
                                    ToastManager().showToast(
                                        context,
                                        "Price updated for $serviceName",
                                        Colors.green);
                                  } catch (e) {
                                    ToastManager().showToast(
                                        context,
                                        "Failed to update price: $e",
                                        Colors.red);
                                  }
                                } else {
                                  ToastManager().showToast(context,
                                      "Invalid price entered.", Colors.orange);
                                }
                              }
                            },
                          ),
                        )
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildItemsCard(BuildContext context, Booking booking,
      Map<String?, String> productNameMap, String? userRole, WidgetRef ref) {
    bool canAddRemoveItems = (userRole == 'admin' || userRole == 'employee') &&
        (booking.status == BookingStatus.inProgress ||
            booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.pendingCustomerResponse ||
            booking.status == BookingStatus.pendingParts);
    return _buildCard(
      title: 'Items Used/Sold',
      actions: [
        if (canAddRemoveItems)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            tooltip: 'Add Item',
            onPressed: () => _showAddItemListModal(context, booking.id),
          ),
      ],
      child: (booking.bookingItems?.isEmpty ?? true)
          ? const Text('No items added to this booking yet.',
              style: TextStyle(fontFamily: 'NunitoSans'))
          : Column(
              children: booking.bookingItems!.map((item) {
                String itemName = (item.serialNumber != null
                        ? productNameMap[item.serialNumber]
                        : null) ??
                    'SN: ${item.serialNumber}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(itemName,
                      style: const TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w500)),
                  subtitle: Text('Serial: ${item.serialNumber}',
                      style: const TextStyle(
                          fontFamily: 'NunitoSans', fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₱${item.priceAtAddition.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.bold)),
                      if (canAddRemoveItems)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.redAccent),
                          tooltip: 'Remove Item',
                          onPressed: () =>
                              _showRemoveItemModal(context, booking.id, item),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildNotesCard(
      BuildContext context, Booking booking, String? userRole, WidgetRef ref) {
    // TODO: Implement editable notes if needed, for now just display
    return _buildCard(
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Customer Notes', booking.customerNotes),
          const SizedBox(height: 8),
          _buildInfoRow('Employee Notes', booking.employeeNotes),
          const SizedBox(height: 8),
          _buildInfoRow('Admin Notes', booking.adminNotes),
        ],
      ),
    );
  }

  Widget _buildPricingAndActionsCard(
      BuildContext context, Booking booking, String? userRole, WidgetRef ref) {
    double subtotal = 0;
    booking.bookingServices
        ?.forEach((s) => subtotal += (s.finalPrice ?? s.estimatedPrice));
    booking.bookingItems?.forEach((i) => subtotal += i.priceAtAddition);
    double total = booking.finalTotalPrice ??
        subtotal; // Assuming no tax/other charges for now

    bool canConfirmPrice = userRole == 'admin' &&
        booking.requiresAdminApproval &&
        booking.status == BookingStatus.pendingAdminApproval;
    bool canConfirmPayment = userRole == 'admin' &&
        booking.status == BookingStatus.pendingPayment &&
        !booking.isPaid;
    bool canGenerateReceipt =
        booking.status == BookingStatus.completed || booking.isPaid;

    return _buildCard(
      title: 'Summary & Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Subtotal:', '₱${subtotal.toStringAsFixed(2)}'),
          if (booking.finalTotalPrice != null)
            _buildInfoRow('Admin Approved Total:',
                '₱${booking.finalTotalPrice!.toStringAsFixed(2)}',
                valueWidget: Text(
                    '₱${booking.finalTotalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'NunitoSans'))),
          _buildInfoRow('Payment Status:', '',
              valueWidget: _statusChip(
                  booking.isPaid
                      ? BookingStatus.completed
                      : BookingStatus.pendingPayment,
                  isPayment: true)), // Simplified
          const Divider(height: 20),

          // --- Action Buttons ---
          if (canConfirmPrice)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm Final Price'),
                  onPressed: () async {
                    try {
                      await ref
                          .read(bookingDetailNotifierProvider(booking.id)
                              .notifier)
                          .confirmPrice(supabaseDB
                              .auth.currentUser!.id); // Pass admin user ID
                      ToastManager().showToast(
                          context, "Final price confirmed!", Colors.green);
                    } catch (e) {
                      ToastManager().showToast(
                          context, "Error confirming price: $e", Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white),
                ),
              ),
            ),
          if (canConfirmPayment)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Confirm Payment'),
                  onPressed: () async {
                    try {
                      await ref
                          .read(bookingDetailNotifierProvider(booking.id)
                              .notifier)
                          .confirmPayment(supabaseDB
                              .auth.currentUser!.id); // Pass admin user ID
                      ToastManager().showToast(
                          context, "Payment confirmed!", Colors.green);
                    } catch (e) {
                      ToastManager().showToast(
                          context, "Error confirming payment: $e", Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                ),
              ),
            ),
          if (canGenerateReceipt)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View/Generate Receipt'),
                  onPressed: () => _showReceiptModal(context, booking),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00AEEF),
                      foregroundColor: Colors.white),
                ),
              ),
            ),
          // Generic "Mark as..." buttons based on current status and allowed transitions
          // This is a simplified version. A more robust solution would use the _isTransitionAllowed logic.
          if (userRole == 'admin' || userRole == 'employee')
            ..._buildDynamicActionButtons(context, ref, booking, userRole),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicActionButtons(
      BuildContext context, WidgetRef ref, Booking booking, String? userRole) {
    List<Widget> buttons = [];
    final notifier =
        ref.read(bookingDetailNotifierProvider(booking.id).notifier);

    // Example dynamic actions (expand this based on BookingService._isTransitionAllowed)
    if (booking.status == BookingStatus.confirmed &&
        (userRole == 'admin' || userRole == 'employee')) {
      buttons.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => notifier.updateStatus(BookingStatus.inProgress,
                    userRole: userRole,
                    userId: supabaseDB.auth.currentUser?.id),
                child: const Text("Start Service"))),
      ));
    }
    if (booking.status == BookingStatus.inProgress &&
        (userRole == 'admin' || userRole == 'employee')) {
      buttons.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => notifier.updateStatus(
                    BookingStatus.pendingAdminApproval,
                    userRole: userRole,
                    userId: supabaseDB.auth.currentUser?.id),
                child: const Text("Request Admin Approval"))),
      ));
    }
    // Add more buttons for Cancel, NoShow, etc. based on status and role

    return buttons;
  }

  Widget _statusChip(BookingStatus status, {bool isPayment = false}) {
    Color chipColor = Colors.grey;
    String chipText = status.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();

    if (isPayment) {
      chipColor = status == BookingStatus.completed
          ? Colors.green
          : Colors.orange; // Completed = Paid
      chipText = status == BookingStatus.completed ? "Paid" : "Pending";
    } else {
      chipColor = _getStatusColor(status);
    }

    return Chip(
      label: Text(chipText,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'NunitoSans')),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(
          horizontal: 4.0), // Adjust padding around the label
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingConfirmation:
        return Colors.orange.shade700;
      case BookingStatus.confirmed:
        return Colors.blue.shade700;
      case BookingStatus.inProgress:
        return Colors.cyan.shade700;
      case BookingStatus.completed:
        return Colors.green.shade700;
      case BookingStatus.cancelled:
        return Colors.red.shade700;
      case BookingStatus.noShow:
        return Colors.grey.shade700;
      case BookingStatus.pendingAdminApproval:
        return Colors.purple.shade700;
      case BookingStatus.pendingPayment:
        return Colors.amber.shade800;
      default:
        return Colors.black54;
    }
  }

  Future<String?> _showUpdatePriceDialog(
      BuildContext context, String serviceName, double currentPrice) async {
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toStringAsFixed(2));
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Update Price for "$serviceName"',
              style: const TextStyle(fontSize: 16)),
          content: TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(
              labelText: 'New Final Price (PHP)',
              prefixText: '₱',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Price cannot be empty.';
              }
              if (double.tryParse(value) == null || double.parse(value) < 0) {
                return 'Invalid price.';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (Form.of(dialogContext)!.validate()) {
                  // Assuming this dialog is wrapped in a Form or has one
                  Navigator.of(dialogContext).pop(priceController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
