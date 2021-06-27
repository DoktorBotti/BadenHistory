import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_list/unique_list.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FetchContent {
  double latitude_min = 48.99;
  double latitude_max = 49.036;
  double longitude_min = 8.33;
  double longitude_max = 8.47;

  List<RecordViewData> collectibles = UniqueList();

  MyFindings myFindings = MyFindings();

  static final FetchContent _instance = FetchContent._internal();

  factory FetchContent() => _instance;

  LatLng user_position = LatLng(49.01358967154513, 8.404437624549605);

  FetchContent._internal() {
    syncData();
  }

  Future<String> getImageByID(final int id) async {
    // http://192.168.178.37:5000/api/images/21/
    final api = "http://192.168.178.37:5000/api/images/" + id.toString();
    print(api);
    //TODO: get image from backend
    return api;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<bool> isFound(final int id) async {
    return myFindings.foundIDs.contains(id);
  }

  void addFound(final int id) async {
    return myFindings.foundIDs.add(id);
  }

  List<int> allFound() {
    return myFindings.foundIDs;
  }

  // Future<File> writeFile() async {
  //   final file = await _localFile;
  //   // Write the file
  //   return file.writeAsString('');
  // }

  Future<bool> syncData() async {
    String collectable = RecordType.COLLECTABLE.rep;
    String question = RecordType.QUESTION.rep;
    await syncCategory(collectable);
    return syncCategory(question);
  }

  Future<bool> syncCategory(final String category) async{
    print("syncing");

    final response = await http.get(
        Uri.parse('http://192.168.178.37:5000/api/ids/?type="$category"'));
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
    print('Failed to load record');
    }
    return new Future<bool>.value(true);
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

class Question {
  final int id;
  final String questionTitle;
  final double latitude;
  final double longitude;

  const Question(
      {required this.id,
      required this.questionTitle,
      required this.longitude,
      required this.latitude});
}

class RecordViewData {
  RecordViewData(this.baseRecord, this.path);

  Record baseRecord;
  String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordViewData &&
          runtimeType == other.runtimeType &&
          baseRecord == other.baseRecord;

  @override
  int get hashCode => baseRecord.hashCode;
}

Future<List<RecordViewData>> getVisitedRecords() async {
  var fc = FetchContent();
  return fc.collectibles;
}

class Record {
  final int id;
  final double? x;
  final double? y;
  final String? image;
  final String? title;
  final String? text;
  final String? place;
  final double? latitude;
  final double? longitude;
  final String? voice;
  final String type;
  final String? username;
  final int? linkTo;
  final double? time;

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
      required this.username,
        required this.linkTo,
        required this.time});

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
        username: json['username'],
        linkTo: json['linkTo'],
        time: json['time']);
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
      'username': username,
      'linkTo': linkTo,
      'time': time
    };
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Record && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

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
        text! +
        (voice?.toString() ?? "") +
        type +
        (username?.toString() ?? ""));
  }
}

class MyFindings {

  static final String key = "my_findings";

  List<int> foundIDs = UniqueList();

  static final MyFindings _instance = MyFindings._internal();

  factory MyFindings() => _instance;

  MyFindings._internal() {
    get();
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encode());
  }

  String encode() {
    return foundIDs.join(",").toString();
  }

  static List<int> decode(String decoded) {
    var list = UniqueList<int>();
    list.addAll(decoded.split(",").map((e) => int.parse(e)));
    return list;
  }

  static Future<bool> get() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.get(key);
    MyFindings my = MyFindings();
    if (result != null) {
      my.foundIDs = decode(result.toString());
    }
    return new Future<bool>.value(true);
  }

}

enum RecordType {
  RECORD,COMMENT,AUDIO,COLLECTABLE,QUESTION,IMAGE
}

extension RecordTypeRep on RecordType {
  String get rep {
    switch (this) {

      case RecordType.RECORD:
        return "record";
      case RecordType.COMMENT:
        return "comment";
      case RecordType.AUDIO:
        return "audio";
      case RecordType.COLLECTABLE:
        return "collectable";
      case RecordType.QUESTION:
        return "question";
      case RecordType.IMAGE:
        return "image";
    }
  }
}
