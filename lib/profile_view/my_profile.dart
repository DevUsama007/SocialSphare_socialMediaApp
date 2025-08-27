import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/introductionScreens/introductionScreen.dart';
import 'package:social_sphere/profile_view/edit_my_profile.dart';
import 'package:social_sphere/profile_view/my_posts.dart';
import 'package:social_sphere/profile_view/my_shorts.dart';
import 'package:social_sphere/register&login&splashScreen/complete_profile.dart';
import 'package:social_sphere/register&login&splashScreen/login.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';

class myProfile extends StatefulWidget {
  final String uid;

  const myProfile({super.key, required this.uid});
  @override
  _myProfileState createState() => _myProfileState();
}

class _myProfileState extends State<myProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    fetchData();
    // fetchUserData();
  }

  bool uploading = false;
  double _uploadProgress = 0.0;

  String? fieldValue;
  var username;
  var userImage;
  var name;
  var userAbout;
  var bio;
  var phonenumber;
  Future<void> fetchData() async {
    try {
      print(widget.uid.toString());
      print("id of the user si s");
      DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore
          .instance
          .collection('User_Profile')
          .doc(widget.uid.toString())
          .get();
      print(document.data());
      if (document.exists) {
        print(document.data()?['bio']);
        setState(() {
          bio = document.data()?['bio'];
          name = document.data()?['Name']; // Replace with your field name
          username =
              document.data()?['user_name']; // Replace with your field name
          userImage = document.data()?['profile_image_link'];
          phonenumber =
              document.data()?['phone']; // Replace with your field name
        });
        print("value does not found in the collection");
        print(name);
      } else {
        setState(() {
          fieldValue = 'Document does not exist';
        });
      }
    } catch (e) {
      setState(() {
        fieldValue = 'Error fetching data: $e';
      });
    }
  }

  Future _fetchPostCount() async {
    try {
      AggregateQuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('User_Posts')
          .where("userID", isEqualTo: widget.uid.toString())
          .count()
          .get();

      return postSnapshot.count;
    } catch (error) {
      print("Error getting post count");
      return 0;
    }
  }

  Stream<int> _postCountStream() {
    return FirebaseFirestore.instance
        .collection('User_Posts')
        .where("userID", isEqualTo: widget.uid.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _followingCountStream() {
    return FirebaseFirestore.instance
        .collection('following')
        .where("followedbyUserId", isEqualTo: widget.uid.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _followersCountStream() {
    return FirebaseFirestore.instance
        .collection('following')
        .where("userID", isEqualTo: widget.uid.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => EditMyProfile(
          uid: widget.uid.toString(),
          name: name.toString(),
          username: username.toString(),
          userbio: bio.toString(),
          userimagelink: userImage.toString(),
          userPHONE: phonenumber.toString()),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var reverseTween =
            Tween(begin: end, end: begin).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: SlideTransition(
            position: secondaryAnimation.drive(reverseTween),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(seconds: 1),
      reverseTransitionDuration: Duration(seconds: 1), // Reverse duration
    );
  }

  bool isFollow = false;
  Future<bool> isUserFollowing() async {
    try {
      // Query the Firestore collection where you store the following information
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('following')
          .where("userID", isEqualTo: widget.uid)
          .where('followedbyUserId', isEqualTo: _uid.toString())
          .get();

      // If the snapshot contains documents, it means the user is following the other user
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<void> unfollowUser(String userID) async {
    try {
      var documentID = userID + _uid.toString();
      print(documentID.toString());
      await FirebaseFirestore.instance
          .collection('following')
          .doc(documentID)
          .delete()
          .then(
        (value) {
          setState(() {
            isFollow = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unfollowed',
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
      );
    } catch (error) {
      print('failded');
    }
  }

  Message info = Message();

  final follow = FirebaseFirestore.instance.collection('following');
  bool working = false;

  Future<void> followUser(String userID) async {
    try {
      var documentID = userID + _uid.toString();
      await follow.doc(documentID).set({
        "documentId": documentID,
        "userID": userID.toString(),
        "followedbyUserId": _uid.toString(),
      }).then(
        (value) {
          setState(() {
            isFollow = true;
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
      );
    } catch (error) {
      info.infoMessage(context, "Failed", error.toString());
    }
  }

  @override
  void initState() {
    _getCurrentUser();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  Message mess = Message();
// update profile functions ends here

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              // collapsedHeight: 200,
              // expandedHeight: 380,
              toolbarHeight: 330,
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: 330,
                // decoration: BoxDecoration(
                //     image: DecorationImage(
                //         fit: BoxFit.cover,
                //         image: AssetImage('assets/images/profilebg2.jfif'))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          username == null ? Text("fetching") : Text(username),
                          Container()
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Stack(
                              children: [
                                Positioned(
                                    child: Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 224, 223, 223),
                                      image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: userImage == null
                                              ? AssetImage(
                                                  "assets/images/person_icon.png")
                                              : NetworkImage(userImage)),
                                      borderRadius: BorderRadius.circular(70)),
                                )),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                child: Column(
                                  children: [
                                    StreamBuilder<int>(
                                      stream: _postCountStream(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator(); // Show a loading indicator while waiting for the data
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error getting post count');
                                        } else if (!snapshot.hasData) {
                                          return Text('0');
                                        } else {
                                          int postCount = snapshot.data!;
                                          return Text('$postCount');
                                        }
                                      },
                                    ),
                                    Text(
                                      "Post",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 121, 121, 121),
                                          fontFamily: "inter",
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                child: VerticalDivider(
                                  width: 10,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Column(
                              children: [
                                StreamBuilder<int>(
                                  stream: _followersCountStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Show a loading indicator while waiting for the data
                                    } else if (snapshot.hasError) {
                                      return Text('Error getting post count');
                                    } else if (!snapshot.hasData) {
                                      return Text('0');
                                    } else {
                                      int followersCount = snapshot.data!;
                                      return Text(
                                        "$followersCount",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "inter",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  "Followers",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 121, 121, 121),
                                      fontFamily: "inter",
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            child: VerticalDivider(
                              width: 10,
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Column(
                              children: [
                                StreamBuilder<int>(
                                  stream: _followingCountStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Show a loading indicator while waiting for the data
                                    } else if (snapshot.hasError) {
                                      return Text('Error getting post count');
                                    } else if (!snapshot.hasData) {
                                      return Text('0');
                                    } else {
                                      int followingCount = snapshot.data!;
                                      return Text(
                                        "$followingCount",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "inter",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  "Following",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 121, 121, 121),
                                      fontFamily: "inter",
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        name == null ? "fetching" : name.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "inter",
                            fontSize: 14),
                      ),
                    ),
                    Text("Bio"),
                    Container(
                      height: 50,
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            bio == null
                                ? Center(
                                    child: Text(
                                      "Add Bio",
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: "inter",
                                          fontSize: 14),
                                    ),
                                  )
                                : Text(
                                    bio.toString(),
                                    // Allow unlimited lines
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "inter",
                                        fontSize: 14),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    _uid.toString() == widget.uid
                        ? Hero(
                            tag: 'editProfileScreen',
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.9,
                                      25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        16), // Change the radius here
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(_createRoute())
                                      .then(
                                    (value) {
                                      fetchData();
                                    },
                                  );
                                },
                                child: Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                      fontFamily: "inter", fontSize: 17),
                                )),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FutureBuilder<bool>(
                              future: isUserFollowing(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        // backgroundColor: Colors.grey,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                            25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16), // Change the radius here
                                        ),
                                      ),
                                      onPressed: null,
                                      child: Text(
                                        "Following",
                                        style: TextStyle(
                                            fontFamily: "inter", fontSize: 17),
                                      ));
                                } else if (snapshot.hasError) {
                                  return Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 18,
                                  );
                                } else {
                                  isFollow = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: () async {},
                                    child: isFollow == false
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  25),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    16), // Change the radius here
                                              ),
                                            ),
                                            onPressed: () {
                                              followUser(widget.uid.toString());
                                            },
                                            child: Text(
                                              "Follow",
                                              style: TextStyle(
                                                  fontFamily: "inter",
                                                  fontSize: 17),
                                            ))
                                        : InkWell(
                                            onTap: () {
                                              unfollowUser(
                                                  widget.uid.toString());
                                            },
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 249, 98, 46),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.white),
                                                child: Center(
                                                  child: Text(
                                                    "following",
                                                    style: TextStyle(
                                                        fontFamily: "inter",
                                                        color: Color.fromARGB(
                                                            255, 249, 98, 46),
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                          ),
                                  );
                                }
                              },
                            ),
                          ),
                  ],
                ),
              ),
              centerTitle: true,
              pinned: true,
              floating: true,
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
                      children: [Icon(Icons.feed_outlined), Text("POST")],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Icon(Icons.video_collection), Text("Videos")],
                    ),
                  ]),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // TabA(),
            MyPosts(uid: widget.uid.toString()),
            MyShorts(
              uid: widget.uid.toString(),
            )
          ],
        ),
      ),
    );
  }
}

class TabA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (context, child) => Divider(
          height: 1,
        ),
        padding: EdgeInsets.all(0.0),
        itemCount: 30,
        itemBuilder: (context, i) {
          return Container(
            height: 100,
            width: double.infinity,
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          );
        },
      ),
    );
  }
}
