import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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
  void initState() {
    ourMarkers = objectsNearby
        .map((point) =>
        Marker(
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


    return Scaffold(
        appBar: AppBar(title: Text('Baden History'),),
        body: FlutterMap(
            mapController: _mapController,
            layers: [
              TileLayerOptions(
                minZoom: 7,
                maxZoom: 25,
                backgroundColor: Colors.black,
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerClusterLayerOptions(
                  markers: ourMarkers,
                  maxClusterRadius: 190,
                  disableClusteringAtZoom: 16,
                  size: Size(50, 50),
                  fitBoundsOptions: FitBoundsOptions(
                      padding: EdgeInsets.all(50)),
                  polygonOptions: PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  popupOptions: PopupOptions(
                      popupSnap: PopupSnap.markerTop,
                      popupController: _popupController,
                      popupBuilder: (_, marker) =>
                          Container(
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
            options: MapOptions(
                center: LatLng(49.01358967154513, 8.404437624549605),
                plugins: [MarkerClusterPlugin()],
                onTap: (_) =>
                    _popupController
                        .
                    hidePopup
                      (
                    )
            )
        )
    );
  }
}