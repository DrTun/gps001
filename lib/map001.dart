import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
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