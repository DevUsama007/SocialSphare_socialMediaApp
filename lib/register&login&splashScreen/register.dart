// import 'package:firebaseproject/file_upload_firebase_storage/add_user.dart';
// import 'package:firebaseproject/homepage.dart';
// import 'package:firebaseproject/login.dart';
// import 'package:firebaseproject/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/homepage.dart';
import 'package:social_sphere/introductionScreens/introductionScreen.dart';
import 'package:social_sphere/main.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sphere/register&login&splashScreen/complete_profile.dart';
import 'package:social_sphere/register&login&splashScreen/login.dart';
import 'package:social_sphere/register&login&splashScreen/splashScreen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Message mess = Message();
  bool processing = false;
  validation() {
    setState(() {
      processing = true;
    });
    if (email.text.toString() == "" ||
        pass.text.toString() == "" ||
        confirm_password.text.toString() == "") {
      setState(() {
        processing = false;
      });
      mess.infoMessage(context, "Input Field error", "Input Field is Empty");
    } else {
      register();
    }
  }

  register() {
    setState(() {
      processing = true;
    });
    _auth
        .createUserWithEmailAndPassword(
            email: email.text.toString(), password: pass.text.toString())
        .then((value) {
      mess.infoMessage(context, "Sucess", "User Register Sucessfuly");
      setState(() {
        processing = false;
      });
      var user = _auth.currentUser;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return CompleteProfile();
        },
      ));
    }).onError((error, stackTrace) {
      setState(() {
        processing = false;
      });
      mess.infoMessage(context, "Error Occured", error.toString());
    });
  }

  var eyeicon = Icons.visibility;
  bool ischeck = false;

  bool check = false;
  TextEditingController confirm_password = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController email = TextEditingController();
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
                height: 70,
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.7,
              //   height: 80,
              //   child: Image.asset("assets/images/SS_LOGO.png"),
              // ),

              Text(
                "Create Account",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      "Fill your information below or register ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 14),
                    ),
                    Text(
                      "with your social account ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
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
                      "Email",
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
                  controller: email,
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
                    hintText: "example@gmail.com",
                    prefixIcon: Icon(Icons.email),
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
                      "Password",
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
                  controller: pass,
                  obscureText: ischeck,
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
                      hintText: "Password",
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            if (ischeck) {
                              setState(() {
                                ischeck = false;
                                eyeicon = Icons.visibility;
                              });
                            } else {
                              setState(() {
                                ischeck = true;
                                eyeicon = Icons.visibility_off;
                              });
                            }
                          },
                          child: Icon(
                            eyeicon,
                            color: Colors.black,
                          ))),
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
                      "Confirm Password",
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
                  controller: confirm_password,
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
                    hintText: "confirm password",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    side: WidgetStateBorderSide.resolveWith(
                      (states) => BorderSide(width: 1.0, color: Colors.red),
                    ),
                    fillColor: WidgetStatePropertyAll(
                        Color.fromARGB(255, 249, 98, 46)),
                    activeColor: Colors.white,
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    value: check,
                    onChanged: (value) {
                      setState(() {
                        check = !check;
                        // print(check);
                      });
                    },
                  ),
                  Text(
                    "Agree with",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "Terme & Condition",
                    style: TextStyle(
                        color: Color.fromARGB(255, 249, 98, 46),
                        fontFamily: "inter",
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 249, 98, 46),
                        decorationThickness: 2),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              processing
                  ? ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(
                              MediaQuery.of(context).size.width * 0.9, 50))),
                      onPressed: !processing ? () {} : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            " Sign Up",
                            style: TextStyle(fontFamily: "inter", fontSize: 17),
                          ),
                        ],
                      ))
                  : ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(
                              MediaQuery.of(context).size.width * 0.9, 50))),
                      onPressed: check
                          ? () {
                              validation();
                            }
                          : null,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontFamily: "inter", fontSize: 17),
                      )),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Divider(),
                  ),
                  Text(
                    "or Sign Up with",
                    style: TextStyle(
                        color: Color.fromARGB(255, 121, 121, 121),
                        fontFamily: "inter",
                        fontSize: 14),
                  ),
                  Container(
                    width: 100,
                    child: Divider(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Color.fromARGB(255, 176, 176, 176))),
                        child: Image.asset(
                          'assets/images/apple.png',
                          width: 30,
                          height: 30,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Color.fromARGB(255, 176, 176, 176))),
                        child: Image.asset(
                          'assets/images/google.png',
                          width: 30,
                          height: 30,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        // Message info = Message();
                        // info.infoMessage(context, "Error Occured",
                        //     "Please check your internet connection");
                      },
                      child: Container(
                          width: 50,
                          height: 50,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Color.fromARGB(255, 176, 176, 176))),
                          child: Image.asset(
                            color: const Color.fromARGB(255, 8, 126, 223),
                            'assets/images/facebook.png',
                            width: 30,
                            height: 30,
                          )),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't Have An Account? ",
                    style: TextStyle(
                        color: Color.fromARGB(255, 121, 121, 121),
                        fontFamily: "inter",
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => login(),
                          ));
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color.fromARGB(255, 249, 98, 46),
                        fontFamily: "inter",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ))),
    );
  }
}
