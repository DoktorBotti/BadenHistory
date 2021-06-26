import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_ws/DetailScreen.dart';
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
  @override
  Widget build(BuildContext context) {
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
                Tab(
                  text: 'Quests',
                  icon: Icon(Icons.access_time),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FindingsScreen(),
              MapContainer(),
              DetailScreen(
                imagePath: "assets/testimage.jpg",
              ),
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
        ));
  }
}

class MapContainer extends StatefulWidget {
  MapContainer({Key? key}) : super(key: key);

  @override
  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  @override
  void initState() {
    var fc = FetchContent();
    Future<Record> r1 = fc.fetchRecord(1);
    r1.then((value) => value.printDebug1());
    _ourMarkers = objectsNearby
        .map((point) => Marker(
            point: point,
            width: 60,
            height: 60,
            builder: (context) =>
                Icon(Icons.pin_drop, size: 60, color: Colors.blueAccent)))
        .toList();
    super.initState();
  }

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
  PopupController _popupController = PopupController();
  MapController _mapController = MapController();
  List<Marker> _ourMarkers = [];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      nonRotatedLayers: [],
      options: MapOptions(
          center: LatLng(49.01358967154513, 8.404437624549605),
          plugins: [MarkerClusterPlugin(), LocationPlugin()],
          onTap: (_) => _popupController.hidePopup(),
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      layers: [
        TileLayerOptions(
          minZoom: 7,
          maxZoom: 25,
          backgroundColor: Colors.black,
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        LocationOptions(locationButton(), onLocationUpdate: (LatLngData? ld) {
          print("${ld?.location}");
        }, onLocationRequested: (LatLngData? ld) {
          if (ld == null) {
            return;
          }
          _mapController.move(ld.location, 16.0);
        }),
        MarkerClusterLayerOptions(
            markers: _ourMarkers,
            maxClusterRadius: 190,
            disableClusteringAtZoom: 16,
            size: Size(50, 50),
            fitBoundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50)),
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
                          color: Colors.black, shape: BoxShape.rectangle),
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
    );
  }
}

class FetchContent {

  double latitude_min = 48.99;
  double latitude_max = 49.036;
  double longitude_min = 8.33;
  double longitude_max = 8.47;

  Future<Image> getImageByID(final int id) async {
    //TODO: get image from backend
    return Image.asset("assets/testimage.jpg");
  }

  Future<Record> fetchRecord(final int id) async {
    final response = await http.get(Uri.parse(
        'http://192.168.178.37:5000/api/elements/?id=' + id.toString()));
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

class FindingsScreen extends StatefulWidget {
  const FindingsScreen({Key? key}) : super(key: key);

  @override
  _FindingsScreenState createState() => _FindingsScreenState();
}

class _FindingsScreenState extends State<FindingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<RecordViewData>>(future: getVisitedRecords(),
      builder: (context, rec) {
        if(rec.hasData){
          return ListView.builder(
              itemCount: rec.data!.length,
              itemBuilder: (context, i){
                return Card(
                  child: Container(
                    child: Text(rec.data![i].baseRecord.text),
                  ),
                );
              });
        }
        else
          {
            return Card(
              child: Container(
                child: Text("no data"),
              ),
            );
          }
      },)
    );
  }
}

class RecordViewData {
  RecordViewData(this.baseRecord, this.recordImg);

  Record baseRecord;
  Image recordImg;
}

Future<List<RecordViewData>> getVisitedRecords() async {
  var fc = FetchContent();
  var record = await fc.fetchRecord(1);
  var image = await fc.getImageByID(record.id);
  return [RecordViewData(record, image)];
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

  const Record(
      {required this.id, required this.x, required this.y, required this.image, required this.text, required this.voice, required this.type, required this.username});

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
    print(id.toString() + x.toString() + " " + y.toString() +
        (image?.toString() ?? "") + text + (voice?.toString() ?? "") + type +
        (username?.toString() ?? ""));
  }
}
LocationButtonBuilder locationButton() {
  return (BuildContext context, ValueNotifier<LocationServiceStatus> status,
      Function onPressed) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
            child: ValueListenableBuilder<LocationServiceStatus>(
                valueListenable: status,
                builder: (BuildContext context, LocationServiceStatus value,
                    Widget? child) {
                  switch (value) {
                    case LocationServiceStatus.disabled:
                    case LocationServiceStatus.permissionDenied:
                    case LocationServiceStatus.unsubscribed:
                      return const Icon(
                        Icons.location_disabled,
                        color: Colors.white,
                      );
                    default:
                      return const Icon(
                        Icons.location_searching,
                        color: Colors.white,
                      );
                  }
                }),
            onPressed: () => onPressed()),
      ),
    );
  };
}
