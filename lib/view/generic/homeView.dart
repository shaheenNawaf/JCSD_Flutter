import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var isMobile = size.width < 600;

    Widget buildServiceColumn(String imagePath, String text) {
      return SizedBox(
        width: size.width * .3,
        child: Column(
          children: [
            Image.asset(imagePath, height: isMobile ? 50 : 100),
            Text(text,
                style:
                    TextStyle(fontSize: isMobile ? 10 : 20, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    Widget buildReviewColumn(String imagePath, String review, bool isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 70 : 100,
            height: isMobile ? 70 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(imagePath), fit: BoxFit.cover),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
                5,
                (index) => const Icon(Icons.star,
                    color: Color.fromARGB(255, 0, 174, 239), size: 20)),
          ),
          Text(review,
              style: TextStyle(fontSize: isMobile ? 12 : 16),
              textAlign: TextAlign.center),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var isMobile = size.width < 600;
        return Scaffold(
          appBar: const Navbar(),
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
                          image: const AssetImage('assets/images/background.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6), BlendMode.darken),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: size.height * .9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo_white.png',
                                height: isMobile ? 100 : 300),
                            const SizedBox(height: 20),
                             Text(
                              isMobile ? 'Araw-araw kalidad.': 'Araw-araw kalidad. All-day quality services to your hard-earned investments.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 20 :30,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 174, 239),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 30: 50, vertical: isMobile ? 20 : 30),
                                textStyle: TextStyle(fontSize: isMobile ? 20 : 40),
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
                  height: isMobile ? size.height*1.1:size.height,
                  child: Column(
                    mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center :CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: isMobile ? const EdgeInsets.fromLTRB(0, 50, 0, 50):const EdgeInsets.fromLTRB(100, 50, 0, 50),
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
                       Center(
                        child: Text(
                          'We protect and maintain your investments with our wide-range of services that we offer',
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 174, 239)),
                          textAlign: TextAlign.center,
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
                              if (!isMobile)
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
                              if (!isMobile)
                              buildServiceColumn('assets/icons/processor.png',
                                'Offers PC Components'),
                            ],
                            ),
                          ),
                          if (isMobile)
                            Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              buildServiceColumn(
                                'assets/icons/computer.png', 'PC Builds'),
                              buildServiceColumn('assets/icons/processor.png',
                                'Offers PC Components'),
                              ],
                            ),
                            ),
                          ],
                        ),
                        ),
                      Padding(
                        padding: isMobile ? const EdgeInsets.fromLTRB(0, 50, 0, 50):const EdgeInsets.fromLTRB(100, 50, 0, 50),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 252, 215, 12),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child:  Padding(
                            padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                            child: Text(
                              'Guaranteed 5 Star Service',
                              style: TextStyle(
                                  fontSize: isMobile ? 20 : 25,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 99, 84, 0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                        child: Text(
                          'JCSD has been trusted by over 200+ customers and businesses nationwide, plus over 205 5-Star reviews on Facebook!',
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 174, 239),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isMobile)
                        Column(
                          children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                            height: isMobile ? 200 : 300,
                            child: Stack(
                              children: [
                              PageView.builder(
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                final reviews = [
                                  buildReviewColumn('assets/avatars/cat1.jpg',
                                  '"Very professional and accommodating\n10/10 Is informative... also humble and\nfriendly, which is much appreciated in\nthe community"', isMobile),
                                  buildReviewColumn('assets/avatars/cat2.jpg',
                                  '"JCSD provided excellent service\nrecently, deep cleaning my computer\nand shipping it. Thank you. Our team\nhighly recommends JCSD..."', isMobile),
                                  buildReviewColumn('assets/avatars/cat3.jpg',
                                  '"Highly recommended. Cares\nabout every client and gives tips\non how to improve your pcs\nperformance"', isMobile),
                                ];
                                return reviews[index];
                                },
                                controller: PageController(
                                viewportFraction: 1,
                                initialPage: 0,
                                ),
                                onPageChanged: (index) {
                                // Handle page change if needed
                                },
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Visibility(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_left, size: 40),
                                  onPressed: () {
                                  PageController().previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  },
                                ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Visibility(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_right, size: 40),
                                  onPressed: () {
                                  PageController().nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  },
                                ),
                                ),
                              ),
                              ],
                            ),
                            ),
                          ),
                          ],
                        )
                        else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          buildReviewColumn('assets/avatars/cat1.jpg',
                            '"Very professional and accommodating\n10/10 Is informative... also humble and\nfriendly, which is much appreciated in\nthe community"', isMobile),
                          buildReviewColumn('assets/avatars/cat2.jpg',
                            '"JCSD provided excellent service\nrecently, deep cleaning my computer\nand shipping it. Thank you. Our team\nhighly recommends JCSD..."', isMobile),
                          buildReviewColumn('assets/avatars/cat3.jpg',
                            '"Highly recommended. Cares\nabout every client and gives tips\non how to improve your pcs\nperformance"', isMobile),
                          ],
                        ),
                    ],
                  ),
                ),

                if (isMobile)
                  SizedBox(
                  width: size.width,
                  height: size.height * .6,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 5, 31, 40)),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Center(
                            child: Image.asset('assets/images/logo_white.png',
                              height: 50),
                          ),
                        ),
                        RichText(
                          text: const TextSpan(
                          children: [
                            TextSpan(
                            text: 'Address: \n',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                            ),
                            TextSpan(
                            text:
                              'Purok 4 block 3, Panacan \nRelocation, Davao City, \nPhilippines 8000',
                            style: TextStyle(
                              fontSize: 15,
                                fontWeight: FontWeight.w100,
                              color: Colors.white),
                            ),
                          ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: const TextSpan(
                          children: [
                            TextSpan(
                            text: 'Contact Number: \n',
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
                        const SizedBox(height: 10),
                        RichText(
                          text: const TextSpan(
                          children: [
                            TextSpan(
                            text: 'Operating Hours: \n',
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
                        ],
                      ),
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20),
                      Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          '© 2023 JCSD Online. All rights reserved.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(.7)),
                        ),
                        const SizedBox(height: 10),
                        Row(
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
                        ],
                      ),
                      ),
                    ],
                    ),
                  ),
                  )
                else
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
    );
  }
}
