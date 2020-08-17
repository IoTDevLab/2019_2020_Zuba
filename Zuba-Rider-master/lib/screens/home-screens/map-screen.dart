// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:zubarider/controllers/api_controller.dart';
import 'package:zubarider/mech/constants.dart';
import 'package:zubarider/mech/eye_less.dart';
import 'package:zubarider/mech/screensize.dart';

class MapScreen extends StatefulWidget {
  final serialNumber;
  final lat;
  final long;
  final orderType;

  MapScreen({
    Key key,
    this.lat,
    this.long,
    this.serialNumber,
    this.orderType,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double binValue = 0.0;
  bool _isProcessing = false;

  // For storing the current position
  Position _currentPosition;

  // initial camera position (Ghana)
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(7.9528, -1.0307), zoom: 6.0);

  final Set<Polyline> polyline = {};

  GoogleMapController mapController;
  List<LatLng> routCoords;
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: Confident.MAPS_API);

  final Geolocator _geolocator = Geolocator();

  // check if location permission is allowed
  _checkPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    // LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // use the following two lines of code to also get the location
    // _locationData = await location.getLocation();
    // print(_locationData.toString());
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator.getCurrentPosition().then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });

      // await _createPolylines(position, _binCordinates);
    }).catchError((e) {
      print(e);
    });
  }

  getSomePoints() async {
    routCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        destination: LatLng(40.6944, -73.9212),
        mode: RouteMode.driving);
  }

  // Create the polylines for showing the route between two places
  // _createPolylines(Position start, Position destination) async {
  //   // Initializing PolylinePoints
  //   polylinePoints = PolylinePoints();

  //   // Generating the list of coordinates to be used for drawing the polylines
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     Confident.MAPS_API, // Google Maps API Key
  //     PointLatLng(start.latitude, start.longitude),
  //     PointLatLng(destination.latitude, destination.longitude),
  //     travelMode: TravelMode.driving,
  //   );

  //   // Adding the coordinates to the list
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }

  //   // Defining an ID
  //   PolylineId id = PolylineId('poly');

  //   // Initializing Polyline
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.red,
  //     points: polylineCoordinates,
  //     width: 3,
  //   );

  //   // Adding the polyline to the map
  //   polylines[id] = polyline;
  // }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routCoords,
          width: 7,
          color: Colors.red,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });
  }

  @override
  void initState() {
    super.initState();
    // _checkPermission();
    // _getCurrentLocation();
    getSomePoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialLocation,
            mapType: MapType.normal,
            polylines: polyline,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          // Button.back
          Positioned(
            child: Container(
              margin: EdgeInsets.only(top: 20, left: 20),
              width: 40.0,
              height: 60.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 9),
                        blurRadius: 10,
                        color: cardShadow.withOpacity(0.15))
                  ],
                  color: Colors.white),
              child: RaisedButton(
                elevation: 0.0,
                highlightElevation: 0.0,
                color: Colors.white,
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 25.0,
            left: screenWidth(context, dividedBy: 1.0) -
                screenWidth(context, dividedBy: 1.2, minus: 5.0) / 0.9,
            child: Container(
                height: screenHeight(context, dividedBy: 9.0),
                width: screenWidth(context, dividedBy: 1.2),
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 13,
                          color: cardShadow.withOpacity(0.1)),
                    ]),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            style: TextStyle(
                                                color: fDark,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              widget.orderType == 0
                                                  ? TextSpan(text: "Manual ")
                                                  : TextSpan(
                                                      text: "Automatic "),
                                              TextSpan(text: 'Pickup')
                                            ])),
                                    SizedBox(height: 5.0),
                                    RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                                color: fDark.withAlpha(190),
                                                fontSize: 15),
                                            children: [
                                          TextSpan(text: "Serial no: "),
                                          TextSpan(text: 'GH-8276-AS')
                                        ]))
                                  ]),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                width: screenWidth(context, dividedBy: 8.0),
                                height: screenWidth(context, dividedBy: 6.5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 9),
                                          blurRadius: 10,
                                          color: cardShadow.withOpacity(0.15))
                                    ],
                                    gradient: LinearGradient(
                                        colors: [gNext.withAlpha(180), gNext],
                                        stops: [0.5, 1],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight)),
                                child: Container(
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _getCurrentLocation();
                                      }),
                                ),
                              )),
                        ]))),
          ),
        ]),
      ),
    );
  }
}
