import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zubarider/controllers/api_controller.dart';
import 'package:zubarider/controllers/pref_controller.dart';
import 'package:zubarider/mech/constants.dart';
import 'package:zubarider/mech/customWidgets.dart';
import 'package:zubarider/mech/drawings.dart';
import 'package:zubarider/mech/input_validations.dart';
import 'package:zubarider/mech/screensize.dart';
import 'package:flutter/gestures.dart';
import 'package:zubarider/screens/auth-screens/signup.dart';
import 'package:zubarider/screens/home-screens/home-shell.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Form builder key
  final _formKey = GlobalKey<FormState>();

  // Keeps track of the login process
  bool _isProcessing = false;

  // Form inputs
  String _email = '';
  var _password = '';

  @override
  Widget build(BuildContext context) {
    // get status bar height
    double statusBarH = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: bColor1,
      body: SafeArea(
        child: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: screenHeight(context, minus: statusBarH),
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
                          alignment: Alignment.center,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 90.0),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/bin-logo-s.png',
                                      width: 190.0,
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'Rider',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23.0,
                                          letterSpacing: 2.2),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: screenHeight(context, dividedBy: 9)),
                              Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: Container(
                                  width: screenWidth(context, dividedBy: 1.21),
                                  child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          TextFormField(
                                            onChanged: (value) {
                                              setState(() => _email = value);
                                            },
                                            validator: emailValidation,
                                            decoration: customInput.copyWith(
                                                hintText: 'Email',
                                                icon: Image.asset(
                                                    'assets/images/Contacts_26px.png',
                                                    width: 26)),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          SizedBox(
                                            height: 17.0,
                                          ),
                                          TextFormField(
                                            onChanged: (value) {
                                              setState(() => _password = value);
                                            },
                                            validator:
                                                passLenValidation, // modify to compare with database
                                            decoration: customInput.copyWith(
                                                hintText: 'Password',
                                                icon: Image.asset(
                                                    'assets/images/Key_24px.png',
                                                    width: 26)),
                                            obscureText: true,
                                          ),
                                          SizedBox(
                                            height: 17.0,
                                          ),
                                          CustomButton(
                                              buttonType:
                                                  ButtonType.defaultButton,
                                              width: screenWidth(context,
                                                  dividedBy: 1.211,
                                                  minus: 42.0),
                                              height: null,
                                              buttonChild: _isProcessing
                                                  ? loadingSpinner
                                                  : Text(
                                                      'LOGIN',
                                                      style: TextStyle(
                                                        fontSize: 22.0,
                                                      ),
                                                    ),
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  _submitDataToApi(context,
                                                      _email, _password);
                                                }
                                              }),
                                          SizedBox(
                                            height: 17.0,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 40.0),
                                            child: Center(
                                                child: RichText(
                                              text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            'Don\'t have an account yet? Tap '),
                                                    TextSpan(
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    SignUp())),
                                                      text: 'HERE',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                    TextSpan(
                                                        text:
                                                            ' to create an account.')
                                                  ],
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: fBright,
                                                      letterSpacing: 0.2)),
                                            )),
                                          )
                                        ],
                                      )),
                                ),
                              )
                            ],
                          ),
                        )
                        // Main Content.end
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
        top: true,
        bottom: false,
      ),
    );
  }

// Submits data to api
  void _submitDataToApi(
      BuildContext context, String email, String password) async {
    // if a login process is already ongoing, exit
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    await APIController().login(email: email, password: password).then(
        (Response<dynamic> response) async {
      // Decode the data
      Map<String, dynamic> data = APIController.decodeMapData(response);

      // Save details to device
      await PrefController.saveUserDetails(data);

      setState(() {
        _isProcessing = false;
      });

      // Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeShell()),
          (Route<dynamic> route) => false);
    }, onError: (e) {
      // DioError

      setState(() {
        _isProcessing = false;
      });

      // Display error notification if any
      Future(errorDialog(context,
          title: "Error",
          message: APIController.errorMessage(e, context),
          primaryButtonText: "Ok", onPrimaryPress: () {
        Navigator.of(context).pop();
      }));
    });
  }

// error.message
  errorMessage() {}
}
