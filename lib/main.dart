import 'dart:async';

import 'package:flutter/material.dart';
import 'helpers.dart';
import 'map.dart';
import 'mynotifier.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

void main() async{
  runApp(
          MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()) // Provider
      ],
    
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});
  @override
  MyStatefulWidgetState createState() => MyStatefulWidgetState();
}

class MyStatefulWidgetState extends State<MyStatefulWidget> {
  final logger=Logger();
  late MyNotifier provider ;  // Provider Declaration and init
  
  // GPS Declare >>>>
  final Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  // GPS Declare -------------------
  @override
  void initState() {
    super.initState(); 
    // Provider init
    provider = Provider.of<MyNotifier>(context,listen: false);
    // GPS Init >>>>
    // Permission and get current location
   chkGPSPermission().then((value) => () {
      if (value) {
        location.enableBackgroundMode(enable: true);
        logger.i("Permission Granted");
      } else {
        logger.i("Permission Denied");
      }
    });
    // Listener 
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 3000);
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      GlobalData.counter++;
      var lat= currentLocation.latitude;
      var lng= currentLocation.longitude; 
      TheLocation.set(currentLocation.latitude!, currentLocation.longitude!, DateTime.now());
      provider.updateLoc1(TheLocation.lat, TheLocation.lng, TheLocation.dtime);
      provider.updateData01("$lat","$lat");
      MyHelpers.showIt("$lat x $lng ",label: "(${GlobalData.counter}) ",sec: 2); 
    });
    locationSubscription.pause();
    // GPS Init -------------------
  } 
  Future<bool> chkGPSPermission() async{
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
  Future<LocationData?> getCurrentLocation(Location location) async { 
      LocationData locationData;
      bool serviceEnabled=await chkGPSPermission();
      if (serviceEnabled) {
        locationData = await location.getLocation();
        TheLocation.set(locationData.latitude!, locationData.longitude!, DateTime.now());
        return locationData;
      } else {
        return null;
      } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS 001'),

            actions: [
              PopupMenuButton<String>(          
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async { 
                  if (value == 'START') {GlobalData.counter=0;locationSubscription.resume(); } 
                  else if (value == 'STOP') { GlobalData.counter=0;locationSubscription.pause(); } // Provider Update
                  else if (value =="CURRENT"){ 
                    var locationData = await getCurrentLocation(location); 
                    if (locationData != null) {
                      var lng= locationData.longitude;
                      var lat= locationData.latitude;
                      provider.updateLoc1(TheLocation.lat, TheLocation.lng, TheLocation.dtime);
                      provider.updateData01("$lat","$lat");
                      MyHelpers.showIt("$lat x $lng",label: "Show Location: ",sec: 5);
                    } else {
                    logger.i("Permission Denied");
                    }  
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>( value: 'START',  child: Text('Start'),  ),
                  const PopupMenuItem<String>( value: 'STOP',  child: Text('Stop'), ),
                  const PopupMenuItem<String>( value: 'CURRENT',  child: Text('Current'), ),
                ],
              ),
            ],
      ),
      body: Column(
        children: [
          const Text(" "),
          ElevatedButton(
          onPressed: () async { 
            provider.updateLoc1(TheLocation.lat, TheLocation.lng, TheLocation.dtime);
            provider.updateData01("$TheLocation.lat","$TheLocation.lat");
          },
          child: const Text('Refresh'),
          ), 
             SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                child: const MyMap()),
          
        ],
      ),
    );
  }
}
class GlobalData{
  static int counter=0;
}
class TheLocation{
  static double lat=0;
  static double lng=0; 
  static DateTime dtime= DateTime.now();
  static void set(double lat, double lng, DateTime dt){
    if (lat!=0 && lng!=0){
    TheLocation.lat=lat;
    TheLocation.lng=lng;
    TheLocation.dtime=dt;
    }
  }
}