import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';

class homePageForyou extends StatefulWidget {
  const homePageForyou({super.key});

  @override
  State<homePageForyou> createState() => _homePageForyouState();
}

class _homePageForyouState extends State<homePageForyou> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Image.asset(
      //     'assets/images/SS_LOGO.png',
      //     width: 190,
      //     height: 40,
      //   ),
        // actions: [
        //   Container(
        //       width: 40,
        //       height: 40,
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(30),
        //           border: Border.all(color: Colors.grey)),
        //       child: Icon(Icons.search)),
        //   Padding(
        //     padding: const EdgeInsets.only(left: 10, right: 20),
        //     child: InkWell(
        //       onTap: () async {
        //         await FirebaseAuth.instance.signOut().then(
        //           (value) {
        //             Navigator.pushReplacement(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => AnimatedSplashScreen(),
        //                 ));
        //           },
        //         );
        //       },
        //       child: Container(
        //           width: 40,
        //           height: 40,
        //           decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(30),
        //               border: Border.all(color: Colors.grey)),
        //           child: Icon(Icons.logout)),
        //     ),
        //   )
        // ],
      // ),
    );
  }
}
