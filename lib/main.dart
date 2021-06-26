import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ws/DetailScreen.dart';
import 'package:flutter_ws/MapScreen.dart';
import 'package:flutter_ws/RecordsAndFetcher.dart';
import 'package:flutter_ws/SoundComponents.dart';
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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Baden History'),
            bottom: TabBar(
              indicatorColor: Colors.white,
              isScrollable: true,
              tabs: [
                Tab(
                  text: 'My Findings',
                  icon: Icon(Icons.favorite),
                ),
                Tab(text: 'Map', icon: Icon(Icons.map_rounded)),
                Tab(
                  text: 'Quests',
                  icon: Icon(Icons.access_time),
                ),
                Tab(text: 'AudioStuff TMP', icon: Icon(Icons.access_alarms))
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
              AudioGui()
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
        ));
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
        child: FutureBuilder<List<RecordViewData>>(
      future: getVisitedRecords(),
      builder: (context, rec) {
        if (rec.hasData) {
          return ListView.builder(
              itemCount: rec.data!.length,
              itemBuilder: (context, i) {
                return Card(
                  child: Container(
                    child: Text(rec.data![i].baseRecord.text),
                  ),
                );
              });
        } else {
          return Card(
            child: Container(
              child: Text("no data"),
            ),
          );
        }
      },
    ));
  }
}
