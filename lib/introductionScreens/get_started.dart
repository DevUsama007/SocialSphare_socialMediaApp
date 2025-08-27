import 'package:flutter/material.dart';
import 'package:social_sphere/register&login&splashScreen/login.dart';
import 'package:social_sphere/register&login&splashScreen/register.dart';

class get_started extends StatefulWidget {
  const get_started({super.key});

  @override
  State<get_started> createState() => _get_startedState();
}

class _get_startedState extends State<get_started> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 60,
              child: Image.asset("assets/images/SS_LOGO.png"),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30),
              width: 400,
              height: 250,
              child: Image.asset("assets/images/get_started.png"),
            ),
            SizedBox(
              height: 10,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Your Premier ",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Text(
                  "Social Network App ",
                  style: TextStyle(
                      color: Color.fromARGB(255, 249, 98, 46),
                      fontFamily: "inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.8, 50))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Register(),
                      ));
                },
                child: Text(
                  "Let's Get Started",
                  style: TextStyle(fontFamily: "inter", fontSize: 17),
                )),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already Have An Account? ",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
