
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; 
import 'package:logger/logger.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)

final logger = Logger();
class MyHelpers{
  static msg(String txt, {int? sec, Color? bcolor}){
    sec ??= 2;
    bcolor ??= Colors.redAccent;
    Fluttertoast.showToast(
      msg: txt,toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec,  backgroundColor: bcolor, textColor: Colors.white,fontSize: 16.0);
  }
  static showIt(String? value, {String? label, int? sec, Color? bcolor}){
  label ??= "Value";
  sec ??=2;
  bcolor ??= Colors.lightBlue;
  logger.i("$label $value");
  MyHelpers.msg("$label:  $value",bcolor: bcolor,sec: sec);   
}
}
