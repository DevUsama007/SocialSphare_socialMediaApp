import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/UserPhotoPost.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/postmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/textpost.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/videopost.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:social_sphere/register&login&splashScreen/login.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';
import 'package:sound_library/sound_library.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class getPostData extends StatefulWidget {
  getPostData({super.key});

  @override
  State<getPostData> createState() => _getPostDataState();
}

class _getPostDataState extends State<getPostData> {
  User? _user;
  String? _uid;
  Stream<List<Post>>? _postStream;
  void _fetchPosts() {
    _postStream = streamFollowedUsersPosts(_uid!);
  }

  Future<void> _refreshPosts() async {
    fetchData();
    setState(() {
      _fetchPosts(); // Trigger a fresh fetch of the posts stream
    });
  }

  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
    setState(() {
      _fetchPosts(); // Trigger a fresh fetch of the posts stream
    });
    fetchData();
    print(_uid);
  }

  String? fieldValue;
  var username;
  var userImage;
  var name;
  var userAbout;
  var bio;
  Future<void> fetchData() async {
    try {
      print(_uid);
      print("id of the user si s");
      DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore
          .instance
          .collection('User_Profile')
          .doc(_uid)
          .get();
      print(document.data());
      if (document.exists) {
        print(document.data()?['bio']);
        setState(() {
          bio = document.data()?['bio'];
          name = document.data()?['Name']; // Replace with your field name
          username =
              document.data()?['user_name']; // Replace with your field name
          userImage = document
              .data()?['profile_image_link']; // Replace with your field name
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

  Future<List<String>> getFollowedUsers(String currentUserId) async {
    List<String> followedUserIds = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('following')
          .where('followedbyUserId', isEqualTo: currentUserId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          print('Document data: ${doc.data()}');
          followedUserIds
              .add(doc['userID']); // Adjust the field name accordingly
        }
      } else {
        print('No documents found.');
      }
    } catch (e) {
      print('Error fetching followed users: $e');
    }

    print('Followed User IDs: $followedUserIds');
    return followedUserIds;
  }

  //clear post functio is going
  Stream<List<Post>> streamFollowedUsersPosts(String currentUserId) async* {
    List<String> followedUserIds = await getFollowedUsers(currentUserId);
    List<Stream<List<Post>>> streams = [];

    for (String userId in followedUserIds) {
      Stream<QuerySnapshot> userPostsStream = FirebaseFirestore.instance
          .collection('User_Posts')
          .where('userID', isEqualTo: userId)
          .snapshots();

      streams.add(userPostsStream.map((snapshot) {
        List<Post> posts = snapshot.docs.map((doc) {
          return Post.fromDocument(doc);
        }).toList();
        print(posts);

        // Sort posts by timestamp in descending order (most recent first)
        posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return posts;
      }));
    }

    yield* StreamZip(streams).map((listOfPostsLists) {
      List<Post> allPosts = listOfPostsLists.expand((posts) => posts).toList();
      allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allPosts;
    });
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

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  refresh() {
    fetchData();
    streamFollowedUsersPosts(_uid.toString());
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/SS_LOGO2.png",
          width: 170,
          height: 80,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: InkWell(
              onTap: () async {
                // Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => login()));
                //   // AwesomeDialog(
                //   dialogBackgroundColor: Colors.yellow,
                //   context: context,
                //   dialogType: DialogType.warning,
                //   animType: AnimType.rightSlide,
                //   title: 'Log Out',
                //   desc: 'Are sure you want to log out!',
                //   btnCancelOnPress: () {
                //     Navigator.pop(context);
                //   },
                //   btnOkOnPress: () {
                //     Navigator.pushReplacement(context,
                //         MaterialPageRoute(builder: (context) => login()));
                //   },
                // )..show();
                // await FirebaseAuth.instance.signOut().then(
                //   (value) {
                //     Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => AnimatedSplashScreen(),
                //         ));
                //   },
                // );
              },
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey)),
                  child: Icon(Icons.logout)),
            ),
          )
        ],
      ),

      body: LiquidPullToRefresh(
        color: Color.fromARGB(255, 249, 98, 46),
        // showChildOpacityTransition: false,
        onRefresh: () => _refreshPosts(),
        springAnimationDurationInMilliseconds: 1000,
        height: 130,

        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  height: 170,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: userImage == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Color.fromARGB(255, 240, 239, 239),
                                  highlightColor:
                                      Color.fromARGB(255, 193, 191, 191),
                                  child: ListView.builder(
                                    itemCount: 8,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        color: Colors.red,
                                        width: 120,
                                        height: 100,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  width: 130,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: userImage == null
                                          ? AssetImage(
                                              "assets/images/person_icon.png")
                                          : NetworkImage(userImage),
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.brown,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 60, left: 45),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Colors.brown,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 40, left: 5),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.orange),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: userImage ==
                                                        null
                                                    ? AssetImage(
                                                        "assets/images/person_icon.png")
                                                    : NetworkImage(userImage),
                                              ),
                                            ),
                                            Text(
                                              "You",
                                              style: TextStyle(
                                                fontFamily: "inter",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                userProfile(
                                  userProfileimg: 'girlimage1.jpg',
                                  userName: 'Janifer',
                                ),
                                userProfile(
                                  userProfileimg: 'girlimage2.jpg',
                                  userName: 'Natasha',
                                ),
                                userProfile(
                                  userProfileimg: 'boyimage1.jpg',
                                  userName: 'Hassan',
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _uid == null
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Shimmer.fromColors(
                          baseColor: Color.fromARGB(255, 240, 239, 239),
                          highlightColor: Color.fromARGB(255, 193, 191, 191),
                          child: ListView.builder(
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return PostCard();
                            },
                          ),
                        ),
                      )
                    : StreamBuilder<List<Post>>(
                        stream: _postStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.connectionState == ConnectionTask) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Shimmer.fromColors(
                                baseColor: Color.fromARGB(255, 240, 239, 239),
                                highlightColor:
                                    Color.fromARGB(255, 193, 191, 191),
                                child: ListView.builder(
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return PostCard();
                                  },
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Shimmer.fromColors(
                                baseColor: Color.fromARGB(255, 240, 239, 239),
                                highlightColor:
                                    Color.fromARGB(255, 193, 191, 191),
                                child: ListView.builder(
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return PostCard();
                                  },
                                ),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                loading = false;

                                Post post = snapshot.data![index];

                                return Container(
                                  child: Column(
                                    children: [
                                      post.postType == 'text'
                                          ? TextPost(
                                              userPostedID: post.userID,
                                              admin_post: 'false',
                                              userProfileimg: post
                                                  .userprofileImage
                                                  .toString(),
                                              name: post.name.toString(),
                                              username:
                                                  post.username.toString(),
                                              postContent:
                                                  post.caption.toString(),
                                              postid: post.postID.toString(),
                                              userid: _uid.toString(),
                                              current_user_image:
                                                  userImage.toString(),
                                              current_user_name:
                                                  name.toString())
                                          : post.postType == "video"
                                              ? userVideoPost(
                                                  userPostedID: post.userID,
                                                  admin_post: "false",
                                                  userProfileimg: post
                                                      .userprofileImage
                                                      .toString(),
                                                  name: post.name.toString(),
                                                  username:
                                                      post.username.toString(),
                                                  postContent:
                                                      post.caption.toString(),
                                                  postid:
                                                      post.postID.toString(),
                                                  postUrl:
                                                      post.postUrl.toString(),
                                                  userid: _uid.toString(),
                                                  current_user_image:
                                                      userImage.toString(),
                                                  current_user_name:
                                                      name.toString())
                                              : userImagePost(
                                                  userPostedID: post.userID,
                                                  admin_post: "false",
                                                  userProfileimg: post
                                                      .userprofileImage
                                                      .toString(),
                                                  name: post.name.toString(),
                                                  username:
                                                      post.username.toString(),
                                                  postContent:
                                                      post.caption.toString(),
                                                  postid:
                                                      post.postID.toString(),
                                                  postUrl:
                                                      post.postUrl.toString(),
                                                  userid: _uid.toString(),
                                                  current_user_image:
                                                      userImage.toString(),
                                                  current_user_name:
                                                      username.toString())
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// shimeer effect screen

class PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // decoration: BoxDecoration(color: Colors.white),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 217, 215, 215).withOpacity(0.7),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 224, 223, 223),
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/images/person_icon.png'),
                        ),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: const Color.fromARGB(255, 103, 102, 102),
                          child: Text(
                            "                                     ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "inter",
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          color: const Color.fromARGB(255, 103, 102, 102),
                          child: Text(
                            "                  ",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 127, 127, 127),
                              fontFamily: "inter",
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Wrap(
                children: [
                  Text(
                    "",
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 59,
                  color: const Color.fromARGB(255, 103, 102, 102),
                  child: Text("              "),
                ),
                Container(
                  width: 79,
                  color: const Color.fromARGB(255, 103, 102, 102),
                  child: Text("              "),
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
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.orange,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.messenger_outline_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPost extends StatefulWidget {
  final String videoUrl;

  VideoPost({required this.videoUrl});

  @override
  _VideoPostState createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  late VideoPlayerController _controller;
  String _playedTime = '0:00';
  String _totalDuration = '0:00';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // When the video is initialized, update the UI.
      })
      ..setLooping(true) // Enable looping
      ..addListener(() {
        setState(() {
          _playedTime = _formatDuration(_controller.value.position);
        });
      });
  }

  String _formatDuration(Duration duration) {
    final String twoDigitsMinutes =
        _twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitsSeconds =
        _twoDigits(duration.inSeconds.remainder(60));
    return "${_twoDigits(duration.inHours)}:$twoDigitsMinutes:$twoDigitsSeconds";
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool playing = true;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5) {
          _controller.play();
        } else {
          _controller.pause();
        }
      },
      child: _controller.value.isInitialized
          ? Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                Positioned(
                    top: MediaQuery.of(context).size.width * 0.5,
                    left: MediaQuery.of(context).size.width * 0.4,
                    child: InkWell(
                        onTap: () {
                          _controller.value.isPlaying
                              ? setState(() {
                                  _controller.pause();
                                  playing = false;
                                })
                              : setState(() {
                                  _controller.play();
                                  playing = true;
                                });
                        },
                        child: !playing
                            ? Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 50,
                              )
                            : Icon(
                                Icons.pause,
                                color: Colors.transparent,
                                size: 50,
                              ))),
                Positioned(
                  bottom: 14,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 8,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            bufferedColor: Color.fromARGB(255, 194, 150, 135),
                            backgroundColor: Color.fromARGB(255, 253, 163, 134),
                            playedColor: Color.fromARGB(255, 249, 98, 46)),
                      )),
                ),
                // Positioned(
                //     child: Row(
                //   children: [
                //     Text(_playedTime),
                //     Text(_totalDuration),
                //   ],
                // ))
              ],
            )
          : Center(
              child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Shimmer.fromColors(
                baseColor: Color.fromARGB(255, 240, 239, 239),
                direction: ShimmerDirection.rtl,
                highlightColor: Color.fromARGB(255, 193, 191, 191),
                child: Container(
                  color:
                      const Color.fromARGB(255, 140, 140, 140).withOpacity(0.6),
                  child: Center(
                      child: Icon(
                    Icons.play_circle_fill,
                    size: 90,
                    color: Colors.black,
                  )),
                ),
              ),
            )),
    );
  }
}

class ShowComments extends StatefulWidget {
  const ShowComments({Key? key}) : super(key: key);

  @override
  _ShowCommentsState createState() => _ShowCommentsState();

  // Static method to call the modal bottom sheet
  static void show(BuildContext context, String postID, String userName,
      String userImage, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return _buildBottomSheetContent(
            context, postID, userName, userImage, userId);
      },
    );
  }

  static Widget _buildBottomSheetContent(BuildContext context, String postID,
      String userName, String userImage, String userId) {
    final TextEditingController commentController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Comments',
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User_Posts')
                  .doc(postID.toString())
                  .collection("comments")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Shimmer.fromColors(
                      baseColor: Color.fromARGB(255, 240, 239, 239),
                      highlightColor: Color.fromARGB(255, 193, 191, 191),
                      child: ListView.builder(
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            title: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              width: 30,
                              height: 30,
                              color: Colors.grey,
                            ),
                            subtitle: Container(
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No comments yet.'));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 175, 174, 174),
                                image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: NetworkImage(comment['userImage'])),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    comment['author'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "inter",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Wrap(
                                    children: [
                                      Text(
                                        comment['content'].toString(),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: commentController,
                    decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.4)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(
                                  255, 249, 98, 46)), // Color when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(
                                  255, 246, 165, 139)), // Default color
                        ),
                        prefixIcon: Icon(Icons.comment),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              var docId = DateTime.now().millisecondsSinceEpoch;
                              if (commentController.text.isNotEmpty) {
                                await FirebaseFirestore.instance
                                    .collection('User_Posts')
                                    .doc(postID.toString())
                                    .collection("comments")
                                    .doc(docId.toString())
                                    .set({
                                  'postID': postID,
                                  'author':
                                      userName, // Replace with actual user data
                                  'content': commentController.text,
                                  'userImage': userImage,
                                  'userId': userId,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                                commentController.clear();
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Color.fromARGB(255, 252, 109, 62),
                            )),
                        filled: true,
                        fillColor: Color.fromARGB(255, 224, 223, 223)),
                    minLines: 1,
                    maxLines: null,
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

class _ShowCommentsState extends State<ShowComments> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class userProfile extends StatefulWidget {
  final String userProfileimg;
  final String userName;
  const userProfile(
      {super.key, required this.userProfileimg, required this.userName});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 130,
      height: 160,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/${widget.userProfileimg}"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 60, left: 45),
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.transparent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 5),
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/images/${widget.userProfileimg}"),
                  ),
                ),
                Text(
                  "${widget.userName}",
                  style: TextStyle(
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
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
