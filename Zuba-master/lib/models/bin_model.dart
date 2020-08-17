import 'package:flutter/material.dart';

class Bin {
  int binID;
  String nickName;
  String serialNumber;
  var currentLevel;
  var currentWeight;
  String smokeNotification;

  Bin(
      {@required this.binID,
      @required this.nickName,
      @required this.serialNumber,
      @required this.currentLevel,
      @required this.currentWeight,
      @required this.smokeNotification});

  Bin.fromMap(obj) {
    this.binID = obj['id'];
    this.nickName = obj['nick_name'];
    this.serialNumber = obj['serial_number'];
    this.currentLevel = obj['current_level'];
    this.currentWeight = obj['current_weight'];
    this.smokeNotification = obj['smoke_noti'];
  }
}
