import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zubarider/controllers/pref_controller.dart';
import 'package:zubarider/mech/customWidgets.dart';
import 'package:zubarider/screens/splash.dart';
import 'package:pusher_websocket_flutter/pusher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    //initialize pusher
    initPusher();
    //connect pusher
    connectPusher();
    //pusher subscription
    subscribeToBinRequests();
  }

  //init pusher
  Future<void> initPusher() async {
    try {
      await Pusher.init(
        "860270340f667b4a303d",
        PusherOptions(cluster: "mt1", encrypted: true),
        enableLogging: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }
  }

  //connect pusher
  connectPusher() async {
    await Pusher.connect(
        onConnectionStateChange: (ConnectionStateChange event) {
      print("Pusher Socket Connection");
      print(event.currentState);
    }, onError: (ConnectionError error) {
      print("Pusher Socket Exception");
      print(error.message);
      print(error.exception);
    });
  }

  //subscribe to bin requests
  subscribeToBinRequests() async {
    Channel channel = await Pusher.subscribe('bin-status');
    await channel.bind('bin.status', (Event event) async {
      //decode data to map
      var data = jsonDecode(event.data);

      print(data);

      // store any available order locally
      await PrefController.saveLatestOreder(data);
      defaultDialog(context,
          title: 'Order Request',
          message:
              'The current weight of this bin is 83kg. Do you want to accept order?',
          primaryButtonText: "Yes",
          onPrimaryPress: () {},
          secondaryButtonText: 'Cancel', onSecondaryPress: () {
        Navigator.of(context).pop();
      });
      print('Main.dart says: All done here');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Calibri'),
        home: SplashScreen());
  }
}
