import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordViewData {
  RecordViewData(this.baseRecord, this.recordImg);

  Record baseRecord;
  Image recordImg;
}

Future<List<RecordViewData>> getVisitedRecords() async {
  var fc = FetchContent();
  var record = await fc.fetchRecord(1);
  var image = await fc.getImageByID(record!.id);
  return [RecordViewData(record, image)];
}

class FetchContent {
  double latitude_min = 48.99;
  double latitude_max = 49.036;
  double longitude_min = 8.33;
  double longitude_max = 8.47;
  List<RecordViewData> collectibles = List.empty(growable: true);
  LatLng user_position = LatLng(49.01358967154513, 8.404437624549605);

  Future<Image> getImageByID(final int id) async {
    //TODO: get image from backend
    return Image.asset("assets/testimage.jpg");
  }

  void syncData() async {
    final response =
    await http.get(Uri.parse('http://192.168.178.37:5000/api/ids'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> content = jsonDecode(response.body);
      for (Map<String, dynamic> id in content) {
        print("Looking at id " + id.values.first.toString());
        Record? record;
        var local = false;
        await Record.get(id.values.first).then((value) {
          record = value;
          local = true;
        }).onError((error, stackTrace) {
          print(error);
        });
        if (record == null) {
          await fetchRecord(id.values.first)
              .then((value) => record = value)
              .onError((error, stackTrace) {
            print(error);
          });
        } else {
          print("found record locally");
        }
        if (record != null) {
          collectibles
              .add(RecordViewData(record!, await getImageByID(record!.id)));
          if (!local) {
            record!.save();
            print("saved record " + id.values.first.toString());
          }
        }
      }
    } else {
      // Use local data
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys()) {
        final record = await Record.get(int.parse(key));
        collectibles.add(RecordViewData(record, await getImageByID(record.id)));
      }
      throw Exception('Failed to load record');
    }
  }

  Future<Record?> fetchRecord(final int id) async {
    final response = await http.get(Uri.parse(
        'http://192.168.178.37:5000/api/elements/?id=' + id.toString()));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final content = jsonDecode(response.body);
      print(content.toString());
      try {
        return Record.fromJson(content[0]);
      } catch (e) {
        return new Future<Record>.error(
            id.toString() + " not found on server or parsing error");
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return new Future<Record>.error("server response != 200");
    }
  }
}

class Record {
  final int id;
  final double x;
  final double y;
  final String? image;
  final String title;
  final String text;
  final String place;
  final double? latitude;
  final double? longitude;
  final String? voice;
  final String type;
  final String? username;

  const Record(
      {required this.title,
        required this.place,
        required this.latitude,
        required this.longitude,
        required this.id,
        required this.x,
        required this.y,
        required this.image,
        required this.text,
        required this.voice,
        required this.type,
        required this.username});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
        id: json['id'],
        x: json['x'],
        y: json['y'],
        image: json['image'],
        title: json['title'],
        text: json['text'],
        place: json['place'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        voice: json['voice'],
        type: json['type'],
        username: json['username']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'image': image,
      'title': title,
      'text': text,
      'place': place,
      'latitude': latitude,
      'longitude': longitude,
      'voice': voice,
      'type': type,
      'username': username
    };
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(id.toString(), jsonEncode(this));
  }

  static Future<Record> get(final int id) async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.get(id.toString());
    if (result != null) {
      return Record.fromJson(jsonDecode(result.toString()));
    }
    return new Future<Record>.error("no local value found");
  }

  void printDebug1() {
    print(id.toString() +
        x.toString() +
        " " +
        y.toString() +
        (image?.toString() ?? "") +
        text +
        (voice?.toString() ?? "") +
        type +
        (username?.toString() ?? ""));
  }
}
