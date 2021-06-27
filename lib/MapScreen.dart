import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:unique_list/unique_list.dart';

import 'RecordsAndFetcher.dart';

class MapContainer extends StatefulWidget {
  MapContainer({Key? key}) : super(key: key);

  @override
  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {

  @override
  void initState() {
    objectsNearby.clear();
    var fc = FetchContent();
    fc.syncData().then((value) {
      for(final collectible in fc.collectibles) {
        objectsNearby.add(LatLng(collectible.baseRecord.x!, collectible.baseRecord.y!));
        print(collectible.baseRecord.x.toString() + collectible.baseRecord.y.toString());
      }
      print(objectsNearby);
      var markers = UniqueList<Marker>();
          markers.addAll(objectsNearby
          .map((point) => Marker(
          point: point,
          width: 60,
          height: 60,
          builder: (context) =>
              Icon(Icons.flag_rounded, size: 60, color: Colors.blueAccent)))
          .toList());
        setState(() {
          _ourMarkers = markers;
        });
    });
    // Future<Record> r1 = fc.fetchRecord(1);
    // r1.then((value) => value.printDebug1());
    super.initState();
  }

  List<LatLng> objectsNearby = [
  ];
  PopupController _popupController = PopupController();
  MapController _mapController = MapController();
  List<Marker> _ourMarkers = [
    QuestionMarker(
        questionData: Question(
            id: 1337,
            questionTitle: "why tho?",
            latitude: 49.27305446340209,
            longitude: 9.17189737808250))
  ];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      nonRotatedLayers: [],
      options: MapOptions(
          center: LatLng(49.01358967154513, 8.404437624549605),
          plugins: [MarkerClusterPlugin(), LocationPlugin()],
          onTap: (handle) => {
                _popupController.hidePopup()
                // TODO: potentially more cleanup logic here
              },
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

class QuestionMarker extends Marker {
  QuestionMarker({required this.questionData})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.top),
            height: 60,
            width: 60,
            point: LatLng(questionData.latitude, questionData.longitude),
            builder: (BuildContext ctx) => Icon(Icons.ac_unit));

  final Question questionData;
}
