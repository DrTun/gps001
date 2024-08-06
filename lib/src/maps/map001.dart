import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:gps001/src/widgets/recenter.dart';
import 'package:gps001/src/widgets/refreshcircle.dart'; 
import 'package:gps001/src/widgets/switchon.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/geodata.dart';
//  -------------------------------------    Map001 (Property of Nirvasoft.com)
class Map001 extends StatefulWidget {
  const Map001({super.key});

  @override
  Map001State createState() => Map001State();
}
class Map001State extends State<Map001> {
  late LocationNotifier locationNotifierProvider ;
  final List<Marker> markers = [];
  //late MapController mapctrl; 
  final  mapctrl = MapController();
  bool refreshing = false; 
  bool switchon = false;
  final ValueNotifier<bool> isStartValue = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    setState(() {
    locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
    });
  }
@override
Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (context, provider , child) {
      const double lat =GeoData.defaultLat; 
      const double lng =GeoData.defaultLng;
      return Scaffold(
          body: Stack(
            children: [ 
            FlutterMap(
              mapController: provider.mapController,
              options:   MapOptions(
                initialCenter: const LatLng(lat, lng), //london
                initialZoom: GeoData.zoom,
                onPositionChanged: (position, hasGesture) {
                  GeoData.zoom=position.zoom;
                  if (hasGesture) {
                    setState(() {GeoData.centerMap=false;});
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(rotate: true, markers: addMarkers(provider)),  // add markers
              ],
            ),
            Positioned( // refresh button
                  right: 10,
                  top: 0,
                  child: switchOn()),
            Positioned( // refresh button
                  right: 10,
                  bottom: 50,
                  child: refreshCircle()),
            Positioned( //  recentre button
                  left: 10,
                  bottom: 50,
                  child: reCenter()),
            Positioned( //  recentre button
                  left: 10,
                  bottom: 10,
                  child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?locationNotifierProvider.loc01.lat:''} ${GeoData.showLatLng?locationNotifierProvider.loc01.lat:''} ", style: const TextStyle(fontSize: 14))
                   
                  ),
            ],
          ),
        );
  });
}

  List<Marker> addMarkers(LocationNotifier model) { 
      markers.clear();
      markers.add(Marker(
        point: LatLng(model.loc01.lat, model.loc01.lng), width: 100,height: 100,alignment: Alignment.center,
        child: Image.asset('assets/images/here.png',scale: 1.0,),
      ));
    return markers;
  }
  Widget reCenter() {
    return 
      ReCenter(
          value: GeoData.centerMap,  
          onClick: ()  {
            setState(() {
                GeoData.centerMap=true;
            });
            locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
          },
      );
  }
  Widget refreshCircle() {
    return refreshing // cheeck if on or off
        ? RefreshCircle(value: true, onClick: () async {},)
        : RefreshCircle(value: false,
            onClick: () async {
              setState(() { refreshing = true;}); // start refreshing
              Timer(const Duration(seconds: 1), () {
                setState(() { refreshing = false;}); // done refreshing
                if (GeoData.showLatLng) {GeoData.showLatLng=false; } else {GeoData.showLatLng=true;}
                }
              );
            },
          );
  }
  Widget switchOn() {
    return switchon // cheeck if on or off
        ? SwitchOn(value: true, label: "End",
            onClick: () async {
              setState(() {switchon = false;  });
            },
          )
        : SwitchOn(value: false, label: "Start",
            onClick: () async {
              setState(() {switchon = true;});
            },
          );
  }
}