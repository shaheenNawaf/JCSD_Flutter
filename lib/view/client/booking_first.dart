//Base Imports
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';

//UI Imports
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/view/client/modals/booking_confirmed.dart';

//Backend Implementations
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';

//State Management
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';

//Added these helpers for state management

final _selectedServiceIdsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => {});
// Holds the selected booking type
final _selectedBookingTypeProvider =
    StateProvider.autoDispose<BookingType>((ref) => BookingType.appointment);
// Holds the selected date and time
final _selectedDateTimeProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);
// Holds calculated estimated price
final _estimatedPriceProvider = StateProvider.autoDispose<double>((ref) => 0.0);
// Holds loading state during submission
final _isSubmittingProvider = StateProvider.autoDispose<bool>((ref) => false);
//Holding date state during submission
final _selectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Added a specific Database function inside the Database
final unavailableSlotsProvider = FutureProvider.autoDispose
    .family<List<String>, DateTime>((ref, date) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  print('[unavailableSlotsProvider] Fetching for date: $formattedDate');
  try {
    final response = await supabaseDB.rpc(
      'get_unavailable_slots', // Ensure this RPC function exists in Supabase
      params: {'p_date': formattedDate},
    );
    print(
        '[unavailableSlotsProvider] RPC response for $formattedDate: $response');
    if (response is List) {
      return response
          .map((item) => item?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    print(
        'Warning: Unexpected RPC response format from get_unavailable_slots. Expected List, got ${response?.runtimeType}');
    return <String>[];
  } catch (e, stackTrace) {
    print(
        '[unavailableSlotsProvider] Error fetching unavailable slots for $formattedDate: $e\n$stackTrace');
    return <String>[];
  }
});

class ClientBooking1 extends ConsumerStatefulWidget {
  const ClientBooking1({super.key});

  @override
  ConsumerState<ClientBooking1> createState() => _ClientBooking1State();
}

class _ClientBooking1State extends ConsumerState<ClientBooking1> {
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  DateTime currentDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  final List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentDate = DateTime(now.year, now.month, now.day);
    startDate = _getWeekStart(currentDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_selectedDateProvider.notifier).state = currentDate;
      _updateEstimatedPrice();
      ref.listenManual(
          _selectedServiceIdsProvider, (_, __) => _updateEstimatedPrice());
      ref.listenManual(
          _selectedBookingTypeProvider,
          (_, nextType) =>
              _validateSelectedServicesAgainstBookingType(nextType));
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  //Added UI Elements (Generic Ones)

  //Error Dialog Handler
  Future<void> showErrorDialog(
      BuildContext context, String title, String message) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return ErrorDialog(title: title, content: message);
        });
  }

  //Helper Functions

  //Auto-updated the estimated price based on the selected services
  void _updateEstimatedPrice() {
    final selectedIDs = ref.read(_selectedServiceIdsProvider);
    final availableServicesAsync = ref.read(fetchAvailableServices);

    availableServicesAsync.whenData((availableServices) {
      double totalEsitmate = 0.0;
      final serviceMap = {for (var s in availableServices) s.serviceID: s};
      for (int id in selectedIDs) {
        final service = serviceMap[id];
        if (service != null) {
          totalEsitmate += service.minPrice ?? 0.0;
        }
      }
      if (mounted) {
        ref.read(_estimatedPriceProvider.notifier).state = totalEsitmate;
      }
    });
  }

  //Handles date navigation
  void navigateDate(bool isNext) {
    final newStartDate = isNext
        ? startDate.add(const Duration(days: 7))
        : startDate.subtract(const Duration(days: 7));
    if (newStartDate.isBefore(_getWeekStart(currentDate))) {
      return;
    }
    setState(() {
      startDate = newStartDate;
      ref.read(_selectedDateProvider.notifier).state = newStartDate;
      ref.read(_selectedDateTimeProvider.notifier).state = null;
    });
  }

  bool _validateSelectedServicesAgainstBookingType(BookingType bookingType) {
    final selectedIds = ref.read(_selectedServiceIdsProvider);
    final availableServicesAsyncValue = ref.read(fetchAvailableServices);

    if (selectedIds.isEmpty) return true;

    final availableServices = availableServicesAsyncValue.asData?.value;
    if (availableServices == null) return true; // Services not loaded yet

    final serviceMap = {for (var s in availableServices) s.serviceID: s};
    List<String> incompatibleServices = [];
    String errorMessage = '';

    for (int id in selectedIds) {
      final service = serviceMap[id];
      if (service == null) continue;

      if (bookingType == BookingType.homeService && !service.requiresAddress) {
        incompatibleServices.add(service.serviceName);
        errorMessage =
            'The following selected services are not available for Home Service: ${service.serviceName}';
      } else if (bookingType != BookingType.homeService &&
          service.isWalkInOnly) {
        incompatibleServices.add(service.serviceName);
        errorMessage =
            'The following selected services are Walk-in Only and cannot be booked for In-Shop Appointment: ${service.serviceName}';
      }
    }

    if (incompatibleServices.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showErrorDialog(context, 'Service Compatibility Error',
              '$errorMessage\n- ${incompatibleServices.join("\n- ")}\nPlease adjust your selection.');
        }
      });
      return false;
    }
    return true;
  }

  // Action Methods

  Future<void> _submitBooking() async {
    final selectedServiceIds = ref.read(_selectedServiceIdsProvider);
    final selectedBookingType = ref.read(_selectedBookingTypeProvider);
    final selectedDateTime = ref.read(_selectedDateTimeProvider);
    final notes = notesController.text;

    if (!_validateSelectedServicesAgainstBookingType(selectedBookingType)) {
      return;
    }
    if (selectedServiceIds.isEmpty) {
      await showErrorDialog(
          context, 'Input Error', 'Please select at least one service.');
      return;
    }
    if (selectedDateTime == null) {
      await showErrorDialog(
          context, 'Input Error', 'Please select a date and time slot.');
      return;
    }

    final currentUserAuth = supabaseDB.auth.currentUser;
    if (currentUserAuth == null) {
      await showErrorDialog(
          context, 'Authentication Error', 'You must be logged in to book.');
      if (mounted) context.go('/login');
      return;
    }
    final String currentUserID = currentUserAuth.id;

    ref.read(_isSubmittingProvider.notifier).state = true;
    try {
      await ref.read(bookingServiceProvider).createNewBookingRequest(
            customerUserId: currentUserID,
            walkInCustomerName: null,
            walkInCustomerContact: null,
            serviceIds: selectedServiceIds.toList(),
            scheduledStartTime: selectedDateTime,
            bookingType: selectedBookingType,
            customerNotes: notes.trim().isEmpty ? null : notes.trim(),
            ref: ref,
          );

      if (mounted) {
        ref.invalidate(_selectedServiceIdsProvider);
        ref.invalidate(_selectedBookingTypeProvider);
        ref.invalidate(_selectedDateTimeProvider);
        ref.invalidate(_estimatedPriceProvider);
        notesController.clear();

        showDialog(
          context: context,
          barrierDismissible: false, // User must tap button to close
          builder: (BuildContext context) {
            return const BookingConfirmationModal(); // Your confirmation modal
          },
        );
      }
    } catch (e, stackTrace) {
      print('Error submitting booking: $e \n $stackTrace');
      if (mounted) {
        await showErrorDialog(
            context, 'Booking Failed', 'An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        ref.read(_isSubmittingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    final availableServicesAsync = ref.watch(fetchAvailableServices);
    final selectedServiceIds = ref.watch(_selectedServiceIdsProvider);
    final selectedBookingType = ref.watch(_selectedBookingTypeProvider);
    final selectedDateTime = ref.watch(_selectedDateTimeProvider);
    final estimatedPrice = ref.watch(_estimatedPriceProvider);
    final isSubmitting = ref.watch(_isSubmittingProvider);
    final viewedDate = ref.watch(_selectedDateProvider);

    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: Form(
        key: formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: const Color(0xFFDFDFDF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceSelection(availableServicesAsync,
                          selectedServiceIds, selectedBookingType),
                      const SizedBox(height: 20),
                      _buildSlotSelection(viewedDate, selectedDateTime),
                      const SizedBox(height: 20),
                      _buildHomeServiceOption(selectedBookingType),
                      const SizedBox(height: 20),
                      _buildNotesSection(),
                      const SizedBox(height: 20),
                      _buildReceipt(
                          estimatedPrice,
                          selectedServiceIds.isNotEmpty,
                          availableServicesAsync,
                          selectedDateTime,
                          selectedBookingType),
                      const SizedBox(height: 20),
                      _buildHelpSection(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(isSubmitting, context),
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFDFDFDF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServiceSelection(availableServicesAsync,
                                selectedServiceIds, selectedBookingType),
                            const SizedBox(height: 20),
                            _buildSlotSelection(viewedDate, selectedDateTime),
                            const SizedBox(height: 20),
                            _buildHomeServiceOption(selectedBookingType),
                            const SizedBox(height: 20),
                            _buildNotesSection(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildReceipt(
                                      estimatedPrice,
                                      selectedServiceIds.isNotEmpty,
                                      availableServicesAsync,
                                      selectedDateTime,
                                      selectedBookingType),
                                  const SizedBox(height: 20),
                                  _buildHelpSection(),
                                  const SizedBox(height: 20),
                                  _buildSubmitButton(isSubmitting,
                                      context), // "Continue" button
                                  const SizedBox(height: 20),
                                ],
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
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting, BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    String buttonText = isDesktop ? 'Book Now!' : 'Continue';

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00AEEF),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontFamily: 'Nunito'),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(buttonText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildServiceSelection(AsyncValue<List<ServicesData>> servicesAsync,
      Set<int> currentSelectedIds, BookingType? currentSelectedType) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select services',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          servicesAsync.when(
            data: (services) {
              if (services.isEmpty) {
                return const Text('No services currently available.');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  // Using Row to match the screenshot's horizontal layout
                  children: services.where((s) => s.isActive).map((service) {
                    // Filter for active services
                    final isSelected =
                        currentSelectedIds.contains(service.serviceID);
                    bool isCompatible = true;
                    if (currentSelectedType == BookingType.homeService &&
                        !service.requiresAddress) {
                      isCompatible = false;
                    } else if (currentSelectedType != BookingType.homeService &&
                        service.isWalkInOnly) {
                      isCompatible = false;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: FilterChip(
                        label: Text(service.serviceName,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                color: !isCompatible
                                    ? Colors.grey.shade600
                                    : (isSelected
                                        ? Colors.white
                                        : Colors.black))),
                        selected: isSelected &&
                            isCompatible, // Only show as selected if compatible
                        backgroundColor: !isCompatible
                            ? Colors.grey.shade300
                            : const Color(0xFFEFEFEF),
                        selectedColor: const Color(0xFF00AEEF),
                        checkmarkColor: Colors.white,
                        showCheckmark: true,
                        labelStyle: TextStyle(
                          decoration:
                              !isCompatible ? TextDecoration.lineThrough : null,
                        ),
                        onSelected: !isCompatible
                            ? null
                            : (selected) {
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
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading services: $err',
                style: const TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildSlotSelection(DateTime viewedDate, DateTime? selectedDateTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a slot',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildDatePicker(viewedDate),
          const SizedBox(height: 20),
          _buildTimePicker(viewedDate, selectedDateTime),
        ],
      ),
    );
  }

  Widget _buildHomeServiceOption(BookingType currentSelectedType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          final currentType = ref.read(_selectedBookingTypeProvider);
          final newType = currentType == BookingType.homeService
              ? BookingType.appointment
              : BookingType.homeService;
          ref.read(_selectedBookingTypeProvider.notifier).state = newType;
          // Validation will be triggered by the listener in initState
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: currentSelectedType == BookingType.homeService,
              onChanged: (value) {
                final newType = value == true
                    ? BookingType.homeService
                    : BookingType.appointment;
                ref.read(_selectedBookingTypeProvider.notifier).state = newType;
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service to be done at your home',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text('This may incur an additional fee.',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notes',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
                hintText:
                    'Add notes for the service (e.g., device model, specific issue)',
                border: OutlineInputBorder(),
                hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 16)),
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReceipt(
      double estimatedPrice,
      bool hasServicesSelected,
      AsyncValue<List<ServicesData>> servicesAsync,
      DateTime? selectedDateTime,
      BookingType selectedBookingType) {
    List<String> getSelectedServiceNames() {
      final selectedIds = ref.read(_selectedServiceIdsProvider);
      final services = servicesAsync.asData?.value ?? [];
      final serviceMap = {for (var s in services) s.serviceID: s.serviceName};
      return selectedIds
          .map((id) => serviceMap[id] ?? 'Unknown Service')
          .toList();
    }

    final serviceNames = getSelectedServiceNames();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Image.asset('assets/images/logo.png', height: 50),
          const SizedBox(height: 10),
          const Text('Booking Service',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            selectedDateTime != null
                ? DateFormat.yMMMMd().add_jm().format(selectedDateTime)
                : 'Date & Time: Not Selected',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Text(
            selectedBookingType == BookingType.homeService
                ? 'Home Service'
                : 'In-Shop Service',
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
          const Divider(),
          if (hasServicesSelected && serviceNames.isNotEmpty)
            ...serviceNames.map((name) => Text(name,
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 16)))
          else
            const Text('No services selected',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontStyle: FontStyle.italic)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Total',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₱${estimatedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          const Text(
            'Final Price will be set after the service has been done',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
              fontFamily: 'Nunito', fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
                text: 'Need Help?\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: 'Contact us on Facebook or call:\n123-456-7890',
                style: TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime currentlyViewedDate) {
    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: startDate.isAtSameMomentAs(_getWeekStart(currentDate))
              ? null
              : () => navigateDate(false),
          splashRadius: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              DateTime date = startDate.add(Duration(days: index));
              bool isSelectedDateUI = date.year == currentlyViewedDate.year &&
                  date.month == currentlyViewedDate.month &&
                  date.day == currentlyViewedDate.day;
              bool isPast = date.isBefore(currentDate);

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        ref.read(_selectedDateProvider.notifier).state = date;
                        ref.read(_selectedDateTimeProvider.notifier).state =
                            null;
                      },
                child: Column(
                  children: [
                    Text(DateFormat.E().format(date),
                        style: const TextStyle(fontFamily: 'Nunito')),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: isPast
                              ? Colors.grey.shade300
                              : (isSelectedDateUI
                                  ? const Color(0xFF00AEEF)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(5),
                          border: isSelectedDateUI
                              ? null
                              : Border.all(color: Colors.grey.shade300)),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            color: isPast
                                ? Colors.grey.shade600
                                : (isSelectedDateUI
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronRight),
          onPressed: () => navigateDate(true),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildTimePicker(
      DateTime currentlyViewedDate, DateTime? currentlySelectedDateTime) {
    final unavailableSlotsAsync =
        ref.watch(unavailableSlotsProvider(currentlyViewedDate));

    return unavailableSlotsAsync.when(
      data: (unavailableTimes) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: timeSlots.map((timeStr) {
              final parts = timeStr.split(':');
              final hour = int.parse(parts[0]);
              final minute = int.parse(parts[1]);
              final potentialSlotDateTime = DateTime(
                  currentlyViewedDate.year,
                  currentlyViewedDate.month,
                  currentlyViewedDate.day,
                  hour,
                  minute);
              final now = DateTime.now();
              bool isPast = potentialSlotDateTime.isBefore(now);
              bool isUnavailable = unavailableTimes.contains(timeStr);
              bool isSelected = currentlySelectedDateTime != null &&
                  currentlySelectedDateTime
                      .isAtSameMomentAs(potentialSlotDateTime);
              bool isDisabled = isPast || isUnavailable;
              String displayTime =
                  DateFormat.jm().format(potentialSlotDateTime);

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () => ref.read(_selectedDateTimeProvider.notifier).state =
                        potentialSlotDateTime,
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? Colors.grey.shade300
                        : (isSelected
                            ? const Color(0xFF00AEEF)
                            : const Color(0xFFEFEFEF)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    displayTime,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        color: isDisabled
                            ? Colors.grey.shade600
                            : (isSelected ? Colors.white : Colors.black)),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, _) => Center(
          child: Text('Error loading slots: $err',
              style: const TextStyle(color: Colors.red))),
    );
  }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
