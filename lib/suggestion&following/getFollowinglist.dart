import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:social_sphere/suggestion&following/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/suggestion&following/userModel.dart';

class Getfollowinglist extends StatefulWidget {
  const Getfollowinglist({super.key});

  @override
  State<Getfollowinglist> createState() => _GetfollowinglistState();
}

class _GetfollowinglistState extends State<Getfollowinglist> {
  List<bool> loadingStates = [];
  bool working = false;

  Future<List<String>> getFollowedUsers(String currentUserId) async {
    List<String> followedUserIds = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('following')
          .where('followedbyUserId', isEqualTo: currentUserId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          followedUserIds.add(doc['userID']);
        }
      } else {
        print('No documents found.');
      }
    } catch (e) {
      print('Error fetching followed users: $e');
    }
    return followedUserIds;
  }

  Future<List<UserM>> fetchFollowedUserDatat(String currentUserId) async {
    List<String> followedUserIds = await getFollowedUsers(currentUserId);
    List<UserM> userDoc = [];
    for (String userId in followedUserIds) {
      QuerySnapshot userdataSnapshot = await FirebaseFirestore.instance
          .collection('User_Profile')
          .where('user_id', isEqualTo: userId)
          .get();
      for (var doc in userdataSnapshot.docs) {
        userDoc.add(UserM.fromDocument(doc));
      }
    }
    return userDoc;
  }

  User? _user;
  String? _uid;

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
  }

  Future<void> unfollowUser(String documentId, int index) async {
    setState(() {
      loadingStates[index] = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('following')
          .doc(documentId)
          .delete();
      setState(() {
        loadingStates[index] = false;
      });
    } catch (error) {
      setState(() {
        loadingStates[index] = false;
      });
    }
  }

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserM>>(
        future: fetchFollowedUserDatat(_uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No followed users found.'));
          } else {
            List<UserM> followedUsers = snapshot.data!;

            if (loadingStates.length != followedUsers.length) {
              loadingStates = List<bool>.filled(followedUsers.length, false);
            }

            return ListView.builder(
              itemCount: followedUsers.length,
              itemBuilder: (context, index) {
                UserM user = followedUsers[index];
                return Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(255, 200, 199, 199),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: ListTile(
                    leading: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  myProfile(uid: user.userId.toString()),
                            ));
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 224, 223, 223),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  user.profileImageLink,
                                )),
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                    title: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "inter",
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      user.username,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "inter",
                        color: Colors.black,
                      ),
                    ),
                    trailing: loadingStates[index]
                        ? Container(
                            width: 70,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(255, 249, 98, 46)),
                            child: Center(
                              child: Text(
                                "follow",
                                style: TextStyle(
                                    fontFamily: "inter",
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              unfollowUser(
                                  user.userId + _uid.toString(), index);
                            },
                            child: Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 249, 98, 46),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white),
                                child: Center(
                                  child: Text(
                                    "following",
                                    style: TextStyle(
                                        fontFamily: "inter",
                                        color: Color.fromARGB(255, 249, 98, 46),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class followingShimmer extends StatefulWidget {
  const followingShimmer({super.key});

  @override
  State<followingShimmer> createState() => _followingShimmerState();
}

class _followingShimmerState extends State<followingShimmer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Shimmer.fromColors(
        baseColor: Color.fromARGB(255, 240, 239, 239),
        highlightColor: Color.fromARGB(255, 193, 191, 191),
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 200, 199, 199),
                    blurRadius: 10,
                    spreadRadius: 2)
              ], borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 224, 223, 223),
                      borderRadius: BorderRadius.circular(40)),
                ),
                title: Text(
                  "            ",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "inter",
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  "        ",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "inter",
                    color: Colors.black,
                  ),
                ),
                trailing: Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 249, 98, 46),
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    child: Center(
                      child: Text(
                        "           ",
                        style: TextStyle(
                            fontFamily: "inter",
                            color: Color.fromARGB(255, 249, 98, 46),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}
