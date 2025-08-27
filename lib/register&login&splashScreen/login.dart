import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/alert_message.dart';
import 'package:social_sphere/forgot_pass&OTPScreen/forgot_password.dart';
import 'package:social_sphere/homepage.dart';
import 'package:social_sphere/register&login&splashScreen/complete_profile.dart';
import 'package:social_sphere/register&login&splashScreen/register.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool processing = false;
  Message mess = Message();
  validation() {
    setState(() {
      processing = true;
    });
    if (email.text.toString() == "" || pass.text.toString() == "") {
      setState(() {
        processing = false;
      });
      mess.infoMessage(context, "Input Field error", "Input Field is Empty");
      print(_auth.currentUser!.uid);
    } else {
      login();
    }
  }

  login() {
    setState(() {
      processing = true;
    });
    _auth
        .signInWithEmailAndPassword(
            email: email.text.toString(), password: pass.text.toString())
        .then((value) {
      print(_auth.currentUser!.uid);
      setState(() {
        processing = false;
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ));
    }).onError((error, stackTrace) {
      setState(() {
        processing = false;
      });
      print(error.toString());
      mess.infoMessage(
          context, "Error Occured", "Check your email or password");
    });
  }

  var eyeicon = Icons.visibility;
  bool ischeck = false;
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
                height: 90,
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.7,
              //   height: 80,
              //   child: Image.asset("assets/images/SS_LOGO.png"),
              // ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Sign In",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Hi! Welcome Back,You've Been Missed",
                style: TextStyle(
                    color: Color.fromARGB(255, 121, 121, 121),
                    fontFamily: "inter",
                    fontSize: 15),
              ),
              SizedBox(
                height: 60,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => forgot_password(),
                          ));
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: Color.fromARGB(255, 249, 98, 46),
                          fontFamily: "inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 249, 98, 46),
                          decorationThickness: 2),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
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
                            " Sign In",
                            style: TextStyle(fontFamily: "inter", fontSize: 17),
                          ),
                        ],
                      ))
                  : ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(
                              MediaQuery.of(context).size.width * 0.9, 50))),
                      onPressed: () {
                        validation();
                      },
                      child: Text(
                        "Sign In",
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
                    "or Sign In with",
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
                    Container(
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
                        ))
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
                        fontSize: 15),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 249, 98, 46),
                        fontFamily: "inter",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ))),
    );
  }
}
