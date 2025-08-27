import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:social_sphere/firebase_options.dart';
import 'package:social_sphere/introductionScreens/introductionScreen.dart';
import 'package:social_sphere/register&login&splashScreen/complete_profile.dart';
import 'package:social_sphere/register&login&splashScreen/register.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';
import 'package:sound_library/sound_library.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 249, 98, 46),
                foregroundColor: Colors.white,
                // primary: Colors.deepPurple, // This sets the background color
                // onPrimary: Colors.white, // This sets the text color
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            iconTheme: IconThemeData(color: Color.fromARGB(255, 121, 121, 121)),
            // scaffoldBackgroundColor: Color.fromARGB(255, 246, 246, 246),
            scaffoldBackgroundColor: Color.fromARGB(255, 246, 246, 246),
            appBarTheme: AppBarTheme(color: Color.fromARGB(255, 246, 246, 246)),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              headlineMedium: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )),
        home: AnimatedSplashScreen()
        // home: CreatePostScreen(
        //   currentUserId: '112244',
        // ),
        );
  }
}
