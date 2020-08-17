import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zuba/controllers/pref_controller.dart';
import 'package:zuba/screens/auth-screens/login.dart';

class APIController {
  Dio _dio;
  Options _options;

  // api url
  String _url = "https://zuba-app.herokuapp.com/api/v1";

  // id of the logged in user
  int _userId;

  APIController() {
    _dio = new Dio();
  }

  // login method
  Future<Response<dynamic>> login({String email, var password}) async {
    return await _dio.post("$_url/owner/login",
        data: {"email": email, "password": password});
  }

  // register method
  Future<Response<dynamic>> register(
      {String title,
      String firstName,
      String lastName,
      String otherName,
      String telephone,
      String address,
      String email,
      var password}) async {
    return await _dio.post("$_url/owner/register", data: {
      "title": title,
      "first_name": firstName,
      "last_name": lastName,
      "other_name": otherName,
      "telephone": telephone,
      "address": address,
      "email": email,
      "password": password
    });
  }

  // decodes data from string to json (Map)
  static decodeMapData(Response response) {
    return response.data['data'];
  }

  // decodes data from string to json (List)
  static List decodeListData(Response response) {
    return decodeMapData(response);
  }

  // accepts response and returns message
  static successMessage(Response response) {
    return response.data['success']['message'];
  }

  // decodes data using methods above and returns the message column for success or error responses from the api
  static errorMessage(DioError e, BuildContext context) {
    String message = e.response != null
        ? e.response.data['error']['message']
        : "No connectivity. Please check your internet connection and try again.";
    int statusCode = e.response != null ? e.response.data['error']['code'] : 0;

    // if response code is unauthenticated or unauthorized
    bool isUnauthorizedOrUnAuthenticated =
        statusCode == 401 || statusCode == 403;

    return isUnauthorizedOrUnAuthenticated
        ?
        // redirect to login page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()))
        : message;
  }

  // retrieve token and user id
  _setTokenHeaderAndUserId() async {
    String token = await PrefController.getToken();
    _userId = await PrefController.getId();

    // assign token
    _options = Options(headers: {"Authorization": "Bearer $token"});
  }

  // retrieve owner's bins
  // @return Response
  Future<Response<dynamic>> ownerBins() async {
    await _setTokenHeaderAndUserId();
    return await _dio.get("$_url/owner/bins", options: _options);
  }

  // manual request for pick up
  Future<Response<dynamic>> orderPickup({int binID}) async {
    return await _dio
        .post("$_url/bins/statistics/manualPickup", data: {"bin_id": binID});
  }
}
