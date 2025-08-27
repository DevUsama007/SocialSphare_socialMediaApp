import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:social_sphere/suggestion&following/getFollowinglist.dart';
import 'package:social_sphere/suggestion&following/userModel.dart';

class Suggestionuserprofile extends StatefulWidget {
  const Suggestionuserprofile({super.key});

  @override
  State<Suggestionuserprofile> createState() => _SuggestionuserprofileState();
}

class _SuggestionuserprofileState extends State<Suggestionuserprofile> {
  List<bool> loadingStates = [];
  String number = "";

  Future<List<UserM>> fetchAllUsers() async {
    List<UserM> allUsers = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('User_Profile').get();
      for (var doc in snapshot.docs) {
        allUsers.add(UserM.fromDocument(doc));
      }
    } catch (e) {
      print('Error fetching all users: $e');
    }
    return allUsers;
  }

  Future<List<String>> getFollowedUsers(String currentUserId) async {
    List<String> followedUserIds = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('following')
          .where('followedbyUserId', isEqualTo: currentUserId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          followedUserIds
              .add(doc['userID']); // Adjust the field name accordingly
        }
      } else {
        print('No documents found.');
      }
    } catch (e) {
      print('Error fetching followed users: $e');
    }
    return followedUserIds;
  }

  Future<List<UserM>> fetchProfileSuggestions(String currentUserId) async {
    List<UserM> allUsers = await fetchAllUsers();
    List<String> followedUserIds = await getFollowedUsers(currentUserId);
    List<UserM> suggestions = allUsers
        .where((user) => !followedUserIds.contains(user.userId))
        .toList();
    return suggestions;
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

  Message info = Message();

  final follow = FirebaseFirestore.instance.collection('following');
  bool working = false;

  Future<void> followUser(String userID) async {
    setState(() {
      working = true;
      number = "";
    });
    try {
      var documentID = userID + _uid.toString();
      await follow.doc(documentID).set({
        "documentId": documentID,
        "userID": userID.toString(),
        "followedbyUserId": _uid.toString(),
      });
      setState(() {
        working = false;
        number = "";
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
    } catch (error) {
      setState(() {
        number = "";
        working = false;
      });
      info.infoMessage(context, "Failed", error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserM>>(
        future: fetchProfileSuggestions(_uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No profile suggestions found.'));
          } else {
            List<UserM> suggestions = snapshot.data!;

            if (loadingStates.length != suggestions.length) {
              loadingStates = List<bool>.filled(suggestions.length, false);
            }

            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                UserM user = suggestions[index];

                return user.userId == _uid.toString()
                    ? Container()
                    : ListTile(
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
                                    image: NetworkImage(user.profileImageLink)),
                                borderRadius: BorderRadius.circular(40)),
                          ),
                        ),
                        title: Text(
                          user.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "inter",
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          user.username.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "inter",
                            color: Colors.black,
                          ),
                        ),
                        trailing: loadingStates[index]
                            ? Container(
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
                                ))
                            : InkWell(
                                onTap: () async {
                                  setState(() {
                                    loadingStates[index] = true;
                                  });
                                  await followUser(user.userId).then(
                                    (value) {
                                      setState(() {
                                        loadingStates[index] = false;
                                      });
                                    },
                                  );
                                },
                                child: Container(
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
