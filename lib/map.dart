import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:gps001/helpers.dart';
import 'package:gps001/main.dart'; 
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
  final List<Marker> markers = [];
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
      const double lat =51.509364; 
      const double lng =-0.128928;

      logger.i("BULD CONTEXT: ${provider.loc01.lat} x ${provider.loc01.lng}");
      return Scaffold(
          body: Stack(
            children: [
                    
            FlutterMap(
              //initialCenter: LatLng(provider.loc01.lat, provider.loc01.lon),
              //initialCenter: LatLng(51.509364, -0.128928),
              mapController: provider.mapController,
              options:   MapOptions(
                initialCenter: const LatLng(lat, lng), //london
                initialZoom: TheLocation.zoom,
                onPositionChanged: (position, hasGesture) {
                    TheLocation.centerMap=false;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nirvasoft.gps001',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      ' ${provider.loc01.lat} ${provider.loc01.lng}',
                      onTap: () => launchUrl(Uri.parse('https://www.nirvasoft.com')),
                    ),
                  ],
                ),
                MarkerLayer(rotate: true, markers: getmarkers(provider)),
              ],
            ),
            ],
          ),
        );
  });
}
  List<Marker> getmarkers(MyNotifier model) {
    //point: LatLng(TheLocation.lat, TheLocation.lng),
    //point: LatLng(model.loc01.lat, model.loc01.lng),
      markers.clear();
      markers.add(Marker(
        point: LatLng(model.loc01.lat, model.loc01.lng),
        width: 25,
        height: 25,
        alignment: Alignment.center,
        child: Image.asset('assets/images/circle_green.png',
          scale: 1.0,
        ),
      ));
    return markers;
  }

}