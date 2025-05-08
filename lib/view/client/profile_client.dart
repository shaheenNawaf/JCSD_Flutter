// lib/view/client/profile_client.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart'; // If needed for navigation from here
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart'; // For supabaseDB
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_state.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart'; // For service names
import 'package:jcsd_flutter/view/bookings/modals/receipt.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'package:shimmer/shimmer.dart'; // For loading state

// Provider to fetch a single account by userID (for profile display)
final userProfileDataProvider =
    FutureProvider.autoDispose<AccountsData?>((ref) async {
  final user = supabaseDB.auth.currentUser;
  if (user == null) return null;
  try {
    final response = await supabaseDB
        .from('accounts')
        .select()
        .eq('userID', user.id)
        .maybeSingle();
    if (response != null) {
      return AccountsData.fromJson(response);
    }
    return null;
  } catch (e) {
    print("Error fetching user profile: $e");
    return null;
  }
});

class ProfilePageClient extends ConsumerStatefulWidget {
  const ProfilePageClient({super.key});

  @override
  ConsumerState<ProfilePageClient> createState() => _ProfilePageClientState();
}

class _ProfilePageClientState extends ConsumerState<ProfilePageClient> {
  // No need for local userProfile, will use userProfileDataProvider
  Booking? _selectedBookingForModal; // To hold data for the details modal

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = supabaseDB.auth.currentUser?.id;
      if (userId != null) {
        // Fetch bookings for the current user
        ref
            .read(bookingListNotifierProvider.notifier)
            .applyFilters(customerUserId: userId);
      } else {
        // Handle case where user is not logged in, though GoRouter should prevent this
        print("ProfilePageClient: User not logged in!");
      }
    });
  }

  String display(String? val) {
    if (val == null || val.trim().isEmpty) return "N/A";
    return val;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat.yMMMMd().format(date); // Example: January 5, 2023
  }

  void _showReceiptModal(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: true, // Receipt can be dismissed
      builder: (BuildContext context) {
        return ReceiptModal(booking: booking);
      },
    );
  }

  void _showBookingDetailsModal(
      BuildContext context, WidgetRef ref, Booking booking) {
    // Fetch service names for display in the modal
    final allServicesAsync = ref.watch(fetchAvailableServices);
    final serviceNameMap = allServicesAsync.asData?.value
            .fold<Map<int, String>>(
                {},
                (map, service) =>
                    map..[service.serviceID] = service.serviceName) ??
        {};

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: ConstrainedBox(
            // To control modal size
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width *
                    (MediaQuery.of(context).size.width > 600 ? 0.4 : 0.9),
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              // Make modal content scrollable
              child: _buildBookingDetailsContent(
                  dialogContext, booking, serviceNameMap),
            ),
          ),
        );
      },
    );
  }

  // Content for the booking details modal
  Widget _buildBookingDetailsContent(BuildContext dialogContext,
      Booking booking, Map<int, String> serviceNameMap) {
    String serviceNames = booking.bookingServices
            ?.map((bs) =>
                serviceNameMap[bs.serviceId] ?? 'Service ID: ${bs.serviceId}')
            .join(', ') ??
        'N/A';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Booking Details",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito')),
          const Divider(),
          _buildModalInfoRow("Booking ID:", booking.id.toString()),
          _buildModalInfoRow("Date & Time:",
              DateFormat.yMMMEd().add_jm().format(booking.scheduledStartTime)),
          _buildModalInfoRow("Service(s):", serviceNames),
          _buildModalInfoRow(
              "Type:",
              booking.bookingType.name
                  .replaceAllMapped(
                      RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                  .trim()),
          _buildModalInfoRow(
              "Status:",
              booking.status.name
                  .replaceAllMapped(
                      RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                  .trim()),
          if (booking.customerNotes != null &&
              booking.customerNotes!.isNotEmpty)
            _buildModalInfoRow("Your Notes:", booking.customerNotes!),
          if (booking.employeeNotes != null &&
              booking.employeeNotes!.isNotEmpty)
            _buildModalInfoRow("Shop Notes:", booking.employeeNotes!),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Estimated Total:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 16)),
              Text(
                  "₱${(booking.finalTotalPrice ?? booking.bookingServices?.fold(0.0, (sum, item) => sum! + (item.finalPrice ?? item.estimatedPrice)) ?? 0.0).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          if (booking.status == BookingStatus.completed || booking.isPaid)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(); // Close details modal first
                  _showReceiptModal(booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final userProfileAsync = ref.watch(userProfileDataProvider);
    final bookingListAsync = ref.watch(bookingListNotifierProvider);

    return Scaffold(
      appBar: const Navbar(
          activePage:
              'profile'), // Assuming 'profile' is the route for this page
      body: LayoutBuilder(builder: (context, constraints) {
        if (!isMobile) {
          // --- Desktop View ---
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFDFDFDF),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1, // Profile section
                  child: userProfileAsync.when(
                    data: (profile) => _buildProfileSection(profile),
                    loading: () => _buildProfileShimmer(),
                    error: (err, _) =>
                        Center(child: Text("Error loading profile: $err")),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2, // Bookings list section
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("My Booking Appointments",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'NunitoSans')),
                        const SizedBox(height: 10),
                        Expanded(
                          child: bookingListAsync.when(
                            data: (bookingState) => _buildBookingsList(
                                bookingState.bookings,
                                isMobile: false),
                            loading: () => _buildBookingsListShimmer(
                                itemCount: 3, isMobile: false),
                            error: (err, _) => Center(
                                child: Text("Error loading bookings: $err")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // --- Mobile View ---
          return Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFDFDFDF),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10), // Reduced padding for mobile
              child: SingleChildScrollView(
                // Make the whole mobile view scrollable
                child: Column(children: [
                  userProfileAsync.when(
                    data: (profile) => _buildProfileSection(profile),
                    loading: () => _buildProfileShimmer(),
                    error: (err, _) =>
                        Center(child: Text("Error loading profile: $err")),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("My Booking Appointments",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'NunitoSans')),
                        const SizedBox(height: 10),
                        bookingListAsync.when(
                          data: (bookingState) => _buildBookingsList(
                              bookingState.bookings,
                              isMobile: true),
                          loading: () => _buildBookingsListShimmer(
                              itemCount: 2, isMobile: true),
                          error: (err, _) => Center(
                              child: Text("Error loading bookings: $err")),
                        ),
                      ],
                    ),
                  ),
                ]),
              ));
        }
      }),
    );
  }

  Widget _buildProfileSection(AccountsData? userProfile) {
    if (userProfile == null) {
      return Container(
          // Fallback for null profile
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Text("Profile not available.")));
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(userProfile),
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          _buildInfoRow(
              FontAwesomeIcons.envelope, 'Email: ', display(userProfile.email)),
          _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ',
              display(userProfile.contactNumber)),
          _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
              formatDate(userProfile.birthDate)),
          _buildDivider(),
          _buildSectionTitle('Address'),
          _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
              display(userProfile.address)),
          _buildInfoRow(
              FontAwesomeIcons.city, 'City: ', display(userProfile.city)),
          _buildInfoRow(FontAwesomeIcons.mapMarkedAlt, 'Province: ',
              display(userProfile.province)),
          _buildInfoRow(FontAwesomeIcons.globe, 'Country: ',
              display(userProfile.country)),
          _buildInfoRow(FontAwesomeIcons.mapPin, 'Zip Code: ',
              display(userProfile.zipCode)),
          // Add more profile details if needed
        ],
      ),
    );
  }

  Widget _buildProfileShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 150, height: 20, color: Colors.white),
                const SizedBox(height: 5),
                Container(width: 100, height: 15, color: Colors.white),
              ])
            ]),
            const SizedBox(height: 20),
            Container(
                width: 100, height: 20, color: Colors.white), // Section Title
            const SizedBox(height: 10),
            _buildShimmerInfoRow(), _buildShimmerInfoRow(),
            _buildShimmerInfoRow(),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Container(
                width: 120, height: 20, color: Colors.white), // Section Title
            const SizedBox(height: 10),
            _buildShimmerInfoRow(), _buildShimmerInfoRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        Container(width: 20, height: 20, color: Colors.white),
        const SizedBox(width: 10),
        Container(width: 80, height: 15, color: Colors.white),
        const SizedBox(width: 5),
        Expanded(child: Container(height: 15, color: Colors.white)),
      ]),
    );
  }

  Widget _buildProfileHeader(AccountsData userProfile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Text(
            (userProfile.firstName.isNotEmpty ? userProfile.firstName[0] : "") +
                (userProfile.lastname.isNotEmpty
                    ? userProfile.lastname[0]
                    : ""),
            style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              display("${userProfile.firstName} ${userProfile.lastname}"),
              style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Text(
              display(
                  userProfile.email), // Assuming email is part of AccountsData
              style: const TextStyle(
                  fontFamily: 'NunitoSans', fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 10.0), // Adjusted padding
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6.0), // Added vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 15),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NunitoSans',
                  fontSize: 14)), // Bolder label
          const SizedBox(width: 5),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(fontFamily: 'NunitoSans', fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        color: Colors.grey[300], thickness: 0.5, height: 30); // Thinner divider
  }

  Widget _buildBookingsList(List<Booking> bookings, {required bool isMobile}) {
    if (bookings.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("You have no bookings yet.",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      ));
    }

    // Fetch service names map once
    final allServicesAsync = ref.watch(fetchAvailableServices);
    final serviceNameMap = allServicesAsync.asData?.value
            .fold<Map<int, String>>(
                {},
                (map, service) =>
                    map..[service.serviceID] = service.serviceName) ??
        {};

    return ListView.builder(
      shrinkWrap:
          true, // Important if inside another scrollable or fixed height container
      physics: isMobile
          ? const NeverScrollableScrollPhysics()
          : null, // Disable scrolling for mobile if inside SingleChildScrollView
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        String serviceNames = booking.bookingServices
                ?.map((bs) =>
                    serviceNameMap[bs.serviceId] ??
                    'Service ID: ${bs.serviceId}')
                .join(', ') ??
            'N/A';
        if (serviceNames.length > 50 && !isMobile) {
          serviceNames = "${serviceNames.substring(0, 47)}...";
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 0), // No horizontal margin for list items
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            title: Text(
              serviceNames,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NunitoSans',
                  fontSize: 15),
              maxLines: isMobile ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                    DateFormat.yMMMEd()
                        .add_jm()
                        .format(booking.scheduledStartTime),
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', fontSize: 13)),
                Text(
                    booking.bookingType.name
                        .replaceAllMapped(
                            RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                        .trim(),
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', fontSize: 13)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusChip(booking.status),
                if (isMobile) const SizedBox(height: 4),
                if (isMobile)
                  SizedBox(
                    height: 28,
                    child: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child:
                          const Text("Details", style: TextStyle(fontSize: 12)),
                      onPressed: () =>
                          _showBookingDetailsModal(context, ref, booking),
                    ),
                  )
              ],
            ),
            onTap: isMobile
                ? null
                : () => _showBookingDetailsModal(
                    context, ref, booking), // Only allow tap on desktop
          ),
        );
      },
    );
  }

  Widget _buildBookingsListShimmer(
      {required int itemCount, required bool isMobile}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: isMobile ? const NeverScrollableScrollPhysics() : null,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              title: Container(
                  width: double.infinity, height: 18, color: Colors.white),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 14,
                      color: Colors.white),
                  const SizedBox(height: 4),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 14,
                      color: Colors.white),
                ],
              ),
              trailing: Container(
                  width: 70,
                  height: 25,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4))),
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(BookingStatus status) {
    Color chipColor;
    String chipText = status.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();

    switch (status) {
      case BookingStatus.pendingConfirmation:
        chipColor = Colors.orange.shade600;
        break;
      case BookingStatus.confirmed:
        chipColor = Colors.blue.shade600;
        break;
      case BookingStatus.inProgress:
        chipColor = Colors.cyan.shade600;
        break;
      case BookingStatus.completed:
        chipColor = Colors.green.shade600;
        break;
      case BookingStatus.cancelled:
        chipColor = Colors.red.shade600;
        break;
      case BookingStatus.noShow:
        chipColor = Colors.grey.shade600;
        break;
      case BookingStatus.pendingAdminApproval:
        chipColor = Colors.purple.shade600;
        break;
      case BookingStatus.pendingPayment:
        chipColor = Colors.amber.shade700;
        break;
      default:
        chipColor = Colors.black45;
    }
    return Chip(
      label: Text(chipText,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
    );
  }
}
