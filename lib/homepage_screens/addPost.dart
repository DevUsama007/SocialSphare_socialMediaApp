import 'dart:io';
import 'package:social_sphere/homepage_screens/followedUserPost/short_video_screen/add_short_video.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/homepage_screens/addTextPost.dart';

class Addpost extends StatefulWidget {
  const Addpost({super.key});

  @override
  State<Addpost> createState() => _AddpostState();
}

class _AddpostState extends State<Addpost> {
// get the user data
  User? _user;
  String? _uid;
  TextEditingController postcaption = TextEditingController();
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

  var username;
  var userImage;
  var name;
  var userAbout;

  String? fieldValue;
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
        setState(() {
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

// get the user data ends here

  int captionLines = 6;
  late String postType;
  PlatformFile? pickedImage;
  Future pick_image() async {
    setState(() {
      pickedvideo = null;
    });
    print("click");
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        postType = "image";
        captionLines = 2;
        pickedImage = result.files.first;
      });
      print(pickedImage!.name);
      print(pickedImage!.size / 1024);

      // showUpdateDialogue(File(pickedImage!.path.toString()));
    } else {
      print("file not picked");
    }
  }

  PlatformFile? pickedvideo;
  Future pick_video() async {
    setState(() {
      pickedImage = null;
      pickedvideo = null;
    });
    print("click");
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        postType = "video";
        captionLines = 2;
        pickedvideo = result.files.first;
      });
      print(pickedvideo!.name);
      print(pickedvideo!.size / 1024);

      // showUpdateDialogue(File(pickedImage!.path.toString()));
    } else {
      print("file not picked");
    }
  }

  bool uploading = false;
  double _uploadProgress = 0.0;
  bool uploadComplete = false;
  Message mess = Message();

  final firestore = FirebaseFirestore.instance.collection('User_Posts');
  Future UploadImagePost() async {
    setState(() {
      uploading = true;
    });
    print("click");
    var documentID = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref("userPost/" + documentID);
    firebase_storage.UploadTask upload =
        ref.putFile(File(pickedImage!.path.toString()).absolute);
    print("click 2");
    upload.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;

      setState(() {
        _uploadProgress = progress;
      });
    });
    DateTime timestamp = DateTime.now();
    await upload.whenComplete(
      () async {
        print("success");
        var newUrl = await ref.getDownloadURL();
        print(newUrl);
        print(postcaption.text);
        firestore.doc(documentID).set({
          "postID": documentID,
          "userID": _uid.toString(),
          "caption": postcaption.text,
          "postType": postType.toString(),
          "postUrl": newUrl.toString(),
          "timestamp": timestamp,
          "username": username,
          "name": name,
          "userprofileImage": userImage,
        }).then(
          (value) {
            setState(() {
              _uploadProgress = 0.0;
              uploading = false;
              uploadComplete = true;
              pickedImage = null;
              postcaption.clear();
              captionLines = 6;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Post Uploaded',
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
              uploading = false;
            });
            mess.infoMessage(context, "Uploading Failed", error.toString());
          },
        );
      },
    );

    print("object");
  }

// function to upload the video
  Future UploadVideoPost() async {
    setState(() {
      uploading = true;
    });
    print("click");
    var documentID = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref("userPost/" + documentID);
    firebase_storage.UploadTask upload =
        ref.putFile(File(pickedvideo!.path.toString()).absolute);
    print("click 2");
    upload.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;

      setState(() {
        _uploadProgress = progress;
      });
    });
    DateTime timestamp = DateTime.now();
    await upload.whenComplete(
      () async {
        print("success");
        var newUrl = await ref.getDownloadURL();
        print(newUrl);
        firestore.doc(documentID).set({
          "postID": documentID,
          "userID": _uid.toString(),
          "caption": postcaption.text,
          "postType": postType.toString(),
          "postUrl": newUrl.toString(),
          "timestamp": timestamp,
          "username": username,
          "name": name,
          "userprofileImage": userImage,
        }).then(
          (value) {
            setState(() {
              _uploadProgress = 0.0;
              uploading = false;
              uploadComplete = true;
              pickedvideo = null;
              postcaption.clear();
              captionLines = 6;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Post Uploaded',
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
              uploading = false;
            });
            mess.infoMessage(context, "Uploading Failed", error.toString());
          },
        );
      },
    );
    // await Future.value(upload).then(
    //   (value) async {

    //   },
    // ).onError(
    //   (error, stackTrace) {
    //     print("error");
    //     mess.infoMessage(context, "Uploading Failed", error.toString());
    //   },
    // );
    print("object");
  }

// fucntions to upload the video post ends here
  @override
  void initState() {
    _getCurrentUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: uploading
            ? Color.fromARGB(255, 249, 98, 46).withOpacity(
                0.6) // Set the background color to null to use the gradient
            : Color.fromARGB(255, 249, 98, 46),
        centerTitle: true,
        title: uploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   child: LinearProgressIndicator(
                  //     minHeight: 30,
                  //     value: _uploadProgress,
                  //     backgroundColor: Color.fromARGB(255, 250, 135, 96),
                  //     valueColor: AlwaysStoppedAnimation<Color>(
                  //       Color.fromARGB(255, 249, 98, 46),
                  //     ),
                  //   ),
                  // ),
                  _uploadProgress > 0
                      ? Text(
                          "Uploading: ${(_uploadProgress * 100).toStringAsFixed(2)}%",
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              color: Colors.black),
                        )
                      : Text(
                          "Connecting",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "inter",
                              fontSize: 14),
                        )
                ],
              )
            : Text('Create Post',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "inter")),
        flexibleSpace: uploading
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 249, 98, 46)
                          .withOpacity(_uploadProgress),
                      Color.fromARGB(255, 250, 135, 96)
                          .withOpacity(_uploadProgress),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : null,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
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
                  leading: Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 224, 223, 223),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: userImage == null
                                ? AssetImage("assets/images/person_icon.png")
                                : NetworkImage(userImage)),
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  title: username == null
                      ? Text("fetching")
                      : Text(
                          username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "inter",
                              fontSize: 18),
                        ),
                  subtitle: name == null ? Text("fetching") : Text(name),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                // height: 50,
                child: TextFormField(
                  maxLines: captionLines,
                  controller: postcaption,
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
                    hintText: "write a caption...",
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              pickedImage == null && pickedvideo == null
                  ? Container()
                  : postType == null
                      ? Container()
                      : postType == "image"
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Image.file(
                                  File(pickedImage!.path.toString())),
                            )
                          : Container(
                              child: ShowPostWidget(
                              file: File(pickedvideo!.path.toString()),
                            )
                              //  Text(pickedvideo!.name.toString()

                              // ),
                              ),
              Divider(),
              InkWell(
                onTap: () {
                  setState(() {
                    captionLines = 6;
                    pickedImage = null;
                    pickedvideo = null;
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Addtextpost(),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.text_fields),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Text"),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  pick_image();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.photo,
                        color: Color.fromARGB(255, 45, 198, 50),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Photo"),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  pick_video();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.video_chat,
                        color: Color.fromARGB(255, 45, 198, 50),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Video"),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddShortVideo(),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.video_chat,
                        color: Color.fromARGB(255, 45, 198, 50),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Add Short"),
                    ],
                  ),
                ),
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.9, 25),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Change the radius here
                    ),
                  ),
                  onPressed:
                      pickedImage == null && pickedvideo == null || uploading
                          ? null
                          : () {
                              // pick_image();
                              postType == "image"
                                  ? UploadImagePost()
                                  : UploadVideoPost();
                            },
                  child: Text(
                    "POST",
                    style: TextStyle(fontFamily: "inter", fontSize: 17),
                  )),
              SizedBox(
                height: 140,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// show picked video to play and check
class ShowPostWidget extends StatefulWidget {
  File file;
  ShowPostWidget({super.key, required this.file});

  @override
  State<ShowPostWidget> createState() => _ShowPostWidgetState();
}

class _ShowPostWidgetState extends State<ShowPostWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  bool playing = true;
  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.width * 0.5,
                      left: MediaQuery.of(context).size.width * 0.25,
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
                ],
              ),
            ],
          )
        : Container();
  }
}
