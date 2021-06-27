import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:unique_list/unique_list.dart';

import 'DetailScreen.dart';
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
        if (collectible.baseRecord.longitude == null ||
            collectible.baseRecord.latitude == null) {
          continue;
        }
        if (collectible.baseRecord.type == "collectable") {
          newMarkers.add(RecordMarker(
              longitude: collectible.baseRecord.y!,
              latitude: collectible.baseRecord.x!,
              isFound: alreadyFound,
              id: collectible.baseRecord.id));
        } else if (collectible.baseRecord.type == "question") {
          var questionD = Question(
              id: collectible.baseRecord.id,
              questionTitle: collectible.baseRecord.title!,
              longitude: collectible.baseRecord.y!,
              latitude: collectible.baseRecord.x!);
          newMarkers.add(QuestionMarker(
              questionData: questionD,
              isFound: alreadyFound,
              id: collectible.baseRecord.id));
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
                  var buldFc = FetchContent();
                  return GestureDetector(
                      onTap: () {
                        print("Tapped flag!");
                        var fc = FetchContent();
                        if (marker is RecordMarker) {
                          fc.addFound(marker.id);
                          var newMarkers = _ourMarkers;
                          newMarkers.remove(marker);
                          var foundM = RecordMarker(
                            longitude: marker.longitude,
                            latitude: marker.latitude,
                            isFound: true,
                            id: marker.id,
                          );
                          newMarkers.add(foundM);
                          setState(() {
                            _ourMarkers = newMarkers;
                          });
                        }
                        if (marker is QuestionMarker) {
                          fc.addFound(marker.id);
                          var newMarkers = _ourMarkers;
                          newMarkers.remove(marker);
                          var foundM = RecordMarker(
                            longitude: marker.questionData.longitude,
                            latitude: marker.questionData.latitude,
                            isFound: true,
                            id: marker.id,
                          );
                          newMarkers.add(foundM);
                          setState(() {
                            _ourMarkers = newMarkers;
                          });
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FutureBuilder(future: buldFc.getImageByID(marker is RecordMarker ? marker.id : marker is QuestionMarker ? marker.id : 0),
                                    builder: (context, img) =>
                                        DetailScreen(
                                      location: "Karlsruhe",
                                      imagePath: img.data.toString(),
                                      title: "Exponat Nr. 15",
                                      description: "Das ist Exponat Nr. 15, Lorem ipsum usw.",
                                    )
                                  ))
                            );
                      },
                      child: FutureBuilder(
                          future: buldFc.getImageByID(marker is QuestionMarker
                              ? marker.id
                              : marker is RecordMarker
                                  ? marker.id
                                  : 0),
                          builder: (_, img) => Container(
                                alignment: Alignment.center,
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                        width: 2, color: Colors.black54)),
                                child: PopupDisplayMap(
                                    imageSource: img.data.toString(),
                                    id: marker is QuestionMarker
                                        ? marker.id
                                        : marker is RecordMarker
                                            ? marker.id
                                            : 0),
                              )));
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
      {required this.longitude,
      required this.latitude,
      required this.isFound,
      required this.id})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 60,
            width: 60,
            point: LatLng(latitude, longitude),
            builder: (BuildContext ctx) => Icon(Icons.flag_rounded,
                color: isFound ? Colors.blueAccent : Colors.black));

  final double longitude;
  final double latitude;
  final bool isFound;
  final int id;
}

class QuestionMarker extends Marker {
  QuestionMarker(
      {required this.questionData, required this.isFound, required this.id})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 60,
            width: 60,
            point: LatLng(questionData.latitude, questionData.longitude),
            builder: (BuildContext ctx) => Icon(Icons.ac_unit,
                color: isFound ? Colors.blueAccent : Colors.black));

  final Question questionData;
  final bool isFound;
  final int id;
}

class PopupDisplayMap extends StatelessWidget {
  const PopupDisplayMap({Key? key, required this.imageSource, required this.id})
      : super(key: key);
  final int id;
  final String imageSource;

  @override
  Widget build(BuildContext context) {
    return Image.network(imageSource);
  }
}
