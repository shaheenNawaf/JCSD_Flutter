import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'package:intl/intl.dart';

class ClientBooking1 extends StatefulWidget {
  const ClientBooking1({super.key});

  @override
  State<ClientBooking1> createState() => _ClientBooking1State();
}

class _ClientBooking1State extends State<ClientBooking1> {
  bool isHomeServiceSelected = false;

  DateTime currentDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  String? selectedTime;

  // Dummy data only, list of services should be fetched on backend
  List<String> services = [
    'Computer Repair',
    'GPU Maintenance',
    'Computer Diagnosis',
    'Laptop Maintenance',
    'Nails'
  ];

  // First service in list to show up would be selected as default here
  List<String> selectedServices = ['Computer Repair'];

  // Navigation of dates are by one date, contemplating if I should also include month on frontend
  void navigateDate(bool isNext) {
    setState(() {
      startDate = isNext
          ? startDate.add(const Duration(days: 1))
          : startDate.subtract(const Duration(days: 1));

      // User cannot select past dates before current date
      if (startDate.isBefore(currentDate)) {
        startDate = currentDate;
      }

      selectedDate = startDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: ScrollConfiguration(
        behavior: NoScrollGlowBehavior(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFDFDFDF),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select services',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              runSpacing: 10,
                              spacing: 10,
                              children: services.map((service) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedServices.contains(service)) {
                                        selectedServices.remove(service);
                                      } else {
                                        selectedServices.add(service);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedServices.contains(service)
                                          ? const Color(0xFF00AEEF)
                                          : const Color(0xFFEFEFEF),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      service,
                                      style: TextStyle(
                                        color:
                                            selectedServices.contains(service)
                                                ? Colors.white
                                                : Colors.black,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select a slot',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Select Date',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    navigateDate(false);
                                  },
                                  icon: const FaIcon(
                                      FontAwesomeIcons.chevronLeft),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      7,
                                      (index) {
                                        DateTime date = startDate
                                            .add(Duration(days: index));
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedDate = date;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Text(
                                                DateFormat.E().format(date),
                                                style: const TextStyle(
                                                    fontFamily: 'Nunito'),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: date == selectedDate
                                                      ? const Color(0xFF00AEEF)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  '${date.day}',
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    color: date == selectedDate
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    navigateDate(true);
                                  },
                                  icon: const FaIcon(
                                      FontAwesomeIcons.chevronRight),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Select Time',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  '9:00',
                                  '10:00',
                                  '11:00',
                                  '12:00',
                                  '1:00',
                                  '2:00',
                                  '3:00',
                                  '4:00',
                                  '5:00'
                                ].map((time) {
                                  int hour = int.parse(time.split(':')[0]);
                                  bool isPM = [
                                    '1:00',
                                    '2:00',
                                    '3:00',
                                    '4:00',
                                    '5:00'
                                  ].contains(time);
                                  if (isPM && hour != 12) hour += 12;

                                  bool isDisabled =
                                      selectedDate.day == currentDate.day &&
                                          hour <= currentDate.hour;

                                  return GestureDetector(
                                    onTap: isDisabled
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedTime = time;
                                            });
                                          },
                                    child: Container(
                                      width: 108,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: isDisabled
                                            ? Colors.grey
                                            : (selectedTime == time
                                                ? const Color(0xFF00AEEF)
                                                : const Color(0xFFEFEFEF)),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color: isDisabled
                                              ? Colors.white
                                              : (selectedTime == time
                                                  ? Colors.white
                                                  : Colors.black),
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isHomeServiceSelected = !isHomeServiceSelected;
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isHomeServiceSelected,
                                onChanged: (value) {
                                  setState(() {
                                    isHomeServiceSelected = value!;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service to be done at your home',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'This will cost you an additional fee',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Add notes for the service',
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Contents inside receipt dynamically changes now depending on user selection
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Image.asset(
                              'assets/images/logo.png',
                              height: 50,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Booking Service',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              DateFormat.yMMMMd().format(selectedDate),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isHomeServiceSelected
                                  ? 'Home Service'
                                  : 'In-Shop Service',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: selectedServices
                                  .map((service) => Text(
                                        service,
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 16,
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const Divider(),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                /* Price should dynamically change upon user selection of service/s
                                their prices should be fetched from backend and 
                                should automatically calculate and total*/
                                Text(
                                  'P1,500',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 130),
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/booking2');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00AEEF),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    textStyle: const TextStyle(
                                        fontSize: 16, fontFamily: 'Nunito'),
                                  ),
                                  child: const Text(
                                    'Continue',
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
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        height: 192,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Need Help?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '\nContact us at Facebook or call using this number\n12312413525454324',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
