import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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
  String lblCenterMap="";
  String lblShowLatLng="";
  String lblTracking="";
  
  // GPS Declare >>>>
  final Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  // GPS Declare -------------------
  @override
  void initState() {
    super.initState(); 
    
    if (TheLocation.centerMap){
      lblCenterMap="Center Map ON";;
    } else{
      lblCenterMap="Center Map OFF";;
    }    
    if (TheLocation.showLatLng){
      lblShowLatLng="Lat & Lng ON";;
    } else{
      lblShowLatLng="Lat & Lng OFF";
    }    
    if (TheLocation.tracking){
      lblTracking="Tracking ON";;
    } else{
      lblTracking="Traking OFF";
    } 
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
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 10000);
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      GlobalData.counter++;
      var lat= currentLocation.latitude;
      var lng= currentLocation.longitude; 
      TheLocation.set(currentLocation.latitude!, currentLocation.longitude!, DateTime.now());
      provider.updateLoc1(TheLocation.lat, TheLocation.lng, TheLocation.dtime);
      provider.updateData01("$lat","$lat");
      if (TheLocation.centerMap){
        provider.mapController.move(LatLng(provider.loc01.lat, provider.loc01.lng),TheLocation.zoom); // Provider Update
      }
      if (TheLocation.showLatLng){
        MyHelpers.showIt("$lat x $lng ",label: "(${GlobalData.counter}) ",sec: 2); 
      }
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
void moveHere(controller) async {
    var locationData = await getCurrentLocation(location); 
    if (locationData != null) {
      var lng= locationData.longitude;
      var lat= locationData.latitude;
      provider.updateLoc1(TheLocation.lat, TheLocation.lng, TheLocation.dtime);
      provider.updateData01("$lat","$lat");
      if (TheLocation.centerMap){
      controller.move(LatLng(provider.loc01.lat, provider.loc01.lng),13.0); 
      }      
      if (TheLocation.showLatLng){
          MyHelpers.showIt("$lat x $lng",label: "Current Location",sec: 5);

      }
    } else {
    logger.i("Permission Denied");
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
                  if (value == 'START') {
                    if(TheLocation.tracking) {
                      TheLocation.tracking=false;
                      GlobalData.counter=0;
                      locationSubscription.resume(); 
                      setState(() {lblTracking="Tracking ON";});
                    } else {
                      TheLocation.tracking=true;
                      GlobalData.counter=0;
                      locationSubscription.pause(); 
                      setState(() {lblTracking="Tracking OFF";});
                    }
                  } else if (value =="CURRENT"){ moveHere(provider.mapController); 
                  } else if (value =="CENTERMAP"){ 
                      if (TheLocation.centerMap){
                        TheLocation.centerMap=false;
                        setState(() {lblCenterMap="Center Map OFF";});
                      } else{
                        TheLocation.centerMap=true;
                        setState(() {lblCenterMap="Center Map ON";});
                      }
                  }else if (value =="SHOWLL"){ 
                    if(TheLocation.showLatLng) {
                      TheLocation.showLatLng=false;
                      setState(() {lblShowLatLng="Lat & Lng OFF";});
                    } else {
                      TheLocation.showLatLng=true;
                      setState(() {lblShowLatLng="Lat & Lng ON";});
                    } 
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>( value: 'CENTERMAP', child: Text(lblCenterMap),  ),
                  PopupMenuItem<String>( value: 'SHOWLL',  child: Text(lblShowLatLng),  ),
                  PopupMenuItem<String>( value: 'START',  child: Text(lblTracking),  ),
                  const PopupMenuItem<String>( value: 'CURRENT',  child: Text('My Location'), ),
                ],
              ),
            ],
      ),
      body: Column(
        children: [
          const Text(" "),
          ElevatedButton(
          onPressed: () async { moveHere(provider.mapController);
          // await provider.mapController.
          
          // addMarker(marker,
          // markerIcon: const MarkerIcon(
          //   icon: Icon(
          //     Icons.location_pin,
          //     color: Colors.blue,
          //     size: 48,
          //   ),
          // ));
          },
          child: const Text('Current Location'),
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
  static bool showLatLng=true;
  static bool centerMap=true;
  static bool tracking=true;
  static double zoom=13;
  static DateTime dtime= DateTime.now();
  static void set(double lat, double lng, DateTime dt){
    if (lat!=0 && lng!=0){
    TheLocation.lat=lat;
    TheLocation.lng=lng;
    TheLocation.dtime=dt;
    }
  }
}