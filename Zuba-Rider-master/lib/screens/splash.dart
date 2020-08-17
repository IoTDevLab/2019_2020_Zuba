import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zubarider/controllers/pref_controller.dart';
import 'package:zubarider/mech/customWidgets.dart';
import 'package:zubarider/mech/drawings.dart';
import 'package:zubarider/screens/auth-screens/login.dart';
import 'package:zubarider/screens/home-screens/home-shell.dart';
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
                          SizedBox(height: 15.0),
                          Text(
                            'Rider',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                letterSpacing: 2.2),
                          ),
                          SizedBox(
                              height: screenHeight(context, dividedBy: 2.0)),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
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

// loading circs
// List<Widget> createLoader(int count) {
//   int i = 0;

//   List<Widget> circs = List<Widget>();
//   while (i < count) {
//     Container circ = Container(
//       height: 14,
//       width: 14,
//       margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
//       decoration:
//           BoxDecoration(borderRadius: BorderRadius.circular(50), boxShadow: [
//         BoxShadow(
//             offset: Offset(0, 2),
//             blurRadius: .08,
//             color: Colors.black.withOpacity(.10)),
//       ]),
//       child: CustomPaint(painter: DrawLoader()),
//     );
//     i++;
//     circs.add(circ);
//   }
//   return circs;
// }
