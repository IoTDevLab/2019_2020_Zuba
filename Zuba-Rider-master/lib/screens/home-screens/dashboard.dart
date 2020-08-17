import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zubarider/controllers/pref_controller.dart';
import 'package:zubarider/controllers/api_controller.dart';
import 'package:zubarider/mech/constants.dart';
import 'package:zubarider/mech/customWidgets.dart';
import 'package:zubarider/mech/screensize.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zubarider/models/order_model.dart';
import 'package:zubarider/screens/home-screens/map-screen.dart';
import 'package:zubarider/mech/drawings.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String fName = '';
  String residenceAddress = '';
  var token;
  var vehicleID = '';

  // get orders
  int _order = 1;
  List<Orders> _orders = [];

  var pickup = DateTime.parse('2020-08-02 13:00:00.000000'); // last pickup time
  var _pickedTime;

  //holds status for loading api data
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    getVehicleData();
    callData();
    _pickUpTime();
    // _loadOrders();
  }

  callData() async {
    fName = await PrefController.getFName();
    residenceAddress = await PrefController.getRAdress();
    vehicleID = await PrefController.getVehicleID();
  }

  _pickUpTime() async {
    final now = new DateTime.now();
    final difference = now.difference(pickup);
    final result = timeago.format(now.subtract(difference), locale: 'en');
    setState(() {
      _pickedTime = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Container(
          color: Colors.grey.withAlpha(20),
          width: double.infinity,
          height: screenHeight(context, dividedBy: 1.0),
          child: Stack(children: <Widget>[
            ClipPath(
              clipper: BezierClipper(),
              child: Container(
                color: gStart.withAlpha(200),
                height: screenHeight(context, dividedBy: 2.6),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 30),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: fBright),
                          children: [
                        TextSpan(text: "Hello "),
                        TextSpan(text: fName)
                      ])),
                ),
                SizedBox(height: 13),
                Center(
                  child: OverViewCard(
                    lastPickup: _pickedTime,
                    ordersCompleted: _order - 1,
                    vehicleID: '$vehicleID',
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, bottom: 0),
                  child: Text("Latest Pickup Order",
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: fDark)),
                ),
                _orderListBuilder()
              ],
            ),
          ]),
        ),
      ),
    );
  }

  _orderListBuilder() {
    return Expanded(
      child: _isProcessing
          ? Center(
              child: loadingSpinner2,
            )
          : _orders.length > 0
              ? ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, position) {
                    return _orderBuilder(_orders[position]);
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("No pickup orders at the moment",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black26,
                          )),
                      IconButton(
                          color: Colors.blueAccent,
                          icon: Icon(Icons.map),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MapScreen(lat: 2, long: 3))))
                    ],
                  ),
                ),
    );
  }

  _orderBuilder(Orders bin) {
    return OrderListCard(
      nickName: null,
      requestType: null,
      pickupMsg: () {
        defaultDialog(context,
            title: 'Order Request',
            message:
                'The current weight of this bin is 83kg. Do you want to accept order?',
            primaryButtonText: "Yes",
            onPrimaryPress: () {
              _acceptPickupOrder(context, bin.binID);
            },
            secondaryButtonText: 'Cancel',
            onSecondaryPress: () {
              Navigator.of(context).pop();
            });
      },
      routTo: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MapScreen(orderType: 0, lat: 3.0, long: 1.2),
            ));
      },
    );
  }

  // get and send vehicle data to prefControl
  getVehicleData() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    token = await PrefController.getToken();

    await APIController().vehicleDetails(token: token).then(
        (Response<dynamic> response) async {
      // Decode the data
      final vehicle = APIController.decodeMapData(response);

      vehicle.isEmpty
          ? setState(() {
              vehicleID = 'No vehicle assigned';
              _isProcessing = false;
            })
          : setState(() {
              vehicleID = (vehicle[0]['reg_number']);
              _isProcessing = false;
            });

      setState(() {
        _isProcessing = false;
      });
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

  // Function to accept an order for a pickup
  _acceptPickupOrder(BuildContext context, int binID) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    await APIController().orderPickup(binID: binID).then(
        (Response<dynamic> response) async {
      setState(() {
        _isProcessing = false;
      });
      Navigator.of(context).pop();
    }, onError: (e) {
      setState(() {
        _isProcessing = false;
      });

      // Display error message if any
      Future(errorDialog(context,
          title: "Error",
          message: APIController.errorMessage(e, context),
          primaryButtonText: "Ok", onPrimaryPress: () {
        Navigator.of(context).pop();
      }));
    });
  }
}
