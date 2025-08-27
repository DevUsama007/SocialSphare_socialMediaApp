import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';

class Addtextpost extends StatefulWidget {
  const Addtextpost({super.key});

  @override
  State<Addtextpost> createState() => _AddtextpostState();
}

class _AddtextpostState extends State<Addtextpost> {
  TextEditingController post = TextEditingController();
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

  final firestore = FirebaseFirestore.instance.collection('User_Posts');
  bool uploading = false;
  double _uploadProgress = 0.0;
  bool uploadComplete = false;
  Message mess = Message();
// post the text to collection
  postText() {
    try {
      setState(() {
        uploading = true;
      });

      print("click");
      var documentID = DateTime.now().millisecondsSinceEpoch.toString();

      DateTime timestamp = DateTime.now();
      firestore.doc(documentID).set({
        "postID": documentID,
        "userID": _uid.toString(),
        "caption": post.text,
        "postType": "text",
        "postUrl": "",
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
            post.clear();
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
            _uploadProgress = 0.0;
          });
          mess.infoMessage(context, "Uploading Failed", error.toString());
        },
      );
    } catch (e) {
      setState(() {
        uploading = false;
        _uploadProgress = 0.0;
      });
      mess.infoMessage(context, "Uploading Failed", e.toString());
    }
  }

// function ends here
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
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
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
              SizedBox(
                height: 10,
              ),
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
                            fit: BoxFit.contain,
                            image: userImage == null
                                ? AssetImage("assets/images/person_icon")
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
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("What's on your mind?",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 18)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                // height: 50,
                child: TextFormField(
                  maxLines: 6,
                  onChanged: (value) {
                    setState(() {});
                  },
                  controller: post,
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
                    hintText: "Type your post here...",
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
                  onPressed: post.text.isNotEmpty && !uploading
                      ? () {
                          postText();
                        }
                      : null,
                  child: Text(
                    "POST",
                    style: TextStyle(fontFamily: "inter", fontSize: 17),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
