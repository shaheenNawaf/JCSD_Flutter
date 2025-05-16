//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

//Backend Imports

//Booking
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/detail_view/booking_detail_notifier.dart';

//Employees
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart'; //Fetching Employee
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';

//Accounts
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/api/global_variables.dart'; // For current user ID

class EditBookingModal extends ConsumerStatefulWidget {
  final Booking booking;

  const EditBookingModal({super.key, required this.booking});

  @override
  ConsumerState<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends ConsumerState<EditBookingModal> {
  late BookingStatus _selectedStatus;
  int? _selectedEmployeeId;
  String?
      _currentLoggedInUserId; // Storing the ID of the admin/employee performing action

  final TextEditingController _adminNotesController = TextEditingController();
  final TextEditingController _employeeNotesController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.booking.status;
    _adminNotesController.text = widget.booking.adminNotes ?? '';
    _employeeNotesController.text = widget.booking.employeeNotes ?? '';

    // Pre-select assigned employee if already assigned (though UI doesn't directly show this)
    // You might fetch widget.booking.bookingAssignments.first.employeeId if needed
    // For simplicity, we'll leave _selectedEmployeeId as null initially for new assignments

    // Get current logged-in user (admin/employee) ID
    final currentUser = supabaseDB.auth.currentUser;
    if (currentUser != null) {
      _currentLoggedInUserId = currentUser.id;
    }
  }

  void dispose() {
    _adminNotesController.dispose();
    _employeeNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    //Fetching and refreshing data
    final bookingService = ref.read(bookingServiceProvider);
    final bookingDetailNotifier =
        ref.read(bookingDetailNotifierProvider(widget.booking.id).notifier);
    final bookingListNotifier = ref.read(bookingListNotifierProvider.notifier);

    //Fetching userRole -- for checking
    //final String? currentUserRole = await ref.read(userRoleProvider.future);

    //Text Controllers
    String? adminNotesForUpdate = _adminNotesController.text.trim();
    String? employeeNotesForUpdate = _employeeNotesController.text.trim();

    //TextForm Verification -- Full Application
    if (adminNotesForUpdate.isEmpty) adminNotesForUpdate = null;
    if (employeeNotesForUpdate.isEmpty) employeeNotesForUpdate = null;

    try {
      if (widget.booking.status == BookingStatus.pendingConfirmation &&
          _selectedStatus == BookingStatus.confirmed) {
        if (_selectedEmployeeId == null) {
          ToastManager().showToast(
              context,
              'Please assign an employee to confirm the booking.',
              Colors.orange);
          setState(() => _isLoading = false);
          return;
        }
        // confirmBookingRequest also updates status to Confirmed
        await bookingService.confirmBookingRequest(
            widget.booking.id, _selectedEmployeeId!);
      } else if (_selectedStatus != widget.booking.status) {
        // TODO: Get userRole for status update logic
        // For now, assume it's an admin or an employee allowed to make the change.
        // The BookingService's _isTransitionAllowed will do the main validation.
        await bookingService.updateBookingStatus(
          widget.booking.id,
          _selectedStatus,
          notes: "Status updated via modal.", // TBA: Note Controllers go here
          userId:
              _currentLoggedInUserId, // Pass the ID of admin/employee making the change
          // userRole: userRole, // This would ideally come from a role provider
        );
      }

      // TODO: Handle note updates if you add controllers for them.

      ToastManager()
          .showToast(context, 'Booking updated successfully!', Colors.green);
      await bookingDetailNotifier.refresh();
      await bookingListNotifier.refresh();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ToastManager().showToast(
          context, 'Error updating booking: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool newNotesDifferentFromOriginal(
      String? newAdminNotes, String? newEmployeeNotes) {
    return newAdminNotes != (widget.booking.adminNotes ?? '') ||
        newEmployeeNotes != (widget.booking.employeeNotes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;
    final employeeState = ref.watch(employeeNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  widget.booking.status == BookingStatus.pendingConfirmation
                      ? 'Confirm Booking Request'
                      : 'Edit Booking Details',
                  style: const TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStaticInfoRow(
                        'Booking ID:', widget.booking.id.toString()),
                    _buildStaticInfoRow(
                        'Customer:',
                        widget.booking.walkInCustomerName ??
                            (widget.booking.customerUserId ?? 'N/A')),
                    _buildStaticInfoRow(
                        'Scheduled:',
                        DateFormat.yMMMEd()
                            .add_jm()
                            .format(widget.booking.scheduledStartTime)),
                    _buildStaticInfoRow(
                        'Type:', widget.booking.bookingType.name.toUpperCase()),
                    const SizedBox(height: 16),
                    _buildDropdownField<BookingStatus>(
                      label: 'Booking Status',
                      value: _selectedStatus,
                      items: BookingStatus.values
                          .where((s) => s != BookingStatus.unknown)
                          .toList(),
                      onChanged: (BookingStatus? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedStatus = newValue);
                        }
                      },
                      itemBuilder: (BookingStatus status) => Text(status.name
                          .replaceAllMapped(
                              RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                          .trim()),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    if (widget.booking.status ==
                            BookingStatus.pendingConfirmation ||
                        _selectedStatus == BookingStatus.confirmed)
                      Builder(
                        builder: (context) {
                          final employeesWithAccounts =
                              employeeState.employeeAccounts;
                          if (employeesWithAccounts.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('No employees available to assign.'),
                            );
                          }
                          return _buildDropdownField<int?>(
                            label: 'Assign Employee',
                            value: _selectedEmployeeId,
                            items: employeesWithAccounts
                                .map((empMap) => int.tryParse(
                                    (empMap['employee'] as EmployeeData)
                                        .employeeID))
                                .where((id) => id != null)
                                .toList(),
                            onChanged: (int? newValue) {
                              setState(() => _selectedEmployeeId = newValue);
                            },
                            itemBuilder: (int? empId) {
                              if (empId == null) return const Text("N/A");
                              final empMap = employeesWithAccounts.firstWhere(
                                (map) =>
                                    (map['employee'] as EmployeeData)
                                        .employeeID ==
                                    empId.toString(),
                                orElse: () => {
                                  'account': AccountsData.empty(''),
                                  'employee': EmployeeData(
                                      employeeID: '',
                                      userID: '',
                                      isAdmin: false,
                                      companyRole: 'N/A',
                                      isActive: false,
                                      createDate: DateTime.now(),
                                      monthlySalary: 220.0,)
                                },
                              );
                              final account = empMap['account'] as AccountsData;
                              return Text(
                                  '${account.firstName} ${account.lastname}');
                            },
                            hintText: 'Select Employee',
                            isRequired: widget.booking.status ==
                                    BookingStatus.pendingConfirmation &&
                                _selectedStatus == BookingStatus.confirmed,
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: "Admin Notes",
                        controller: _adminNotesController,
                        maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: "Employee Notes",
                        controller: _employeeNotesController,
                        maxLines: 3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        foregroundColor: Colors.white),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(widget.booking.status ==
                                    BookingStatus.pendingConfirmation &&
                                _selectedStatus == BookingStatus.confirmed
                            ? 'Confirm & Assign'
                            : 'Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'NunitoSans')),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontFamily: 'NunitoSans'))),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
        )
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required Widget Function(T item) itemBuilder,
    String? hintText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
            if (isRequired)
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<T>(
          value: value,
          hint: hintText != null
              ? Text(hintText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Colors.grey))
              : null,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (val) {
                  if (val == null) return '$label is required';
                  // If T is int?, null is a valid "unselected" state unless explicitly required to be non-null
                  if (val is int && val == null && isRequired)
                    return '$label is required';
                  return null;
                }
              : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
