import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; 

//class MyMap extends StatelessWidget {
//  const MyMap({super.key});

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  MyMapState createState() => MyMapState();
}

class MyMapState extends State<MyMap> {
  late MapController mapController;
  //LocationModel? currentLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
      body: Stack(
        children: [
          
FlutterMap(
    options: const MapOptions(
      initialCenter: LatLng(51.509364, -0.128928),
      initialZoom: 9.2,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.app',
      ),
      RichAttributionWidget(
        attributions: [
          TextSourceAttribution(
            'OpenStreetMap contributors',
            onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
          ),
        ],
      ),
      
    ],
    
  ),



        ],
      ),
    );
}
}