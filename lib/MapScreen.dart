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
    var newMarkers = UniqueList<Marker>();
    var fc = FetchContent();
    fc.syncData().then((value) {
      for (final collectible in fc.collectibles) {
        bool alreadyFound = fc.isFound(collectible.baseRecord.id);
        if(collectible.baseRecord.longitude == null || collectible.baseRecord.latitude == null){
          continue;
        }
        if (collectible.baseRecord.type == "collectable") {
          newMarkers.add(RecordMarker(
              longitude: collectible.baseRecord.x!,
              latitude: collectible.baseRecord.y!,
              isFound: alreadyFound));
        } else if (collectible.baseRecord.type == "question") {
          var questionD = Question(
              id: collectible.baseRecord.id,
              questionTitle: collectible.baseRecord.title!,
              longitude: collectible.baseRecord.x!,
              latitude: collectible.baseRecord.y!);
          newMarkers.add(
              QuestionMarker(questionData: questionD, isFound: alreadyFound));
        }
        // then it must be comment or audio. Ignoring.

        print(collectible.baseRecord.x.toString() +
            collectible.baseRecord.y.toString());
      }
      setState(() {
        _ourMarkers = newMarkers;
      });
      if (_ourMarkers.isNotEmpty) {
        print(_ourMarkers.last);
      }
    });
    // Future<Record> r1 = fc.fetchRecord(1);
    // r1.then((value) => value.printDebug1());
    super.initState();
  }

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
          var fc = FetchContent();
          fc.setLocation(ld!.location);
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
                popupBuilder: (_, marker) {
                  if (marker is QuestionMarker) {
                    return Container(
                      alignment: Alignment.center,
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.black, shape: BoxShape.rectangle),
                      child: Text(
                        'I\'m a question!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (marker is RecordMarker) {
                    return Container(
                      alignment: Alignment.center,
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.black, shape: BoxShape.rectangle),
                      child: Text(
                        'I am an report!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Container(
                    alignment: Alignment.center,
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        color: Colors.black, shape: BoxShape.rectangle),
                    child: Text(
                      'AAAAAAHHHHHH',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
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

class RecordMarker extends Marker {
  RecordMarker(
      {required this.longitude, required this.latitude, required this.isFound})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 60,
            width: 60,
            point: LatLng(latitude, longitude),
            builder: (BuildContext ctx) =>
                Icon(Icons.flag_rounded, color: Colors.blueAccent));

  final double longitude;
  final double latitude;
  final bool isFound;
}

class QuestionMarker extends Marker {
  QuestionMarker({required this.questionData, required this.isFound})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 60,
            width: 60,
            point: LatLng(questionData.latitude, questionData.longitude),
            builder: (BuildContext ctx) => Icon(Icons.ac_unit));

  final Question questionData;
  final bool isFound;
}
