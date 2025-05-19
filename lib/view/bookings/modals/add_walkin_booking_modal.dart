import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

final _selectedServiceIdsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => {});
final _selectedBookingTypeProvider =
    StateProvider.autoDispose<BookingType>((ref) => BookingType.appointment);
final _selectedDateTimeProvider = StateProvider.autoDispose<DateTime?>(
    (ref) => DateTime.now()); // Initialize with now
final _isSubmittingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddWalkInBookingModal extends ConsumerStatefulWidget {
  const AddWalkInBookingModal({super.key});

  @override
  ConsumerState<AddWalkInBookingModal> createState() =>
      _AddWalkInBookingModalState();
}

class _AddWalkInBookingModalState extends ConsumerState<AddWalkInBookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(_selectedServiceIdsProvider);
      ref.invalidate(_selectedBookingTypeProvider);
      ref.read(_selectedDateTimeProvider.notifier).state = DateTime.now();
      ref.invalidate(_isSubmittingProvider);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final currentSelectedDateTime =
        ref.read(_selectedDateTimeProvider) ?? DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: currentSelectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentSelectedDateTime),
    );
    if (time == null) return;

    ref.read(_selectedDateTimeProvider.notifier).state = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _submitWalkInBooking() async {
    if (!_formKey.currentState!.validate()) {
      ToastManager()
          .showToast(context, 'Please fix errors in the form.', Colors.orange);
      return;
    }

    final selectedServiceIds = ref.read(_selectedServiceIdsProvider);
    final selectedDateTime = ref.read(_selectedDateTimeProvider);

    if (selectedServiceIds.isEmpty) {
      ToastManager().showToast(
          context, 'Please select at least one service.', Colors.orange);
      return;
    }
    if (selectedDateTime == null) {
      ToastManager()
          .showToast(context, 'Please select a date and time.', Colors.orange);
      return;
    }

    if (_selectedEmployeeId == null) {
      ToastManager()
          .showToast(context, 'Please assign an employee.', Colors.orange);
      return;
    }

    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final currentAuthUser = supabaseDB.auth.currentUser;

      if (currentAuthUser == null) {
        ToastManager().showToast(
            context, 'Error: Not authenticated. Please log in.', Colors.red);
        ref.read(_isSubmittingProvider.notifier).state = false;
        return;
      }

      final Booking walkInBooking =
          await bookingService.createNewBookingRequest(
        customerUserId: null,
        walkInCustomerName: _nameController.text.trim(),
        walkInCustomerContact: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        serviceIds: selectedServiceIds.toList(),
        scheduledStartTime: selectedDateTime,
        bookingType: BookingType.walkIn, // Explicitly WalkIn
        customerNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        ref: ref,
      );

      final int newBookingID = walkInBooking.id;

      await bookingService.confirmBookingRequest(
        newBookingID,
        int.parse(_selectedEmployeeId!),
        adminNotes: "Walk-in booking created and confirmed by staff.",
      );

      debugPrint(
          'Walk-in booking $newBookingID confirmed and assigned to employee $_selectedEmployeeId.');

      ToastManager().showToast(
          context, 'Walk-in booking created successfully!', Colors.green);

      ref.invalidate(bookingListNotifierProvider);
      ref.invalidate(bookingDetailNotifierProvider(newBookingID));

      if (mounted) {
        Navigator.of(context).pop(true); // Pop with true to indicate success
      }
    } catch (e, s) {
      debugPrint('Failed to create walk-in booking: $e\nStack: $s');
      ToastManager()
          .showToast(context, 'Operation failed: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        ref.read(_isSubmittingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth =
        screenWidth > 700 ? 650 : screenWidth * 0.9; // Matched AddProdDefModal

    final isSubmitting = ref.watch(_isSubmittingProvider);
    final selectedDateTime = ref.watch(_selectedDateTimeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        // Use SizedBox for consistent sizing
        width: containerWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // Header
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Center(
                  child: Text('Add Walk-In Booking',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                ),
              ),
              Flexible(
                // Make content scrollable if it overflows
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTextField(
                        label: 'Customer Name',
                        hintText: 'Enter customer name',
                        controller: _nameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                          label: 'Contact Number (Optional)',
                          hintText: 'Enter contact number',
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11)
                          ],
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^(09|\+639)\d{9}$').hasMatch(value)) {
                              return 'Enter a valid PH mobile number (e.g., 09xxxxxxxxx or +639xxxxxxxxx)';
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildServiceSelectionChips(),
                      const SizedBox(height: 15),
                      _buildDateTimeField(selectedDateTime),
                      const SizedBox(height: 15),
                      _buildEmployeeDropdown(),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: 'Notes (Optional)',
                        hintText: 'Enter any notes for the booking...',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                // Action Buttons
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xFF00AEEF)))),
                        child: const Text('Cancel',
                            style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: isSubmitting
                            ? Container()
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Create & Confirm'),
                        onPressed: isSubmitting ? null : _submitWalkInBooking,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // Consistent with AddProdDef
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            textStyle: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13))
        ]),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 11),
          ),
          validator: validator ??
              (v) => (isRequired && (v == null || v.trim().isEmpty))
                  ? '$label is required'
                  : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _buildServiceSelectionChips() {
    final availableServicesAsync = ref.watch(fetchAvailableServices);
    final selectedServiceIds = ref.watch(_selectedServiceIdsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Services',
              style: TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
          Text(' *', style: TextStyle(color: Colors.red, fontSize: 13))
        ]),
        const SizedBox(height: 4),
        availableServicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No services available.'),
              );
            }
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4)),
              constraints: const BoxConstraints(
                  maxHeight: 150), // Limit height for scrollability
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 0.0,
                  children: services
                      .where((s) =>
                          s.isActive &&
                          (s.isWalkInOnly == false || s.isWalkInOnly == null))
                      .map((service) => FilterChip(
                            label: Text(service.serviceName,
                                style: const TextStyle(fontSize: 11)),
                            selected:
                                selectedServiceIds.contains(service.serviceID),
                            onSelected: (selected) {
                              ref
                                  .read(_selectedServiceIdsProvider.notifier)
                                  .update((state) {
                                final newSet = Set<int>.from(state);
                                if (selected) {
                                  newSet.add(service.serviceID);
                                } else {
                                  newSet.remove(service.serviceID);
                                }
                                return newSet;
                              });
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  selectedServiceIds.contains(service.serviceID)
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, st) => Text('Error: $err',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(DateTime? selectedDateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Scheduled Time',
              style: TextStyle(fontFamily: 'NunitoSans', fontSize: 13),
            ),
            Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 13),
            )
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedDateTime != null
                ? DateFormat.yMd().add_jm().format(selectedDateTime)
                : 'Select date and time...',
          ),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 11),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, size: 18),
              onPressed: _pickDateTime,
            ),
          ),
          validator: (_) =>
              selectedDateTime == null ? 'Date and time are required' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown() {
    final employeeState = ref.watch(employeeNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Assign Employee',
              style: TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
          Text(' *', style: TextStyle(color: Colors.red, fontSize: 13))
        ]),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final activeEmployeesWithDetails = employeeState.employeeAccounts
                .where((empMap) {
                  final employeeData = empMap['employee'] as EmployeeData?;
                  return employeeData?.isActive ?? false;
                })
                .map((empMap) {
                  final account = empMap['account'] as AccountsData?;
                  final employee = empMap['employee'] as EmployeeData?;
                  if (account == null || employee == null) return null;
                  return {
                    'id': employee.employeeID,
                    'name': '${account.firstName} ${account.lastname}'
                  };
                })
                .whereType<Map<String, dynamic>>()
                .toList();

            if (activeEmployeesWithDetails.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No active employees available.',
                    style: TextStyle(fontSize: 11)),
              );
            }

            if (_selectedEmployeeId != null &&
                !activeEmployeesWithDetails
                    .any((map) => map['id'] == _selectedEmployeeId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedEmployeeId = null;
                  });
                }
              });
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select employee...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                    fontSize: 11),
              ),
              value: _selectedEmployeeId,
              isExpanded: true,
              items: activeEmployeesWithDetails.map((empDetail) {
                return DropdownMenuItem<String>(
                  value: empDetail['id'] as String,
                  child: Text(empDetail['name'] as String,
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans')),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmployeeId = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Employee is required' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            );
          },
        ),
      ],
    );
  }
}
