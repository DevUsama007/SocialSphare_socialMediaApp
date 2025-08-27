import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditMyProfile extends StatefulWidget {
  final String uid;
  final String name;
  final String username;
  final String userbio;
  final String userimagelink;
  final String userPHONE;

  EditMyProfile(
      {super.key,
      required this.uid,
      required this.name,
      required this.username,
      required this.userbio,
      required this.userimagelink,
      required this.userPHONE});

  @override
  State<EditMyProfile> createState() => _EditMyProfileState();
}

class _EditMyProfileState extends State<EditMyProfile> {
  bool uploading = false;
  double _uploadProgress = 0.0;
  setinialValue() {
    setState(() {
      pickedImage = null;
      update_name.text = widget.name == null ? "" : widget.name;

      update_username.text = widget.username == null ? "" : widget.username;
      update_phone.text = widget.userPHONE == null ? "" : widget.userPHONE;
      update_bio.text = widget.userbio == null ? "" : widget.userbio.toString();
    });
  }
  // UpdateProfileUi(BuildContext context) {
  // setState(() {
  //   pickedImage = null;
  //   update_name.text = widget.name == null ? "" : widget.name;

  //   update_username.text = widget.username == null ? "" : widget.username;
  //   update_phone.text = widget.userPHONE== null ? "" : widget.userPHONE;
  //   update_bio.text = widget.userbio == null ? "" : widget.userbio.toString();
  // });

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, StateSetter setState) {
  //           return    },
  //       );
  //     },
  //   );
  // }

  bool withoutimageupload = false;
//update profile functions

  final firestore = FirebaseFirestore.instance.collection('User_Profile');
  final userPostInstance = FirebaseFirestore.instance.collection('User_Posts');
  validation() {
    if (update_name.text.toString() == "" ||
        update_username.text.toString() == "" ||
        update_phone.text.toString() == "") {
      mess.infoMessage(context, "Input Field error", "Input Field is Empty");
    } else {
      insertUserProfileData();
    }
  }

  insertUserProfileData() {
    pickedImage == null ? withoutImageProfileData() : withImageProfileData();
  }

  //uploading without image
  Future withoutImageProfileData() async {
    setState(() {
      withoutimageupload = true;
    });

    firestore.doc(widget.uid).set({
      "user_id": widget.uid.toString(),
      "Name": update_name.text,
      "bio": update_bio.text,
      "user_name": update_username.text,
      "phone": update_phone.text,
      "profile_image_link": widget.userimagelink.toString()
    }).then(
      (value) {
        updateDataInUserPosts();
      },
    ).onError(
      (error, stackTrace) {
        setState(() {
          uploading = false;
          withoutimageupload = false;
        });
        mess.infoMessage(context, "Uploading Failed", error.toString());
      },
    );
  }

  void updateDataInUserPosts() async {
    // Reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query to find all posts where userId matches myId
    QuerySnapshot querySnapshot = await firestore
        .collection('User_Posts')
        .where('userID', isEqualTo: widget.uid)
        .get();

    // Loop through each document and update the username
    for (var doc in querySnapshot.docs) {
      print("---------------------------------------------");
      print(doc.id);

      await firestore.collection('User_Posts').doc(doc.id).update({
        'name': update_name.text,
        'username': update_username.text,
      });
    }
    mess.infoMessage(context, "Success", "Profile Updated");
    setState(() {
      _uploadProgress = 0.0;
      uploading = false;
      withoutimageupload = false;
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

    print("Username updated successfully!");
  }

// uploading with image
  Future withImageProfileData() async {
    setState(() {
      uploading = true;
    });
    print("click");
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref("images/" + widget.uid.toString()
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
        firestore.doc(widget.uid).set({
          "user_id": widget.uid.toString(),
          "Name": update_name.text,
          "bio": update_bio.text,
          "user_name": update_username.text,
          "phone": update_phone.text,
          "profile_image_link": newUrl
        }).then(
          (value) {
            updateDataInUserPosts();
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

  Message mess = Message();
// update profile functions ends here
  //text fields to update the profile
  TextEditingController update_name = TextEditingController();
  TextEditingController update_username = TextEditingController();
  TextEditingController update_phone = TextEditingController();
  TextEditingController update_bio = TextEditingController();

//function for pick the image from memory
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

  @override
  void initState() {
    setinialValue();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Hero(
        tag: 'editProfileScreen',
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                children: [
                  pickedImage == null
                      ? Stack(
                          children: [
                            Positioned(
                                child: Container(
                              padding: EdgeInsets.only(top: 10),
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: pickedImage == null
                                          ? widget.userimagelink == null
                                              ? AssetImage(
                                                  "assets/images/person_icon.png")
                                              : NetworkImage(
                                                  widget.userimagelink)
                                          : FileImage(File(
                                              pickedImage!.path.toString()))),
                                  color: Color.fromARGB(255, 224, 223, 223),
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
                                          color:
                                              Color.fromARGB(255, 249, 98, 46),
                                          borderRadius:
                                              BorderRadius.circular(16)),
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
                                          color:
                                              Color.fromARGB(255, 249, 98, 46),
                                          borderRadius:
                                              BorderRadius.circular(16)),
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
                      controller: update_name,
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
                        prefixIcon: Icon(Icons.person),
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
                      controller: update_username,
                      textAlign: TextAlign.start,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontFamily: "inter",
                            textBaseline: TextBaseline.alphabetic,
                            color: Color.fromARGB(255, 121, 121, 121)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none
                            // Optional: for rounded corners
                            // borderSide: BorderSide(
                            //   color: Colors.grey, // Color of the border
                            //   width: 2.0, // Width of the border
                            // ),
                            ),
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
                        prefixIcon: Icon(Icons.person),
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
                      controller: update_phone,
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
                        prefixIcon: Icon(Icons.phone),
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
                          "Bio",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "inter",
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    style: TextStyle(color: Colors.black),
                    controller: update_bio,
                    decoration: InputDecoration(
                      hintText: 'Add Your Bio...',
                      hintStyle:
                          TextStyle(color: Colors.black.withOpacity(0.4)),
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
                      filled: true,
                      fillColor: Color.fromARGB(255, 224, 223, 223),
                    ),
                    minLines: 2,
                    maxLines: null,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  !withoutimageupload
                      ? !uploading
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: WidgetStatePropertyAll(Size(
                                      MediaQuery.of(context).size.width * 0.9,
                                      50))),
                              onPressed: !uploading
                                  ? () {
                                      validation();
                                      // updateDataInUserPosts();
                                    }
                                  : null,
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                    fontFamily: "inter", fontSize: 17),
                              ))
                          : _uploadProgress > 0
                              ? ElevatedButton(
                                  style: ButtonStyle(
                                      minimumSize: WidgetStatePropertyAll(Size(
                                          MediaQuery.of(context).size.width *
                                              0.9,
                                          50))),
                                  onPressed: () {},
                                  child: Text(
                                    "${(_uploadProgress * 100).toStringAsFixed(2)}%",
                                    style: TextStyle(
                                        fontFamily: "inter", fontSize: 14),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ButtonStyle(
                                      minimumSize: WidgetStatePropertyAll(Size(
                                          MediaQuery.of(context).size.width *
                                              0.9,
                                          50))),
                                  onPressed: () {},
                                  child: Text(
                                    "Conecting",
                                    style: TextStyle(
                                        fontFamily: "inter", fontSize: 14),
                                  ),
                                )
                      : ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: WidgetStatePropertyAll(Size(
                                  MediaQuery.of(context).size.width * 0.9,
                                  50))),
                          onPressed: () {},
                          child: Text(
                            withoutimageupload
                                ? "updating.."
                                : "Update Profile",
                            style: TextStyle(fontFamily: "inter", fontSize: 17),
                          )),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
