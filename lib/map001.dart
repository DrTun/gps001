import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gps001/circular_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'helpers.dart'; 
import 'geodata.dart';
//  -------------------------------------    Map001 (Property of Nirvasoft.com)
class Map001 extends StatefulWidget {
  const Map001({super.key});

  @override
  Map001State createState() => Map001State();
}

class Map001State extends State<Map001> {
  late LocationNotifier provider ;
  final List<Marker> markers = [];
  //late MapController mapctrl; 
  final  mapctrl = MapController();
  bool circling = false;
  
  @override
  void initState() {
    super.initState();
    setState(() {
    provider = Provider.of<LocationNotifier>(context,listen: false);
    });
  }
@override
Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (context, provider , child) {
      const double lat =51.509364; 
      const double lng =-0.128928;

      logger.i("BULD CONTEXT: ${provider.loc01.lat} x ${provider.loc01.lng}");
      return Scaffold(
          body: Stack(
            children: [ 
            FlutterMap(
              mapController: provider.mapController,
              options:   MapOptions(
                initialCenter: const LatLng(lat, lng), //london
                initialZoom: GeoData.zoom,
                onPositionChanged: (position, hasGesture) {GeoData.centerMap=false;},
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nirvasoft.gps001',
                ),
                MarkerLayer(rotate: true, markers: getmarkers(provider)),
              ],
            ),                  Positioned(
                  right: 10,
                  bottom: 80,
                  child: _refreshMap()),
            ],
          ),
        );
  });
}

  Widget _refreshMap() {
    return circling
        ? Container(
            decoration: const BoxDecoration(
                color: Colors.lightBlue, shape: BoxShape.circle),
            width: 40,
            height: 40,
            child: SpinKitFadingCircle(
              size: 30.0,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                );
              },
            ))
        : CircularButton(
            color: Colors.lightBlue,
            width: 40,
            height: 40,
            icon: const Icon(
              Icons.cached,
              color: Colors.white,
            ),
            onClick: () async {
              circling = true;
              setState(() {});
              Timer(const Duration(seconds: 5), () {
                setState(() {
                  circling = false;
                });
              });
            },
          );
  }

  List<Marker> getmarkers(LocationNotifier model) { 
      markers.clear();
      markers.add(Marker(
        point: LatLng(model.loc01.lat, model.loc01.lng),
        width: 25,
        height: 25,
        alignment: Alignment.center,
        child: Image.asset('assets/images/circle_green.png',scale: 1.0,),
      ));
    return markers;
  }

}