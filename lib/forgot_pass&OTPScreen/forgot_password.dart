import 'package:flutter/material.dart';

class forgot_password extends StatefulWidget {
  const forgot_password({super.key});

  @override
  State<forgot_password> createState() => _forgot_passwordState();
}

class _forgot_passwordState extends State<forgot_password> {
  var eyeicon = Icons.visibility;
  bool ischeck = false;

  bool check = false;
  TextEditingController pass = TextEditingController();
  TextEditingController confirm_pass = TextEditingController();
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
              Container(
                width: 200,
                height: 200,
                child: Image.asset("assets/images/forgot_pass_dark.png"),
              ),
              Text(
                "New Password",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      "Your New Password Must Be Different ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 121, 121, 121),
                          fontFamily: "inter",
                          fontSize: 14),
                    ),
                    Text(
                      "From Previously Used Password ",
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
                  controller: confirm_pass,
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
                      hintText: "Confirm Password",
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
                height: 25,
              ),

              ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.9, 50))),
                  onPressed: () {},
                  child: Text(
                    "Create New Password",
                    style: TextStyle(fontFamily: "inter", fontSize: 17),
                  )),
            ],
          ))),
    );
  }
}
