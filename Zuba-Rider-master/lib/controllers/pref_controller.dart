import 'package:shared_preferences/shared_preferences.dart';

class PrefController {
  //save logged in user details to prefs
  static saveUserDetails(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('title', data['title']);
    prefs.setString('fName', data['first_name']);
    prefs.setString('lName', data['last_name']);
    prefs.setString('oName', data['other_name']);
    prefs.setString('address', data['address']);
    prefs.setString('phone', data['telephone']);
    prefs.setString('email', data['email']);
    prefs.setInt('id', data['id']);
    prefs.setString('token', data['token']);
  }

  static getFName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fName') ?? "";
  }

  static getLName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('lName') ?? "";
  }

  static getOName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oName') ?? "";
  }

  static getRAdress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('address') ?? "";
  }

  static getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone') ?? "";
  }

  static getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? "";
  }

  static getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

  static getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }

  //save vehicle details to prefs
  static saveVehicleDetails(Map<String, dynamic> data) async {
    SharedPreferences vPrefs = await SharedPreferences.getInstance();
    vPrefs.setInt('id', data['id']);
    vPrefs.setString('vehicleID', data['reg_number']);
    vPrefs.setString('vehicleColor', data['color']);
    vPrefs.setString('vehicleBrand', data['brand']);
    vPrefs.setString('maxCapacity', data['max_capacity']);
    vPrefs.setInt('assignState', data['assign_state']);
  }

  static getVehicleID() async {
    SharedPreferences vPrefs = await SharedPreferences.getInstance();
    return vPrefs.getString('vehicleID') ?? "";
  }

//save latest order to prefs
  static saveLatestOreder(Map<String, dynamic> data) async {
    SharedPreferences oPrefs = await SharedPreferences.getInstance();
    oPrefs.setInt('id', data['request_id']);
    oPrefs.setString('requestType', data['request_type']);
    oPrefs.setString('binID', data['bin_id']);
    oPrefs.setString('long', data['bin_loc_long']);
    oPrefs.setString('lat', data['bin_loc_lat']);
    print('Pref_controller.dart says: All done here');
  }

  //clears logged in user data from
  static clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('id');
    prefs.remove('fName');
    prefs.remove('lName');
    prefs.remove('oName');
    prefs.remove('address');
    prefs.remove('phone');
    prefs.remove('email');
    prefs.remove('token');

    SharedPreferences vPrefs = await SharedPreferences.getInstance();
    vPrefs.remove('id');
    vPrefs.remove('vehicleID');
    vPrefs.remove('vehicleColor');
    vPrefs.remove('vehicleBrand');
    vPrefs.remove('maxCapacity');
    vPrefs.remove('assignState');
  }
}
