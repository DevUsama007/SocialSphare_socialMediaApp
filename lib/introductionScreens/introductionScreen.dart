import 'package:flutter/material.dart';
import 'package:social_sphere/introductionScreens/get_started.dart';
import 'package:social_sphere/main.dart';

class CustomIntroductionScreen extends StatefulWidget {
  @override
  _CustomIntroductionScreenState createState() =>
      _CustomIntroductionScreenState();
}

class _CustomIntroductionScreenState extends State<CustomIntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 246, 246, 246),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  IntroPage(
                    imagePath: 'assets/images/2.png',
                    text: 'See What Your Connections Are Sharing',
                  ),
                  IntroPage2(
                    key: null,
                  ),
                  IntroPage3(
                    key: null,
                  ),
                ],
              ),
            ),
            _buildIndicators(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3, // Number of pages
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          width: _currentPage == index ? 20.0 : 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Color.fromARGB(255, 249, 98, 46)
                : Color.fromARGB(255, 250, 173, 148),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _currentPage > 0
            ? TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Icon(
                  Icons.arrow_circle_left,
                  size: 45,
                  color: Color.fromARGB(255, 249, 98, 46),
                ),
              )
            : SizedBox(width: 60), // Placeholder for spacing

        _currentPage < 2
            ? TextButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Container(
                  child: Icon(
                    Icons.arrow_circle_right_sharp,
                    color: Color.fromARGB(255, 249, 98, 46),
                    size: 45,
                  ),
                ),
              )
            : TextButton(
                onPressed: () {
                  // SharedPreferences prefs =
                  //     await SharedPreferences.getInstance();
                  // await prefs.setBool('seen', true);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => get_started()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(color: Color.fromARGB(255, 249, 98, 46)),
                ),
              ),
      ],
    );
  }
}

class IntroPage extends StatelessWidget {
  final String imagePath;
  final String text;

  IntroPage({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/connections.png"))),
      child: Column(
        children: [
          Container(
            color: Color.fromARGB(255, 246, 246, 246),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => get_started(),
                        ));
                  },
                  child: Text(
                    "skip     ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "inter",
                        color: Color.fromARGB(255, 249, 98, 46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage2 extends StatelessWidget {
  IntroPage2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/explore_profile4.png"))),
      child: Column(
        children: [
          Container(
            color: Color.fromARGB(255, 246, 246, 246),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => get_started(),
                        ));
                  },
                  child: Text(
                    "skip     ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "inter",
                        color: Color.fromARGB(255, 249, 98, 46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage3 extends StatelessWidget {
  IntroPage3({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/short_video3.png"))),
      child: Column(
        children: [
          Container(
            color: Color.fromARGB(255, 246, 246, 246),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => get_started(),
                        ));
                  },
                  child: Text(
                    "skip     ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "inter",
                        color: Color.fromARGB(255, 249, 98, 46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
