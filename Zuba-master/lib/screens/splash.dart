import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuba/controllers/pref_controller.dart';
import 'package:zuba/mech/customWidgets.dart';
import 'package:zuba/mech/drawings.dart';
import 'package:zuba/screens/auth-screens/login.dart';
import 'package:zuba/screens/home-screens/home-shell.dart';
import '../mech/constants.dart';
import '../mech/screensize.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // hide status bar
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    // continue after 3sec
    Future.delayed(Duration(seconds: 3), _autoLogUserIn);
  }

  //automatically logs user in if the token exists
  _autoLogUserIn() async {
    String token = await PrefController.getToken();
    if (token.isNotEmpty) {
      // show status bar
//      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

      //navigate to home page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeShell()));
    } else {
      // show status bar
//      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

      //navigate to home page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    // Main Background
                    Positioned(
                      child: Container(
                        child: CustomPaint(painter: DrawCircle()),
                      ),
                    ),

                    // Main Content.start
                    Container(
                      height: screenHeight(context, dividedBy: 1),
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 210.0),
                            child: Image.asset(
                              'assets/images/bin-logo-s.png',
                              width: 270.0,
                            ),
                          ),
                          SizedBox(
                              height: screenHeight(context, dividedBy: 2.0)),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Getting things ready...',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: fBright,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Container(child: loadingSpinner)
                        ],
                      ),
                    ) // Main Content.end
                  ],
                ),
              ),
            ],
          ),
        ),
        top: false,
        bottom: false,
      ),
    );
  }
}
