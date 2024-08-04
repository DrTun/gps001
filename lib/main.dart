import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'helpers.dart';
import 'map001.dart';
import 'geodata.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

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
    // GPS Init >>>> 
    locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
    GeoData.chkPermissions(location).then((permits) => () {
      if (permits==false) {logger.i("Permission Denied");}
      else {   
        location.enableBackgroundMode(enable: true);
      }
    });
    location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {repeat(currentLocation);});
    if (GeoData.listenChanges==false) locationSubscription.pause();
    // GPS Init -------------------
  }
  void repeat(LocationData currentLocation){
      GeoData.counter++;
      var lat= currentLocation.latitude;
      var lng= currentLocation.longitude; 
      GeoData.setLocation(currentLocation.latitude!, currentLocation.longitude!, DateTime.now());
      locationNotifierProvider.updateLoc1(GeoData.lat, GeoData.lng, GeoData.dtime); 
      if (GeoData.centerMap){locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom);}
      if (GeoData.showLatLng){MyHelpers.showIt("$lat x $lng ",label: "(${GeoData.counter}) ",sec: 2); }
  }
  void moveHere() async {
      var locationData = await GeoData.getCurrentLocation(location); 
      if (locationData != null) {
        locationNotifierProvider.updateLoc1(GeoData.lat, GeoData.lng, GeoData.dtime); 
        locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
        if (GeoData.showLatLng){ MyHelpers.showIt("$locationData.latitude x $locationData.longitude",label: "Current Location",sec: 5);}
      } else { logger.i("Permission Denied"); }    
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
                  }else if (value =="SHOWLL"){ 
                    if(GeoData.showLatLng) {
                      GeoData.showLatLng=false;
                      setState(() {lblShowLatLng="Show Lat & Lng";});
                    } else {
                      GeoData.showLatLng=true;
                      setState(() {lblShowLatLng="Hide Lat & Lng";});
                    } 
                  } else if (value =="CURRENT"){ moveHere(); 
                  } 
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>( value: 'START',  child: Text(lblLocationChanges),),
                  PopupMenuItem<String>( value: 'SHOWLL',  child: Text(lblShowLatLng),),
                  const PopupMenuDivider(),
                    const PopupMenuItem<String>( value: 'CURRENT',  child: Text('Show current location'),),
                ],
              ),
            ],
      ),
      body: Column(
        children: [
          const Text(""),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Map001()),  
        ],
      ),
    );
  }
}