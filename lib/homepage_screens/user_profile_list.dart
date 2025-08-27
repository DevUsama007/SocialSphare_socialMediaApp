import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:social_sphere/suggestion&following/getFollowinglist.dart';
import 'package:social_sphere/suggestion&following/suggestionUserProfile.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final suggestionList = FirebaseFirestore.instance
      .collection('User_Profile')
      .where("followedbyUserId")
      .snapshots();

  final follow = FirebaseFirestore.instance.collection('following');
  TextEditingController searchText = TextEditingController();
  User? _user;
  String? _uid;

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });

    print(_uid);
  }

  Message info = Message();
  bool working = false;
  followUser(String userID) {
    setState(() {
      working = true;
    });
    print(userID);
    print(_uid.toString());
    try {
      var documentID = userID + _uid.toString();
      follow.doc(documentID).set({
        "documentId": documentID,
        "userID": userID.toString(),
        "followedbyUserId": _uid.toString(),
      }).then(
        (value) {
          setState(() {
            working = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Followed',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
              duration: Duration(seconds: 2),
              showCloseIcon: true,
              backgroundColor: Color.fromARGB(255, 249, 98, 46),
            ),
          );
        },
      ).onError(
        (error, stackTrace) {
          setState(() {
            working = false;
          });
          info.infoMessage(context, "Failed", error.toString());
        },
      );
    } catch (e) {
      setState(() {
        working = false;
      });
      info.infoMessage(context, "Error", "Check Your Internet Connection");
    }
  }

  unfollowUser(String documentId) {
    FirebaseFirestore.instance.collection('following').doc(documentId).delete();
  }

  @override
  void initState() {
    _getCurrentUser();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Color.fromARGB(255, 249, 98, 46),
            overlayColor:
                WidgetStatePropertyAll(Color.fromARGB(255, 249, 98, 46)),
            indicatorColor: Color.fromARGB(255, 249, 98, 46),
            labelPadding: const EdgeInsets.only(
              bottom: 10,
            ),
            controller: _tabController,
            tabs: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text("Suggestions")],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text("Following")],
              ),
            ]),
        title: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50,
          child: TextFormField(
            controller: searchText,
            textAlign: TextAlign.start,
            cursorColor: Colors.grey,
            decoration: InputDecoration(
                hintStyle: TextStyle(
                    fontFamily: "inter",
                    color: Color.fromARGB(255, 121, 121, 121)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none
                    // Optional: for rounded corners
                    // borderSide: BorderSide(
                    //   color: Colors.grey, // Color of the border
                    //   width: 2.0, // Width of the border
                    // ),
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      12.0), // Optional: for rounded corners
                ),
                enabledBorder: InputBorder.none,
                fillColor: Color.fromARGB(255, 224, 223, 223),
                filled: true,
                hintText: "Search user profile",
                suffixIcon: Icon(Icons.search)),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [Suggestionuserprofile(), Getfollowinglist()],
      ),
    );
  }
}
