import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gps001/src/widgets/circular_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'src/providers/geodata.dart';
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
                MarkerLayer(rotate: true, markers: _markers(provider)),  // add markers
              ],
            ),
            Positioned( // refresh button
                  right: 10,
                  bottom: 50,
                  child: _refreshMap()),
            Positioned( //  recentre button
                  left: 10,
                  bottom: 50,
                  child: _recenter()),
            ],
          ),
        );
  });
}
Widget _refreshMap() {
    return refreshing // cheeck if the map is refreshing
        ? Container( // show rotating circle
            decoration: const BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
            width: 40, height: 40,
            child: SpinKitFadingCircle(
              size: 30.0,
              itemBuilder: (BuildContext context, int index) {  
                return DecoratedBox( decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),);
                },
              )
            )
        : CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.lightBlue,
            width: 40, height: 40,
            icon: const Icon( Icons.cached, color: Colors.white,),
            onClick: () async {
              setState(() {refreshing = true;});
              Timer(const Duration(seconds: 1), () {
                setState(() { refreshing = false;}); // set refreshing dones
                }
              );
            },
          );
  }
  Widget _recenter() {
    return
          GeoData.centerMap // check if the map is centered; i centered no icon
          ? const Text("Centered",style: TextStyle(color: Colors.blueGrey),)
          : CircularButton(
            color: Colors.lightBlue,
            width: 40,
            height: 40,
            icon: const Icon(
              Icons.center_focus_weak_rounded,
              color: Colors.white,
            ),
            onClick: ()  {
              setState(() {
                  GeoData.centerMap=true;
              });
              locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
            },
          );
  }
  List<Marker> _markers(LocationNotifier model) { 
      markers.clear();
      markers.add(Marker(
        point: LatLng(model.loc01.lat, model.loc01.lng),
        width: 100,
        height: 100,
        alignment: Alignment.center,
        child: Image.asset('assets/images/here.png',scale: 1.0,),
      ));
    return markers;
  }

}