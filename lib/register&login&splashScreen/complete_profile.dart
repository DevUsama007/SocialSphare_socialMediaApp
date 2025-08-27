import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/homepage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  Message mess = Message();
  TextEditingController name = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController phone = TextEditingController();
  // instance for firebase storage
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  // instance for firebase database

  final firestore = FirebaseFirestore.instance.collection('User_Profile');
  User? _user;
  String? _uid;
  bool uploading = false;
  double _uploadProgress = 0.0;
  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
      _uid = user?.uid;
    });
    print(_uid);
  }

  PlatformFile? pickedImage;
  Future pick_image() async {
    print("click");
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
      print(pickedImage!.name);
      print(pickedImage!.size / 1024);
      // showUpdateDialogue(File(pickedImage!.path.toString()));
    } else {
      print("file not picked");
    }
  }

  validation() {
    setState(() {
      uploading = true;
    });
    if (name.text.toString() == "" ||
        userName.text.toString() == "" ||
        phone.text.toString() == "") {
      setState(() {
        uploading = false;
      });
      mess.infoMessage(context, "Input Field error", "Input Field is Empty");
    } else if (pickedImage == null) {
      setState(() {
        uploading = false;
      });
      mess.infoMessage(context, "Image Not Picked", "Pick the Image! ");
    } else {
      insertUserProfileData();
    }
  }

  Future insertUserProfileData() async {
    print("click");
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref("images/" + _uid.toString()
            // DateTime.now().millisecondsSinceEpoch.toString()
            );
    firebase_storage.UploadTask upload =
        ref.putFile(File(pickedImage!.path.toString()).absolute);
    print("click 2");
    upload.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;

      setState(() {
        _uploadProgress = progress;
      });
    });
    await upload.whenComplete(
      () async {
        print("success");
        var newUrl = await ref.getDownloadURL();
        print(newUrl);
        firestore.doc(_uid).set({
          "user_id": _uid.toString(),
          "Name": name.text,
          "user_name": userName.text,
          "phone": phone.text,
          "profile_image_link": newUrl
        }).then(
          (value) {
            mess.infoMessage(context, "Success", "Profile Updated");
            setState(() {
              _uploadProgress = 0.0;
              uploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile is Updated Successfully',
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(),
                ));
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
   
    
  }

  @override
  void initState() {
    _getCurrentUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.7,
              //   height: 80,
              //   child: Image.asset("assets/images/SS_LOGO.png"),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_circle_left,
                      size: 45,
                      color: Color.fromARGB(255, 249, 98, 46),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Complete Your Profile",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      "Don't worry only you can see your personal ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 14),
                    ),
                    Text(
                      "data, only you will able to see it ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 19,
              ),
              pickedImage == null
                  ? Stack(
                      children: [
                        Positioned(
                            child: Container(
                                padding: EdgeInsets.only(top: 10),
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 224, 223, 223),
                                    borderRadius: BorderRadius.circular(70)),
                                child: Icon(
                                  Icons.person_3_rounded,
                                  color: Color.fromARGB(255, 249, 98, 46),
                                  size: 90,
                                ))),
                        Positioned(
                            bottom: 7,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                pick_image();
                              },
                              child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 249, 98, 46),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  )),
                            ))
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                            child: Container(
                          padding: EdgeInsets.only(top: 10),
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 224, 223, 223),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                      File(pickedImage!.path.toString()))),
                              borderRadius: BorderRadius.circular(70)),
                        )),
                        Positioned(
                            bottom: 7,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                pick_image();
                              },
                              child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 249, 98, 46),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  )),
                            ))
                      ],
                    ),
              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 5),
                    child: Text(
                      "Name",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: TextFormField(
                  controller: name,
                  textAlign: TextAlign.start,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontFamily: "inter",
                        textBaseline: TextBaseline.alphabetic,
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
                    hintText: "Ex. Usama",
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 5),
                    child: Text(
                      "User Name",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: TextFormField(
                  controller: userName,
                  textAlign: TextAlign.start,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontFamily: "inter",
                        textBaseline: TextBaseline.alphabetic,
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
                    hintText: "Ex. Xam_jutt7",
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 5),
                    child: Text(
                      "Phone",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: TextFormField(
                  controller: phone,
                  textAlign: TextAlign.start,
                  cursorColor: Colors.grey,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontFamily: "inter",
                        textBaseline: TextBaseline.alphabetic,
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
                    hintText: "Ex. 0355-2342542",
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),

              ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.9, 50))),
                  onPressed: !uploading
                      ? () {
                          validation();
                        }
                      : null,
                  child: Text(
                    "Complete Profile",
                    style: TextStyle(fontFamily: "inter", fontSize: 17),
                  )),
              SizedBox(
                height: 5,
              ),
              uploading
                  ? Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: LinearProgressIndicator(
                            minHeight: 30,
                            value: _uploadProgress,
                            backgroundColor: Color.fromARGB(255, 249, 126, 84),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 249, 98, 46),
                            ),
                          ),
                        ),
                        _uploadProgress > 0
                            ? Text(
                                "${(_uploadProgress * 100).toStringAsFixed(2)}%",
                                style: TextStyle(
                                    fontFamily: "inter", fontSize: 14),
                              )
                            : Text(
                                "Conecting",
                                style: TextStyle(
                                    fontFamily: "inter", fontSize: 14),
                              )
                      ],
                    )
                  : Container(),
            ],
          ))),
    );
  }
}
