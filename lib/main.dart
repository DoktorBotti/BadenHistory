import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

void main(){
  runApp(BadenHistory());
}

class BadenHistory extends StatelessWidget {
  const BadenHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen());
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    MapController controller = MapController(
    //   initMapWithUserPosition: false,
    //   initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    );
    return FlutterMap(
        mapController: controller,
        layers: [
          TileLayerOptions(
            minZoom: 1,
            maxZoom: 18,
            backgroundColor: Colors.black,
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ], options: MapOptions(
    )
    );
  }
}
