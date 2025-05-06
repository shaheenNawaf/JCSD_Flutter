//Default Imports
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

///Backend Imports
//Booking
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart'; // BookingType enum
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart'; // bookingServiceProvider

//Services
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart'; // Provider: fetchAvailableServices

//Accounts
import 'package:jcsd_flutter/backend/modules/accounts/accounts_state.dart'; // Provider: accountNotifierProvider
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/view/admin/accountlist.dart';

//Generic Widgets
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart';
import 'package:jcsd_flutter/view/generic/dialogs/generic_dialog.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

//State Management for the relevant fields
final _selectedServiceIdsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => {});
final _selectedBookingTypeProvider =
    StateProvider.autoDispose<BookingType?>((ref) => null);
final _selectedDateTimeProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

final _estimatedPriceProvider = StateProvider.autoDispose<double>((ref) => 0.0);
final _isSubmittingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Optional: For form validation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to changes in selected services to update estimated price
      ref.listenManual(_selectedServiceIdsProvider, (previous, next) {
        _updateEstimatedPrice();
      });

      // Initial Price is already loaded
      _updateEstimatedPrice();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  //Error Dialog Handler
  Future<void> showErrorDialog(
      BuildContext context, String title, String message) {
    //if (!context.mounted) return null;

    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return ErrorDialog(title: title, content: message);
        });
  }

  // Calculates estimated price based on selected services.
  void _updateEstimatedPrice() {
    // Use read outside build/listeners if not reacting to changes here
    final selectedIds = ref.read(_selectedServiceIdsProvider);
    // Use watch inside build, but read is okay in callbacks/initState with caution
    final availableServicesAsync = ref.read(fetchAvailableServices);

    availableServicesAsync.whenData((availableServices) {
      double totalEstimate = 0.0;
      // Create lookup map only if needed
      final serviceMap = {for (var s in availableServices) s.serviceID: s};
      for (int id in selectedIds) {
        final service = serviceMap[id];
        if (service != null) {
          // Use minPrice from your updated ServicesData model
          totalEstimate += service.minPrice ??
              0.0; // Handle potential null from model/parsing
        }
      }
      // Update the estimated price state if the widget is still mounted
      if (mounted) {
        ref.read(_estimatedPriceProvider.notifier).state = totalEstimate;
      }
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)), // Start tomorrow
      firstDate: now, // Prevent selecting past dates
      lastDate: now.add(const Duration(days: 90)), // Limit booking window
    );

    if (pickedDate == null || !mounted) {
      return; // Return if date picking was cancelled or widget unmounted
    }

    // TODO: Implement logic to fetch available time slots for the selected date (complex).
    // For now, use a simple time picker, restrict times based on business hours.
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0), // Default start time
    );

    if (pickedTime != null) {
      final selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Final Validation - ensuring na the date/time selected is in the past - Handling it both FE and BE
      if (selectedDateTime
          .isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        // Add buffer
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Invalid Time'),
              content: const Text('Please select a future date and time slot.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Okay'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ),
          );
        }
        return;
      }
      ref.read(_selectedDateTimeProvider.notifier).state = selectedDateTime;
    }
  }

  // Handles the creation of the booking lfg
  Future<void> _submitBooking() async {
    // Optional: Form Validation - TBA
    // if (!(_formKey.currentState?.validate() ?? false)) {
    //   return;
    // }

    // Read current state values
    final selectedServiceIds = ref.read(_selectedServiceIdsProvider);
    final selectedBookingType = ref.read(_selectedBookingTypeProvider);
    final selectedDateTime = ref.read(_selectedDateTimeProvider);
    final notes = _notesController.text;

    // Read current user state safely
    final userAccountState = ref.read(accountNotifierProvider);

    AccountsData? currentUser = null;

    if (userAccountState is AccountsState &&
        userAccountState.accounts.isNotEmpty) {
      currentUser = userAccountState.accounts[0];
    }

    if (currentUser == null || currentUser.userID == null) {
      await showErrorDialog(context, 'Error',
          'Could not identify current user. Please log in again.');
      return;
    }

    final String currentUserID = currentUser.userID;

    // Validation under here
    if (selectedServiceIds.isEmpty) {
      showErrorDialog(
          context, 'Service Error', 'Please select a booking type.');
      return;
    }
    if (selectedBookingType == null) {
      showErrorDialog(
          context, 'Booking Error', 'Please select a booking type.');
      return;
    }
    if (selectedDateTime == null) {
      showErrorDialog(
          context, 'Date-Time Error', 'Please select a date and time.');
      return;
    }

    // --- Submission Logic ---
    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      // Call the BookingService method
      await ref.read(bookingServiceProvider).createNewBookingRequest(
            customerUserId: currentUserID, // Pass current user's UUID
            walkInCustomerName: null, // Not a walk-in created by customer
            walkInCustomerContact: null,
            serviceIds: selectedServiceIds.toList(),
            scheduledStartTime: selectedDateTime,
            bookingType: selectedBookingType,
            customerNotes: notes.trim().isEmpty ? null : notes.trim(),
            ref: ref, // Pass ref for service fetching
          );

      // Success Handling (if widget still mounted)
      if (mounted) {
        // Resetting form state providers
        ref.invalidate(_selectedServiceIdsProvider);
        ref.invalidate(_selectedBookingTypeProvider);
        ref.invalidate(_selectedDateTimeProvider);
        ref.invalidate(_estimatedPriceProvider);

        _notesController.clear();

        // Show success message/dialog
        await showCustomNotificationDialog(
            context: context,
            headerBar: 'Booking Submitted!',
            messageText:
                'Your booking request has been submitted. Please wait for confirmation from the shop.');
        // Optionally navigate back or to booking list
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Error Handling
      if (mounted) {
        showErrorDialog(
            context, 'Error', 'Failed to submit booking: ${e.toString()}');
      }
    } finally {
      // Always reset loading state if widget is still mounted
      if (mounted) {
        ref.read(_isSubmittingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableServicesAsync = ref.watch(fetchAvailableServices);
    final selectedServiceIds = ref.watch(_selectedServiceIdsProvider);
    final selectedBookingType = ref.watch(_selectedBookingTypeProvider);
    final selectedDateTime = ref.watch(_selectedDateTimeProvider);
    final estimatedPrice = ref.watch(_estimatedPriceProvider);
    final isSubmitting = ref.watch(_isSubmittingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Booking'),
        // Optionally add actions like reset
      ),
      body: Form(
        // Optional: Wrap with Form for validation
        key: _formKey,
        child: ListView(
          // Use ListView for scrollability
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Booking Type Selection ---
            const Text('1. Select Booking Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BookingType>(
              value: selectedBookingType,
              hint: const Text('Select Type'),
              // Filter out 'unknown' type if it exists in your enum
              items: BookingType.values
                  .where((type) => type != BookingType.unknown)
                  .map((BookingType type) {
                return DropdownMenuItem<BookingType>(
                  value: type,
                  // Capitalize first letter for display
                  child:
                      Text(type.name[0].toUpperCase() + type.name.substring(1)),
                );
              }).toList(),
              onChanged: (BookingType? newValue) {
                // Update state and potentially clear incompatible service selections
                ref.read(_selectedBookingTypeProvider.notifier).state =
                    newValue;
                ref.read(_selectedServiceIdsProvider.notifier).update((state) {
                  // Example: Clear selection if type changes, adjust as needed
                  return <int>{};
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                // Add validation if needed
              ),
              // validator: (value) => value == null ? 'Please select a booking type' : null,
            ),
            const SizedBox(height: 20),

            // --- Service Selection ---
            const Text('2. Select Service(s):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            availableServicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return const Text('No services currently available.');
                }
                // Filter services based on selected booking type
                final filteredServices = services.where((s) {
                  // Hide inactive services
                  if (s.isActive == false) {
                    return false; // Assuming isActive=false means archived
                  }

                  // Logic based on booking type selection
                  if (selectedBookingType == BookingType.walkIn) {
                    // If walk-in only services exist, show only those. Otherwise show all non-home-service?
                    bool hasWalkInOnly = services.any((s2) => s2.isWalkInOnly);
                    return hasWalkInOnly ? s.isWalkInOnly : !s.requiresAddress;
                  }
                  if (selectedBookingType == BookingType.homeService) {
                    // Show only services requiring address
                    return s.requiresAddress;
                  }
                  // For Appointment or if type not selected yet, show services that are NOT walk-in only
                  return !s.isWalkInOnly;
                }).toList();

                if (filteredServices.isEmpty && selectedBookingType != null) {
                  return Text(
                      'No services available for the selected booking type (${selectedBookingType.name}).');
                }
                if (filteredServices.isEmpty) {
                  return const Text(
                      'Loading available services...'); // Or handle case where all services might be filtered out initially
                }

                // Display filtered services using ChoiceChips
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: filteredServices.map((service) {
                    final isSelected =
                        selectedServiceIds.contains(service.serviceID);
                    return ChoiceChip(
                      label: Text(
                          '₱ ${service.serviceName} (Est: ₱ ${service.minPrice?.toStringAsFixed(2) ?? 'N/A'})'),
                      selected: isSelected,
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
                        // Price updates via the listener
                      },
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading services: $err')),
            ),
            const SizedBox(height: 20),

            // DateTime Picker
            const Text('3. Select Date & Time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey)),
              title: Text(
                selectedDateTime == null
                    ? 'Tap to choose date and time'
                    : DateFormat.yMMMEd().add_jm().format(selectedDateTime),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 20),

            // Estimated Price Display
            if (selectedServiceIds.isNotEmpty) ...[
              // Only show if services are selected
              Text(
                'Estimated Total: ₱${estimatedPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
            ],

            // Customer Notes
            const Text('4. Additional Notes (Optional):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Any specific requests, device model, or issue details...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Booking Request'),
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        // backgroundColor: Theme.of(context).primaryColor, // Example styling
                        // foregroundColor: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
