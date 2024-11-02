import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class ClientBooking1 extends StatefulWidget {
  const ClientBooking1({super.key});

  @override
  State<ClientBooking1> createState() => _ClientBooking1State();
}

class _ClientBooking1State extends State<ClientBooking1> {
  bool isHomeServiceSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: Container(
        width: double.infinity,
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
                            spacing: 10,
                            children: [
                              const Chip(
                                label: Text('Computer Repair'),
                                backgroundColor: Color(0xFF00AEEF),
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              ...[
                                'GPU Maintenance',
                                'Computer Diagnosis',
                                'Laptop Maintenance',
                                'Nails'
                              ].map((service) => Chip(
                                    label: Text(service),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Nunito',
                                    ),
                                  )),
                            ],
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              7,
                              (index) => Column(
                                children: [
                                  Text(
                                    [
                                      'Sun',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat'
                                    ][index],
                                    style:
                                        const TextStyle(fontFamily: 'Nunito'),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? const Color(0xFF00AEEF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '${16 + index}',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          Wrap(
                            spacing: 10,
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
                            ]
                                .map((time) => Chip(
                                      label: Text(time),
                                      backgroundColor: time == '9:00'
                                          ? const Color(0xFF00AEEF)
                                          : const Color(0xFFEFEFEF),
                                      labelStyle: TextStyle(
                                        color: time == '9:00'
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Nunito',
                                      ),
                                    ))
                                .toList(),
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
                          GestureDetector(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Add notes for the service',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
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
                          const Text(
                            'September 20, 2024',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Home Service',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 16),
                          ),
                          const Divider(),
                          const Text(
                            'Computer Repair',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 16),
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/booking2');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AEEF),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 100),
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
    );
  }
}
