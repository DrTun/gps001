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
              options:  const MapOptions(
                initialCenter: LatLng(lat, lng), //london
                initialZoom: 13,
              ),
              children: [
                MarkerLayer(rotate: true, markers: getmarkers(provider)),
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
                
              ],
              
            ),
            ],
          ),
        );
  });
}
  List<Marker> getmarkers(MyNotifier model) {
    markers.clear();
      markers.add(Marker(
        point: LatLng(model.loc01.lat, model.loc01.lng),
        width: 40,
        height: 64,
        alignment: Alignment.center,
        child: Image.asset('assets/images/circle_green.png',
          scale: .3,
        ),
      ));

    //try {
    //   markers.clear();
    //   markers.add(Marker(
    //     point: model.locationPosition!,
    //     width: 40,
    //     height: 64,
    //     alignment: Alignment.center,
    //     child: Image.asset(
    //       model.isOnlineAvailable
    //           ? 'assets/images/circle_green.png'
    //           : 'assets/images/circle_grey.png',
    //       scale: .3,
    //     ),
    //   ));
    //   if (myWidget.destinationController.text != "") {
    //     previousDestinationMarker = Marker(
    //         width: 200.0,
    //         height: 60.0,
    //         point: LatLng(double.parse(myWidget.destinationLat),
    //             double.parse(myWidget.destinationLng)),
    //         child: Column(children: [
    //           Container(
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(5.0),
    //             ),
    //             child: const Padding(
    //               padding: EdgeInsets.all(5.0),
    //               child: Text(
    //                 'To (သို့)',
    //                 style: TextStyle(fontSize: 12.0),
    //               ),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 2,
    //           ),
    //           Image.asset(
    //             'assets/images/to.png',
    //             scale: .3,
    //             width: 25.0,
    //             height: 25.0,
    //           )
    //         ]));
    //     markers.add(previousDestinationMarker!);
    //   } else if (previousDestinationMarker != null &&
    //       markers.contains(previousDestinationMarker)) {
    //     markers.remove(previousDestinationMarker);
    //   } else if (previousDestinationMarker != null &&
    //       markers.contains(previousDestinationMarker) &&
    //       myWidget.destinationController.text == "") {
    //     markers.remove(previousDestinationMarker);
    //   }
    // } catch (error) {}

    return markers;
  }

}