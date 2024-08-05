import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';

import 'package:provider/provider.dart';
import 'src/helpers/helpers.dart';
import 'map001.dart';
import 'src/providers/geodata.dart';

void main() async{
  runApp(
          MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationNotifier()) // Provider
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
  late LocationNotifier locationNotifierProvider ;  // Provider Declaration and init
  String lblLocationChanges=GeoData.listenChanges?"Pause Location Service":"Resume Location Service";
  String lblShowLatLng=GeoData.showLatLng?"Hide Lat & Lng":"Show Lat & Lng On";
  
  // GPS Declare >>>>
  final Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  // GPS Declare -------------------
  @override
  void initState() {
    super.initState();    
    initGeoData();
  }
  Future<void> initGeoData() async {
    try {
      locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
      if (await GeoData.chkPermissions(location)){
        //await location.enableBackgroundMode(enable: true);
        await location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {changeLocations(currentLocation);});
        if (GeoData.listenChanges==false) locationSubscription.pause();
      } else {   logger.i("Permission Denied");} 
    } catch (e) {
      logger.i("Exception (initGeoData): $e");
    }
  }
  void changeLocations(LocationData currentLocation){ //listen to location changes
    try {
      GeoData.counter++;
      GeoData.setLocation(currentLocation.latitude!, currentLocation.longitude!, DateTime.now());
      setState(() {
        locationNotifierProvider.updateLoc1(GeoData.lat, GeoData.lng, GeoData.dtime); 
      });
      if (GeoData.centerMap){locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom);}
      if (GeoData.showLatLng){logger.i("(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");}
    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }
  void moveHere() async { // butten event
    try {
      var locationData = await GeoData.getCurrentLocation(location); 
      if (locationData != null) {
        locationNotifierProvider.updateLoc1(GeoData.lat, GeoData.lng, GeoData.dtime); 
        locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
        MyHelpers.showIt("\n${locationNotifierProvider.loc01.lat}\n${locationNotifierProvider.loc01.lng}",label: "You are here",sec: 4,bcolor: Colors.orange);
      } else { logger.i("Invalid Location!"); }    
    } catch (e) {
      logger.i("Exception (moveHere): $e");
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
                  if (value == 'GPS-START-STOP') {
                    if(GeoData.listenChanges) {
                      GeoData.listenChanges=false;
                      GeoData.counter=0;
                      locationSubscription.resume(); 
                      setState(() {lblLocationChanges="Pause Location Service";});
                    } else {
                      GeoData.listenChanges=true;
                      GeoData.centerMap=true;
                      GeoData.counter=0;
                      locationSubscription.pause(); 
                      setState(() {lblLocationChanges="Resume Location Service";});
                    }
                  } else if (value =="MOVE-HERE"){ moveHere(); } 
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>( value: 'GPS-START-STOP',  child: Text(lblLocationChanges),),
                    const PopupMenuItem<String>( value: 'MOVE-HERE',  child: Text('Show current location'),),
                ],
              ),
            ],
      ),
      body: Column(
        children: [
          const SizedBox(height: (3),),  
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height - 200),
            child: const Map001(),
          ),  
          Text("(${GeoData.counter}) ${locationNotifierProvider.loc01.lat} ${locationNotifierProvider.loc01.lat} ", textAlign: TextAlign.left)
        ],
      ),
    );
  }
}