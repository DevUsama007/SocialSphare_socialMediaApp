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
import 'package:sound_library/sound_library.dart';
import 'package:video_player/video_player.dart';

import 'package:visibility_detector/visibility_detector.dart';

class MyPosts extends StatefulWidget {
  final String uid;
  MyPosts({super.key, required this.uid});

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  @override
  void initState() {
    // TODO: implement initState
    _fetchPosts();
    super.initState();
  }

  String? fieldValue;
  var username;
  var userImage;
  var name;
  var userAbout;
  var bio;
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

  Stream<List<Post>> streamMyPosts(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('User_Posts')
        .where('userID', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      List<Post> posts = snapshot.docs.map((doc) {
        return Post.fromDocument(doc);
      }).toList();

      // Sort posts by timestamp in descending order (most recent first)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    });
  }

  Stream<List<Post>>? _postStream;
  void _fetchPosts() {
    _postStream = streamMyPosts(widget.uid.toString()!);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _fetchPosts(); // Trigger a fresh fetch of the posts stream
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () => _refreshPosts(),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              widget.uid.toString() == null
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
                              baseColor: Color.fromARGB(255, 86, 83, 83),
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
                                            admin_post: 'true',
                                            userProfileimg: post
                                                .userprofileImage
                                                .toString(),
                                            name: post.name.toString(),
                                            username: post.username.toString(),
                                            postContent:
                                                post.caption.toString(),
                                            postid: post.postID.toString(),
                                            userid: widget.uid.toString(),
                                            current_user_image:
                                                userImage.toString(),
                                            current_user_name: name.toString())
                                        : post.postType == "video"
                                            ? userVideoPost(
                                                userPostedID: post.userID,
                                                admin_post: 'true',
                                                userProfileimg: post
                                                    .userprofileImage
                                                    .toString(),
                                                name: post.name.toString(),
                                                username:
                                                    post.username.toString(),
                                                postContent:
                                                    post.caption.toString(),
                                                postid: post.postID.toString(),
                                                postUrl:
                                                    post.postUrl.toString(),
                                                userid: widget.uid.toString(),
                                                current_user_image:
                                                    userImage.toString(),
                                                current_user_name:
                                                    name.toString())
                                            : userImagePost(
                                                userPostedID: post.userID,
                                                admin_post: 'true',
                                                userProfileimg: post
                                                    .userprofileImage
                                                    .toString(),
                                                name: post.name.toString(),
                                                username:
                                                    post.username.toString(),
                                                postContent:
                                                    post.caption.toString(),
                                                postid: post.postID.toString(),
                                                postUrl:
                                                    post.postUrl.toString(),
                                                userid: widget.uid.toString(),
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
                  child: PopupMenuButton(
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                onTap: () {
                                  // FirebaseFirestore.instance
                                  //     .collection("product")
                                  //     .doc("2")
                                  //     .collection("my cart")
                                  //     .doc(snapshot.data!.docs[index]['id']
                                  //         .toString())
                                  //     .delete()
                                  //     .then(
                                  //   (value) {
                                  //     print("success");
                                  //   },
                                  // ).onError(
                                  //   (error, stackTrace) {
                                  //     print("failed");
                                  //   },
                                  // );
                                },
                                child: ListTile(
                                  title: Text("Delete"),
                                  leading: Icon(Icons.delete_outline),
                                )),
                          ],
                      child: Icon(Icons.more_vert)),
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
                                Icons.pause,
                                color: Colors.white,
                                size: 50,
                              )
                            : Icon(
                                Icons.play_arrow,
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
