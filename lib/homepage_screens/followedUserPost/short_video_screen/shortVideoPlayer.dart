import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sphere/profile_view/my_profile.dart';
import 'package:sound_library/sound_library.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String userProfileImage;
  final String userName;
  final String name;
  final String postId;
  final String uid;

  FullScreenVideoPlayer(
      {required this.videoUrl,
      required this.userProfileImage,
      required this.userName,
      required this.name,
      required this.postId,
      required this.uid});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  String _playedTime = '0:00';
  String _totalDuration = '0:00';
  Future _likeCount(String postId) async {
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

  Future<bool> _likedShort(String postID, String userID) async {
    // Replace with your Firebase logic to check if the user has liked the post
    final snapshot = await FirebaseFirestore.instance
        .collection('User_Posts')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .get();

    return snapshot.exists;
  }

  Future<bool> _toggleLikeOnShort(String postID, String userID) async {
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
    super.initState();
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

  Future _fetchLikeCount(String postId) async {
    try {
      AggregateQuerySnapshot likesSnapshot = await FirebaseFirestore.instance
          .collection('short_videos')
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
        .collection('short_videos')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .get();

    return snapshot.exists;
  }

  Future<bool> _toggleLike(String postID, String userID) async {
    final likesCollection = FirebaseFirestore.instance
        .collection('short_videos')
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
  void dispose() {}

  bool playing = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
            child: ShortVideoPlayerfile(
          videoUrl: widget.videoUrl.toString(),
        )
            //  AspectRatio(
            //   aspectRatio: _controller.value.aspectRatio,
            //   child: VideoPlayer(_controller),
            // ),
            ),
        Positioned(
            top: MediaQuery.of(context).size.width,
            left: MediaQuery.of(context).size.width * 0.4,
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
                  )),
        Positioned(
          bottom: 120,
          left: 10,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => myProfile(uid: widget.uid),
                      ));
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 224, 223, 223),
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage(widget.userProfileImage.toString()),
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
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
                      color: Color.fromARGB(255, 127, 127, 127),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "@${widget.userName}" ?? 'Unknown User',
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
        Positioned(
            bottom: 140,
            right: 0,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    print("like");
                  },
                  child: Container(
                    width: 70,
                    height: 40,
                    child: FutureBuilder<bool>(
                      future: _hasLikedPost(widget.postId, widget.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Icon(
                            Icons.favorite_border,
                            color: Colors.white,
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
                              SoundPlayer.playFromAssetPath(
                                  "images/likebtn.mp3");
                              // Handle like/unlike action here
                              bool newLikeStatus =
                                  await _toggleLike(widget.postId, widget.uid);
                              setState(() {
                                hasLiked = true;

                                // Update UI based on newLikeStatus
                              });
                            },
                            child: Icon(
                              hasLiked ? Icons.favorite : Icons.favorite_border,
                              color: hasLiked ? Colors.red : Colors.grey,
                              size: 35,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                FutureBuilder(
                  future: _fetchLikeCount(widget.postId),
                  builder: (context, likeCountSnapshot) {
                    if (likeCountSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text('Loading likes...');
                    } else if (likeCountSnapshot.hasError) {
                      return Text('Error loading likes');
                    } else {
                      return Text(
                        ' ${likeCountSnapshot.data}',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    print("comment");
                    ShortVideoComments.show(context, widget.postId,
                        widget.userName, widget.userProfileImage, widget.uid);
                  },
                  child: Container(
                    width: 70,
                    height: 40,
                    child: Icon(
                      Icons.comment,
                      color: Color.fromARGB(255, 249, 98, 46),
                      size: 35,
                    ),
                  ),
                )
              ],
            )),

        // Positioned(
        //     child: Row(
        //   children: [
        //     Text(_playedTime),
        //     Text(_totalDuration),
        //   ],
        // ))
      ],
    );
  }
}

class ShortVideoComments extends StatefulWidget {
  const ShortVideoComments({Key? key}) : super(key: key);

  @override
  _ShortVideoCommentsState createState() => _ShortVideoCommentsState();

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
                  .collection('short_videos')
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
                  ;
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
                                    .collection('short_videos')
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

class _ShortVideoCommentsState extends State<ShortVideoComments> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ShortVideoPlayerfile extends StatefulWidget {
  final String videoUrl;

  ShortVideoPlayerfile({required this.videoUrl});

  @override
  _ShortVideoPlayerfileState createState() => _ShortVideoPlayerfileState();
}

class _ShortVideoPlayerfileState extends State<ShortVideoPlayerfile> {
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
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                Positioned(
                    top: MediaQuery.of(context).size.width * 0.7,
                    left: MediaQuery.of(context).size.width * 0.4,
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
                          )),
                Positioned(
                  bottom: 48,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 10,
                      margin: EdgeInsets.only(top: 20, bottom: 10),
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
