import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/short_video_screen/shortVideoPlayer.dart';
import 'package:video_player/video_player.dart';

class MyShorts extends StatefulWidget {
  String uid;
  MyShorts({super.key, required this.uid});

  @override
  State<MyShorts> createState() => _MyShortsState();
}

class _MyShortsState extends State<MyShorts> {
  show() {
    return FirebaseFirestore.instance
        .collection('short_videos')
        .where("userID", isEqualTo: widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: Color.fromARGB(255, 226, 224, 224).withOpacity(0.1),
      child: StreamBuilder<QuerySnapshot>(
        stream: show(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 20,
              height: 20,
              child: Shimmer.fromColors(
                baseColor: Color.fromARGB(255, 240, 239, 239),
                direction: ShimmerDirection.rtl,
                highlightColor: Color.fromARGB(255, 193, 191, 191),
                child: Container(
                  color:
                      const Color.fromARGB(255, 140, 140, 140).withOpacity(0.1),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 90,
                        color: Colors.black,
                      ),
                      Text("Fetching...")
                    ],
                  )),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Text("error occured");
          }
          return Wrap(
            children: List.generate(snapshot.data!.docs.length, (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenVideoPlayer(
                          videoUrl:
                              snapshot.data!.docs[index]['postUrl'].toString(),
                          userProfileImage: snapshot
                              .data!.docs[index]['userprofileImage']
                              .toString(),
                          userName:
                              snapshot.data!.docs[index]['username'].toString(),
                          name: snapshot.data!.docs[index]['name'].toString(),
                          postId:
                              snapshot.data!.docs[index]['postID'].toString(),
                          uid: snapshot.data!.docs[index]['userID'].toString(),
                        ),
                      ));
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Container(
                    margin: EdgeInsets.only(left: 10, bottom: 10),
                    width: 105,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: myShortPlayer(
                      videoUrl:
                          snapshot.data!.docs[index]['postUrl'].toString(),
                      PostId: snapshot.data!.docs[index]['postID'].toString(),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class myShortPlayer extends StatefulWidget {
  final String videoUrl;
  final String PostId;

  myShortPlayer({required this.videoUrl, required this.PostId});

  @override
  _myShortPlayerState createState() => _myShortPlayerState();
}

class _myShortPlayerState extends State<myShortPlayer> {
  late VideoPlayerController _controller;
  Future<void> deleteFile(String filePath, String p_ID) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post Deleting...',
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
    // Create a reference to the file to delete
    print("working start");
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(filePath);

    // Delete the file and handle the result
    ref.delete().then((_) {
      deleteFileDocument(p_ID.toString());
    }).catchError((error) {
      // Handle the error
      print('Error occurred while deleting the file: $error');
    });
  }

  deleteFileDocument(String p_ID) {
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

  Future<bool> fileExists(String filePath, String p_ID) async {
    try {
      // Create a reference to the file
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(filePath);

      // Try to get the download URL of the file
      await ref.getDownloadURL();

      // If successful, the file exists
      return true;
    } catch (e) {
      // If an error occurs (e.g., file not found), return false
      if (e is FirebaseException && e.code == 'object-not-found') {
        print('File does not exist.');
        return false;
      } else {
        // Handle other errors
        print('An error occurred: $e');
        return false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.pause(); // Ensure the video is paused after loading
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 5,
                  left: 10,
                  child: PopupMenuButton(
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                onTap: () async {
                                  String filePath = 'userPost/${widget.PostId}';
                                  print(
                                      filePath); // Replace with your file path

                                  bool exists =
                                      await fileExists(filePath, widget.PostId);

                                  if (exists) {
                                    deleteFile(filePath, widget.PostId);
                                  } else {
                                    print('File does not exist.');
                                    deleteFileDocument(widget.PostId);
                                  }
                                },
                                child: ListTile(
                                  title: Text("Delete"),
                                  leading: Icon(Icons.delete_outline),
                                )),
                          ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.orange,
                      )),
                ),
                VideoPlayer(_controller),
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ), // Overlay play icon
              ],
            ),
          )
        : Shimmer.fromColors(
            baseColor: Color.fromARGB(255, 240, 239, 239),
            direction: ShimmerDirection.rtl,
            highlightColor: Color.fromARGB(255, 119, 116, 116),
            child: Container(
              color: Color.fromARGB(255, 195, 194, 194).withOpacity(0.1),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.black,
                  ),
                ],
              )),
            ),
          );
  }
}
