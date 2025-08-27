import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/get_postData.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:sound_library/sound_library.dart';

class TextPost extends StatefulWidget {
  final String userProfileimg;
  final String name;
  final String username;
  final String postContent;
  final String postid;
  final String userid;
  final String current_user_name;
  final String current_user_image;
  final String admin_post;
  final String userPostedID;

  TextPost(
      {required this.userProfileimg,
      required this.name,
      required this.username,
      required this.postContent,
      required this.postid,
      required this.userid,
      required this.current_user_image,
      required this.current_user_name,
      required this.admin_post,
      required this.userPostedID});

  @override
  _TextPostState createState() => _TextPostState();
}

class _TextPostState extends State<TextPost> {
  deleteFileDocument(String p_ID) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post Deleting',
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
    print('file deleted');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentRef =
        firestore.collection('User_Posts').doc(p_ID.toString());
    documentRef.delete().then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post Deleted',
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
        print("File Deleted-------------------------------------");
      },
    );
    // File deleted successfully
  }

  Future _fetchLikeCount(String postId) async {
    try {
      AggregateQuerySnapshot likesSnapshot = await FirebaseFirestore.instance
          .collection('User_Posts')
          .doc(postId)
          .collection('likes')
          .count()
          .get();

      return likesSnapshot.count;
    } catch (error) {
      print("Error getting like count for post $postId: $error");
      return 0;
    }
  }

  Future<bool> _hasLikedPost(String postID, String userID) async {
    // Replace with your Firebase logic to check if the user has liked the post
    final snapshot = await FirebaseFirestore.instance
        .collection('User_Posts')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .get();

    return snapshot.exists;
  }

  Future<bool> _toggleLike(String postID, String userID) async {
    final likesCollection = FirebaseFirestore.instance
        .collection('User_Posts')
        .doc(postID)
        .collection('likes');

    final userLikeDoc = likesCollection.doc(userID);
    final userLikeSnapshot = await userLikeDoc.get();

    if (userLikeSnapshot.exists) {
      // User has already liked the post, so remove the like
      await userLikeDoc.delete();
      return false;
    } else {
      // User has not liked the post, so add a like
      await userLikeDoc.set({});
      return true;
    }
  }

  User? _user;
  String? _uid;

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
    // print("-----------------------------------");
    // print(_uid);
    // print(widget.userPostedID.toString());

    // fetchUserData();
  }

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              myProfile(uid: widget.userPostedID),
                        ));
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 224, 223, 223),
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: NetworkImage(widget.userProfileimg),
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name ?? 'Unknown User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "inter",
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "@${widget.username ?? 'Unknown User'}",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 127, 127, 127),
                              fontFamily: "inter",
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                widget.admin_post == "true" &&
                        _uid.toString() == widget.userPostedID.toString()
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: PopupMenuButton(
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      onTap: () {
                                        deleteFileDocument(widget.postid);
                                      },
                                      child: ListTile(
                                        title: Text("Delete"),
                                        leading: Icon(Icons.delete_outline),
                                      )),
                                ],
                            child: Icon(Icons.more_vert)),
                      )
                    : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Wrap(
              children: [
                Text(
                  widget.postContent,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "inter",
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    FutureBuilder(
                      future: _fetchLikeCount(widget.postid),
                      builder: (context, likeCountSnapshot) {
                        if (likeCountSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading likes...');
                        } else if (likeCountSnapshot.hasError) {
                          return Text('Error loading likes');
                        } else {
                          return Text(' ${likeCountSnapshot.data}');
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "comments",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 127, 127, 127),
                        fontFamily: "inter",
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FutureBuilder<bool>(
                    future: _hasLikedPost(widget.postid, widget.userid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                          size: 18,
                        );
                      } else if (snapshot.hasError) {
                        return Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 18,
                        );
                      } else {
                        bool hasLiked = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            SoundPlayer.playFromAssetPath("images/likebtn.mp3");
                            // Handle like/unlike action here
                            bool newLikeStatus =
                                await _toggleLike(widget.postid, widget.userid);
                            setState(() {
                              hasLiked = true;

                              // Update UI based on newLikeStatus
                            });
                          },
                          child: Icon(
                            hasLiked ? Icons.favorite : Icons.favorite_border,
                            color: hasLiked ? Colors.red : Colors.black,
                            size: 25,
                          ),
                        );
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ShowComments.show(
                        context,
                        widget.postid,
                        widget.current_user_name,
                        widget.current_user_image,
                        widget.userid);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.messenger_outline_rounded),
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
