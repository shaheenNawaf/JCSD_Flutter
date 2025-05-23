import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/bookings/booking_confirmed.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class ClientBooking2 extends StatelessWidget {
  const ClientBooking2({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: Container(
        color: const Color(0xFFDFDFDF),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isMobile
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFullWidthContainer(_buildReviewAndConfirmSection()),
                    const SizedBox(height: 20),
                    _buildFullWidthContainer(_buildBookingSummary(context)),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildReviewAndConfirmSection(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: _buildBookingSummary(context),
                  ),
                ],
              ),
      ),
    );
  }

  void _BookingConfirmationModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const BookingConfirmationModal();
      },
    );
  }

  Widget _buildFullWidthContainer(Widget child) {
    return SizedBox(
      width: double.infinity,
      child: child,
    );
  }

  Widget _buildReviewAndConfirmSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Review and confirm",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Cancellation policy",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text:
                      "Cancel for free anytime in advance, otherwise you will be charged ",
                ),
                TextSpan(
                  text: "\n100% ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "of the service price for not showing up.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Item Policy",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Some other terms of condition",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 50,
          ),
          const SizedBox(height: 10),
          const Text(
            "Booking Service",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Sun 16 July 2023 at 5:00pm",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              fontSize: 16,
            ),
          ),
          const Divider(),
          const Text(
            "Booking Notes:",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Text(
            " Please help",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
            ),
          ),
          const Divider(),
          const Text(
            "Service Location:",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Text(
            " In-store Service",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
            ),
          ),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Computer Repair",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
              Text(
                "P1,500",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
              Text(
                "INR 900",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 200),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/profileClient');
                  _BookingConfirmationModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      const TextStyle(fontSize: 16, fontFamily: 'Nunito'),
                ),
                child: const Text(
                  'Book Now!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
