import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:social_sphere/homepage_screens/addPost.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/get_postData.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/short_video_screen/short_videos.dart';
import 'package:social_sphere/homepage_screens/homepage_foryou.dart';
import 'package:social_sphere/homepage_screens/user_profile_list.dart';
import 'package:social_sphere/profile_view/my_posts.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:social_sphere/register&login&splashScreen/login.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';
import 'package:social_sphere/suggestion&following/getFollowinglist.dart';
import 'package:social_sphere/suggestion&following/suggestionUserProfile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  User? _user;
  String? _uid;

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
    ;
    print(_uid);

    // fetchUserData();
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCurrentUser();
    super.initState();
  }

  int ind = 1;
  @override
  Widget build(BuildContext context) {
    print(_controller.index);
    return Scaffold(
     

      body: PersistentTabView(
        screenTransitionAnimation:
            ScreenTransitionAnimation(curve: Curves.decelerate),
        backgroundColor: Colors.white,
        tabs: [
          PersistentTabConfig(
            screen: getPostData(),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 249, 98, 46),
              icon: Icon(Icons.home),
            ),
          ),
          PersistentTabConfig(
            screen: ShortVideoFollowed(),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 249, 98, 46),
              icon: Icon(Icons.video_collection),
            ),
          ),
          PersistentTabConfig(
            screen: Addpost(),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 249, 98, 46),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          PersistentTabConfig(
            screen: UserProfile(),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 249, 98, 46),
              icon: Icon(Icons.people),
            ),
          ),
          PersistentTabConfig(
            screen: myProfile(
              uid: _uid.toString(),
            ),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 249, 98, 46),
              icon: Icon(Icons.person_3_rounded),
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => Style15BottomNavBar(
          navBarDecoration:
              NavBarDecoration(borderRadius: BorderRadius.circular(20)),
          navBarConfig: navBarConfig,
        ),
      ),
    );
  }
}
