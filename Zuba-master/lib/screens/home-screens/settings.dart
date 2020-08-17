import 'package:flutter/material.dart';
import 'package:zuba/controllers/pref_controller.dart';
import 'package:zuba/mech/constants.dart';
import 'package:zuba/mech/customWidgets.dart';
import 'package:zuba/mech/screensize.dart';
import 'package:zuba/screens/auth-screens/login.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey.withOpacity(.05),
          width: double.infinity,
          height: screenHeight(context, dividedBy: 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25, left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Settings",
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: fHeader)),
                    SizedBox(height: 5),
                    Text(
                      'Options you can use to configure the app.',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: <Widget>[
                    CustomButton(
                        height: 45.0,
                        width: 120.0,
                        buttonType: ButtonType.dangerButton,
                        buttonChild: _isProcessing
                            ? loadingSpinner
                            : Text(
                                'Sign Out',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                        onPressed: () {
                          _logOut();
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logOut() {
    dangerDialog(context,
        title: "Log Out",
        message: "Are you sure you want to logout?", onPrimaryPress: () async {
      await PrefController.clearUserDetails();

      // Navigate to Login
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false);
    });
  }
}
