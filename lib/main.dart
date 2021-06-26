import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' as local;


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
  void initState() {
    var fc = new FetchContent();
    Future<Record> r1 = fc.fetchRecord(1);
    r1.then((value) => value.printDebug1());
    ourMarkers = objectsNearby
        .map((point) => Marker(
            point: point,
            width: 60,
            height: 60,
            builder: (context) =>
                Icon(Icons.pin_drop, size: 60, color: Colors.blueAccent)))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PopupController _popupController = PopupController();
    MapController _mapController = MapController();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Baden History'),
            bottom: TabBar(
              indicatorColor: Colors.white,
              isScrollable: false,
              tabs: [
                Tab(
                  text: 'My Findings',
                  icon: Icon(Icons.favorite),
                ),
                Tab(text: 'Map', icon: Icon(Icons.map_rounded)),
                Tab(text: 'Quests', icon: Icon(Icons.access_time),)
              ],
            ),
          ),
          body: FlutterMap(
              mapController: _mapController,
              layers: [
                TileLayerOptions(
                  minZoom: 7,
                  maxZoom: 25,
                  backgroundColor: Colors.black,
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerClusterLayerOptions(
                    markers: ourMarkers,
                    maxClusterRadius: 190,
                    disableClusteringAtZoom: 16,
                    size: Size(50, 50),
                    fitBoundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(50)),
                    polygonOptions: PolygonOptions(
                        borderColor: Colors.blueAccent,
                        color: Colors.black12,
                        borderStrokeWidth: 3),
                    popupOptions: PopupOptions(
                        popupSnap: PopupSnap.markerTop,
                        popupController: _popupController,
                        popupBuilder: (_, marker) => Container(
                              alignment: Alignment.center,
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.rectangle),
                              child: Text(
                                'Go near this object to find out more',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                    builder: (context, markers) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.orange, shape: BoxShape.circle),
                          child: Text('${markers.length}'));
                    })
              ],
              options: MapOptions(
                  center: LatLng(49.01358967154513, 8.404437624549605),
                  plugins: [MarkerClusterPlugin()],
                  onTap: (_) => _popupController.hidePopup()))),
      initialIndex: 1,
    );
  }
}

class FetchContent {

  double latitude_min = 48.99;
  double latitude_max = 49.036;
  double longitude_min = 8.33;
  double longitude_max = 8.47;

  Future<Record> fetchRecord(final int id) async{
    final response = await http.get(Uri.parse('http://192.168.178.37:5000/api/elements/?id='+id.toString()));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Record.fromJson(jsonDecode(response.body)[0]);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load record');
    }
  }
}

class Record {
  final int id;
  final double x;
  final double y;
  final String? image;
  final String text;
  final String? voice;
  final String type;
  final String? username;

  const Record({required this.id, required this.x, required this.y, required this.image, required this.text, required this.voice, required this.type, required this.username});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      x: json['x'],
      y: json['y'],
      image: json['image'],
      text: json['text'],
      voice: json['voice'],
      type: json['type'],
      username: json['username']
    );
  }
  void printDebug1() {
    print(id.toString() + x.toString() + " " + y.toString() + (image?.toString() ?? "") + text + (voice?.toString() ?? "") + type + (username?.toString() ?? "") );
  }
}
