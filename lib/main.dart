import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

import 'package:provider/provider.dart';
import 'src/helpers/helpers.dart';
import 'src/maps/map001.dart';
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

class MyStatefulWidgetState extends State<MyStatefulWidget> with WidgetsBindingObserver{
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
    WidgetsBinding.instance.addObserver(this); // lifecycle observer
    initGeoData();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // lifecycle observer
    locationSubscription.cancel();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // Lifecycle
    super.didChangeAppLifecycleState(state);
    logger.e("LifeCycle State: $state");
    if (state == AppLifecycleState.paused) {bg();} 
    else if (state == AppLifecycleState.resumed) {}
    else if (state == AppLifecycleState.inactive) { bg();}
  }
  Future<void> bg() async {
    if (GeoData.tripStarted) {
      await location.enableBackgroundMode(enable: true);
    } else {
      await location.enableBackgroundMode(enable: false);
    }
  }
  Future<void> initGeoData() async {
    try {
      locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
      if (await GeoData.chkPermissions(location)){
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
      
      GeoData.setLocation(currentLocation.latitude!, currentLocation.longitude!, DateTime.now());  
      setState(() {
        locationNotifierProvider.updateLoc1(currentLocation.latitude!,  currentLocation.longitude!, GeoData.currentDtime); 
      });
      if (GeoData.centerMap){locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom);}
      //if (GeoData.showLatLng){logger.i("(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");}
    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }
  void moveHere() async { // butten event
    try {
      var locationData = await GeoData.getCurrentLocation(location); 
      if (locationData != null) {
        locationNotifierProvider.updateLoc1(GeoData.currentLat, GeoData.currentLng, GeoData.currentDtime); 
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
                      locationSubscription.pause(); 
                      setState(() {lblLocationChanges="Resume Location Service";});
                    } else {
                      GeoData.listenChanges=true;
                      GeoData.centerMap=true;
                      GeoData.counter=1;
                      locationSubscription.resume(); 
                      setState(() {lblLocationChanges="Pause Location Service";});
                    }
                  } else if (value =="MOVE-HERE"){ moveHere(); 
                  } else if (value =="ASKMIN"){ _minDistance(context); 
                  } else if (value =="ASKMAX"){ _maxDistance(context); 
                  } else if (value =="ASKDIS"){ _getDistance(context); 
                  } else if (value =="ASKINT"){ _getInterval(context); 
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>( value: 'GPS-START-STOP',  child: Text(lblLocationChanges),),
                  const PopupMenuItem<String>( value: 'MOVE-HERE',  child: Text('Show current location'),),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>( value: 'ASKINT',  child: Text('Interval'),),
                  const PopupMenuItem<String>( value: 'ASKDIS',  child: Text('Distance'),),
                  const PopupMenuItem<String>( value: 'ASKMIN',  child: Text('Minimum Distance'),),
                  const PopupMenuItem<String>( value: 'ASKMAX',  child: Text('Maximum Distance'),),
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
        ],
      ),
    );
  }


  Future<void> _minDistance(BuildContext context) async {
    String? result =  await prompt(
              context,title: const Text('Minimum Distance?'),
              initialValue: GeoData.minDistance.toString(),
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) {setState(() {GeoData.minDistance = parsedResult;});}
    }
  }
  Future<void> _maxDistance(BuildContext context) async {
    String? result =  await prompt(
              context,title: const Text('Maximum Distance?'),
              initialValue: GeoData.maxDistance.toString(),
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) {setState(() {GeoData.maxDistance = parsedResult;});}
    }
  }
  Future<void> _getDistance(BuildContext context) async {
    String? result =  await prompt(
              context,title: const Text('Distance?'),
              initialValue: GeoData.distance.toString(),
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) {
        setState(() {
          GeoData.distance = parsedResult;
          location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
      });}
    }
  }
  Future<void> _getInterval(BuildContext context) async {
    String? result =  await prompt(
              context,title: const Text('Interval?'),
              initialValue: GeoData.interval.toString(),
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    if (result != null) {
      int? parsedResult = int.tryParse(result);
      if (parsedResult != null) {
        setState(() {
          GeoData.interval = parsedResult;
          location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        });
      }
    }
  }
}