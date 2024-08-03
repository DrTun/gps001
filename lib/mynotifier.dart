import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
//  -------------------------------------    My Notifier (Property of Nirvasoft.com)
class MyNotifier extends ChangeNotifier {
  MyNotifier() {
    _data01 = Data01('CCT1', 'Clean Code Template'); 
    _loc01 = Loc01(0, 0,  DateTime(2000));
  }

  late Data01 _data01;
  Data01 get data01 => _data01;
  void updateData01(String id, String name) {
    _data01 = Data01(id, name);
    notifyListeners(); // Notify listeners that the data has changed
  } 

  late Loc01 _loc01;
  Loc01 get loc01 => _loc01;
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;
  
  void updateLoc1(double lon, double lat, DateTime dt){
    _loc01 = Loc01(lon, lat, dt);
    notifyListeners();
  }

}
class Data01 {
  final String id;
  final String name;
  Data01(this.id, this.name);
}
class Loc01 {
  final double  lat;
  final double lng; 
  final DateTime dt;
  Loc01(this.lat, this.lng, this.dt);
} 