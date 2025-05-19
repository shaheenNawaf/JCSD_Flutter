import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart'; // For supabaseDB
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
// Removed: import '../../../backend/modules/bookings/state/list_view/booking_list_state.dart'; // Not directly used here for provider invalidation

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

  String? _selectedEmployeeId; // Changed to int for employeeID (PK)
  Set<int> _selectedServiceIds = {};
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitWalkInBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServiceIds.isEmpty) {
      ToastManager().showToast(
          context, 'Please select at least one service.', Colors.orange);
      return;
    }

    if (_selectedEmployeeId == null) {
      ToastManager()
          .showToast(context, 'Please assign an employee.', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      // final currentUserRole = ref.read(userRoleProvider).asData?.value; // If needed for notes

      final Booking walkInBooking =
          await bookingService.createNewBookingRequest(
        customerUserId: null, // This is a walk-in
        walkInCustomerName: _nameController.text.trim(),
        walkInCustomerContact: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        serviceIds: _selectedServiceIds.toList(),
        scheduledStartTime: _selectedDateTime,
        bookingType: BookingType.walkIn,
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
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      debugPrint('Failed to create walk-in booking: $e\nStack: $s');
      ToastManager()
          .showToast(context, 'Operation failed: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableServicesAsync = ref.watch(fetchAvailableServices);
    final employeeState = ref.watch(employeeNotifierProvider);

    return AlertDialog(
      title: const Text('Add Walk-In Customer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                    labelText: 'Contact Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('Services*:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              availableServicesAsync.when(
                data: (services) {
                  if (services.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No services available.'),
                    );
                  }
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: services
                        .where((s) =>
                            s.isActive &&
                            !s.isWalkInOnly) // Assuming walk-ins can't be walk-in only services
                        .map((service) => FilterChip(
                              label: Text(service.serviceName),
                              selected: _selectedServiceIds
                                  .contains(service.serviceID),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedServiceIds.add(service.serviceID);
                                  } else {
                                    _selectedServiceIds
                                        .remove(service.serviceID);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Text('Error loading services: $err',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              const SizedBox(height: 16),
              Text(
                  'Scheduled Time: ${DateFormat.yMd().add_jm().format(_selectedDateTime)}'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _pickDateTime,
                child: const Text('Change Time'),
              ),
              const SizedBox(height: 16),
              Text('Assign Employee*:',
                  style: Theme.of(context).textTheme.titleMedium),
              if (employeeState.employeeAccounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Loading employees or no employees available.'),
                )
              else
                Builder(
                  builder: (context) {
                    final activeEmployeesWithDetails = employeeState
                        .employeeAccounts
                        .where((empMap) {
                          final employeeData =
                              empMap['employee'] as EmployeeData?;
                          return employeeData?.isActive ?? false;
                        })
                        .map((empMap) {
                          final account = empMap['account'] as AccountsData?;
                          final employee = empMap['employee'] as EmployeeData?;
                          if (account == null || employee == null) return null;
                          return {
                            'id': employee.employeeID,
                            'name': '${account.firstName} ${account.lastname}'
                          }; // employeeID is now int
                        })
                        .whereType<Map<String, dynamic>>() // Filter out nulls
                        .toList();

                    if (activeEmployeesWithDetails.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No active employees available to assign.'),
                      );
                    }

                    // Reset selected employee if current selection is no longer valid
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
                        labelText: 'Select Employee',
                        border: OutlineInputBorder(),
                        hintText: 'Assign to an employee',
                      ),
                      value: _selectedEmployeeId,
                      isExpanded: true,
                      items: activeEmployeesWithDetails.map((empDetail) {
                        return DropdownMenuItem<String>(
                          value: empDetail['id'] as String,
                          child: Text(empDetail['name'] as String),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmployeeId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          // Check for null directly
                          return 'Please select an employee.';
                        }
                        return null;
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitWalkInBooking,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Create & Confirm'),
        ),
      ],
    );
  }
}
