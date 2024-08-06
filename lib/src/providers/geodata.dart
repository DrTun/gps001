import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gps001/src/helpers/helpers.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart'; 
//  -------------------------------------    GeoData (Property of Nirvasoft.com)
class GeoData{
  static int counter=0;
  static double lat=0;
  static double lng=0; 
  static DateTime dtime= DateTime.now();
  static bool tripStarted=false;
  static Polyline polyline01 = Polyline(points: [], color: Colors.blue,strokeWidth: 3,
  );


  static bool showLatLng=true;
  static bool centerMap=true;
  static bool listenChanges=true;
  static double zoom=16;
  static int interval=2000;
  static double distance=0;

  static const double defaultLat=1.3521;
  static const double defaultLng=103.8198;

  static void setLocation(double lat, double lng, DateTime dt){
    if (lat!=0 && lng!=0){
      GeoData.lat=lat;
      GeoData.lng=lng;
      GeoData.dtime=dt;
      if (tripStarted){polyline01.points.add(LatLng(lat, lng));}
    }
  }

  static void startTrip(){
    polyline01.points.clear();
    tripStarted=true;
  }
  static void endTrip(){
    tripStarted=false;
  }
  static Future<bool> chkPermissions(Location location) async{
    bool serviceEnabled;
    PermissionStatus permissionGranted; 
    try { 
        serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (serviceEnabled) {
            logger.i("Service Enabled");
          } else {
            logger.i("Service Disabled");
            return false;
          }
        }
        permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          if (permissionGranted == PermissionStatus.granted) {
            logger.i("Permission Granted");
          } else {
            logger.i("Permission Denined");
            return false;
          }
        }
    } catch (e) {
      logger.e("Permission Exception (getCurrentLocation)");
    return false;
    }
    return true;
  } 
  static Future<LocationData?> getCurrentLocation(Location location) async { 
      LocationData locationData;
      bool serviceEnabled=await chkPermissions(location);
      if (serviceEnabled) {
        locationData = await location.getLocation();
        GeoData.setLocation(locationData.latitude!, locationData.longitude!, DateTime.now());
        return locationData;
      } else {
        return null;
      } 
  }
}
//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)
class LocationNotifier extends ChangeNotifier {
  LocationNotifier() { 
    _loc01 = Loc01(0, 0,  DateTime(2000));
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
class Loc01 {
  final double  lat;
  final double lng; 
  final DateTime dt;
  Loc01(this.lat, this.lng, this.dt);
} 
//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)

