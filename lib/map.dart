import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:gps001/helpers.dart';
import 'package:gps001/mynotifier.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 

//class MyMap extends StatelessWidget {
//  const MyMap({super.key});

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  MyMapState createState() => MyMapState();
}

class MyMapState extends State<MyMap> {
  late MyNotifier provider ;
  //late MapController mapctrl; 
  final  mapctrl = MapController();

  @override
  void initState() {
    super.initState();
    setState(() {
    provider = Provider.of<MyNotifier>(context,listen: false);
    });
  }
@override
Widget build(BuildContext context) {
    return Consumer<MyNotifier>(
      builder: (context, provider , child) {
      //mapctrl.move(LatLng(provider.loc01.lat, provider.loc01.lng),13);

      logger.i("BULD CONTEXT: ${provider.loc01.lat} x ${provider.loc01.lng}");
      return Scaffold(
          body: Stack(
            children: [
                    
            FlutterMap(
              //initialCenter: LatLng(provider.loc01.lat, provider.loc01.lon),
              //initialCenter: LatLng(51.509364, -0.128928),
              mapController: provider.mapController,
              options:  const MapOptions(
                initialCenter: LatLng(16.87142019486324, 96.12368485665527),
                initialZoom: 13,
              ),
              children: [
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(provider.loc01.lat, provider.loc01.lng),
                      width: 80,
                      height: 80,
                      child: const FlutterLogo(),
                    ),
                  ],
                ),
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '${provider.loc01.lat} ${provider.loc01.lng}',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
                
              ],
              
            ),
            ],
          ),
        );
  });
}
}