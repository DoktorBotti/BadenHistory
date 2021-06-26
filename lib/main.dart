import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(BadenHistory());
}

class BadenHistory extends StatelessWidget {
  const BadenHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LatLng> objectsNearby = [
    LatLng(49.01358967154513, 8.404437624549605),
    LatLng(50.03111935248694, 9.50641335880519),
    LatLng(50.59453579029447, 9.09409549394147),
    LatLng(49.05782579488481, 9.99637829327629),
    LatLng(49.27305446340209, 9.17189737808250),
    LatLng(48.28978577551132, 8.11155515664592),
    LatLng(50.83918481074443, 8.59033195643448),
    LatLng(48.93699220770547, 8.91040842128563),
    LatLng(50.05733722085694, 7.35620412422381)
  ];
  List<Marker> ourMarkers = [];

  @override
  Widget build(BuildContext context) {
    MapController controller = MapController();
    ourMarkers = objectsNearby
        .map((point) =>
        Marker(
            point: point,
            width: 60,
            height: 60,
            builder: (context) =>
                Icon(Icons.pin_drop, size: 60, color: Colors.blueAccent)))
        .toList();
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
          MarkerLayerOptions(markers:ourMarkers)
        ],
        options:
        MapOptions(center: LatLng(49.01358967154513, 8.404437624549605)));
  }
}
