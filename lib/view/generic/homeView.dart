import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget buildServiceColumn(String imagePath, String text) {
      return SizedBox(
        width: size.width * .3,
        child: Column(
          children: [
            Image.asset(imagePath, height: 100),
            Text(text,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    Widget buildReviewColumn(String imagePath, String review) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(imagePath), fit: BoxFit.cover),
            ),
          ),
          Row(
            children: List.generate(
                5,
                (index) => Icon(Icons.star,
                    color: Color.fromARGB(255, 0, 174, 239), size: 20)),
          ),
          Text(review,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center),
        ],
      );
    }

    return Scaffold(
      appBar: Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6), BlendMode.darken),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: size.height * .9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo_white.png',
                            height: 300),
                        const SizedBox(height: 20),
                        const Text(
                          'Araw-araw kalidad. All-day quality services to your hard-earned investments.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 174, 239),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 30),
                            textStyle: const TextStyle(fontSize: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(100, 50, 0, 50),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 252, 215, 12),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                        child: Text(
                          'Why choose us?',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 99, 84, 0)),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'We protect and maintain your investments with our wide-range of services that we offer',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 174, 239)),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildServiceColumn('assets/icons/screen.png',
                                  'Computer Restoration'),
                              buildServiceColumn('assets/icons/gpu-mining.png',
                                  'GPU Maintenance'),
                              buildServiceColumn(
                                  'assets/icons/computer.png', 'PC Builds'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildServiceColumn('assets/icons/settings.png',
                                  'Computer Diagnosis'),
                              buildServiceColumn('assets/icons/laptop.png',
                                  'Laptop Maintenance'),
                              buildServiceColumn('assets/icons/processor.png',
                                  'Offers PC Components'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(100, 50, 0, 50),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 252, 215, 12),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                        child: Text(
                          'Guaranteed 5 Star Service',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 99, 84, 0)),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                      child: Text(
                        'JCSD has been trusted by over 200+ customers and businesses nationwide, plus over 205 5-Star reviews on Facebook!',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 174, 239)),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildReviewColumn('assets/avatars/cat1.jpg',
                          '"Very professional and accommodating\n10/10 Is informative... also humble and\nfriendly, which is much appreciated in\nthe community"'),
                      buildReviewColumn('assets/avatars/cat2.jpg',
                          '"JCSD provided excellent service\nrecently, deep cleaning my computer\nand shipping it. Thank you. Our team\nhighly recommends JCSD..."'),
                      buildReviewColumn('assets/avatars/cat3.jpg',
                          '"Highly recommended. Cares\nabout every client and gives tips\non how to improve your pcs\nperformance"'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width,
              height: size.height * .3,
              child: Container(
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 5, 31, 40)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(50, 50, 50, 10),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Address: ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    TextSpan(
                                      text:
                                          'Purok 4 block 3, Panacan Relocation, Davao City, Philippines 8000',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(50, 10, 50, 10),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Contact Number: ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: '0976 074 7797',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(50, 10, 50, 10),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Operating Hours: ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: '8:00 AM - 10:00 PM',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset('assets/images/logo_white.png',
                                  height: 50),
                              const Text('Araw-araw Kalidad.',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                        color: Colors.white,
                        thickness: 1,
                        indent: 50,
                        endIndent: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                          child: Text(
                            '© 2023 JCSD Online. All rights reserved.',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(.7)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 50, 0),
                          child: Row(
                            children: [
                              Text(
                                'Follow our Socials!',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(.7)),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.facebook,
                                    color: Colors.white.withOpacity(.7)),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.one_x_mobiledata,
                                    color: Colors.white.withOpacity(.7)),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.play_circle_fill,
                                    color: Colors.white.withOpacity(.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
