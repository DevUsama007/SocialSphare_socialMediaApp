import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:social_sphere/homepage.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/get_postData.dart';
import 'package:social_sphere/introductionScreens/introductionScreen.dart';
import 'package:social_sphere/main.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  User? _user;

  String? _uid;

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
    print(_uid);
    print("uiser id asafdslfjasdkl fasdjklfjasdl");
  }

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });

    // Once the animation completes, navigate to the desired screen
    _controller.addStatusListener((status) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => _uid == Null || _uid == null
                  ? CustomIntroductionScreen()
                  : Homepage()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 249, 98, 46),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          // height: 700,
          width: MediaQuery.of(context).size.width,

          // decoration: BoxDecoration(color: ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image(
                    width: 300,
                    height: 300,
                    image: AssetImage("assets/images/SS_LOGO2.png")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
