import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ws/DetailScreen.dart';
import 'package:flutter_ws/MapScreen.dart';
import 'package:flutter_ws/RecordsAndFetcher.dart';
import 'package:flutter_ws/ChatScreen.dart';

import 'package:cached_network_image/cached_network_image.dart';

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
        length: 2,
        initialIndex: 1,
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
                // Tab(
                //   text: 'Quests',
                //   icon: Icon(Icons.access_time),
                // ),
                // Tab(text: 'AudioStuff TMP', icon: Icon(Icons.access_alarms)),
                // Tab(text: 'Chat', icon: Icon(Icons.access_alarms))
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FindingsScreen(),
              MapContainer(),
              // DetailScreen(
              //   location: "Karlsruhe",
              //   imagePath: "assets/testimage.jpg",
              //   title: "Exponat Nr. 15",
              //   description: "Das ist Exponat Nr. 15, Lorem ipsum usw.",
              // ),
              // AudioGui(),
              // ChatDetailPage()
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
  // 0 DetailsScreen
  // 1 StandardScreen
  // 2 ChatScreen

  int state1 = 0;
  int selected = 0;
  void setState1(int state) {
    setState(() {
      state1 = state;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<List<RecordViewData>>(
      future: getVisitedRecords(),
      builder: (context, rec) {
        if (rec.hasData) {
          if(state1 == 0) {
            return DetailScreen(id: rec.data![selected].baseRecord.id, title: rec.data![selected].baseRecord.title!, location: rec.data![selected].baseRecord.place!, latitude: rec.data![selected].baseRecord.latitude!, longitude: rec.data![selected].baseRecord.longitude!, imagePath: rec.data![selected].path, description: rec.data![selected].baseRecord.text!);
          } else if (state1 == 1) {
            return ListView.builder(
                itemCount: rec.data!.length,
                itemBuilder: (context, i) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // ListTile(
                        //   leading: Icon(Icons.arrow_drop_down_circle),
                        //   title: Text(rec.data![i].baseRecord.title),
                        //   subtitle: Text(rec.data![i].baseRecord.place,
                        //     style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        //   ),
                        // ),
                        //rec.data![i].path,
                        ExpansionTile(
                          // leading:
                            title: Row(children: [
                              Container(
                                height: 0.1 * MediaQuery.of(context).size.height,
                                width: 0.3 *
                                    MediaQuery.of(context).size.width, // 20%
                                child: Image.network(rec.data![i].path,
                                    fit: BoxFit.fitHeight),
                                alignment: Alignment.center,
                              ),
                              Container(
                                height: 0.1 * MediaQuery.of(context).size.height,
                                width: 0.5 *
                                    MediaQuery.of(context).size.width, // 60%
                                alignment: Alignment.centerLeft,
                                child: Text(rec.data![i].baseRecord.title!),
                              ),
                            ]),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  rec.data![i].baseRecord.place!,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Image.network(rec.data![i].path),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  rec.data![i].baseRecord.text!,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [

                                  TextButton(
                                    onPressed: () {
                                      // DefaultTabController.of(context)!.animateTo(2);
                                      // DefaultTabController.of(context)
                                      // _HomeScreenState.tabController.animateTo(DetailScreen(location: rec.data![i].baseRecord.place, imagePath: rec.data![i].path,title: rec.data![i].baseRecord.title!, description: rec.data![i].baseRecord.text!,));
                                      setState(() {
                                        state1 = 0;
                                      });
                                      selected = i;
                                      build(context);
                                      print("pressed, switch to details");
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => DetailScreen(location: rec.data![i].baseRecord.place, imagePath: rec.data![i].path,title: rec.data![i].baseRecord.title!, description: rec.data![i].baseRecord.text!,)),
                                      // );
                                    },
                                    child: const Text('Details'),
                                  ),
                                ],
                              ),
                            ]),
                      ],
                    ),
                  );
                });
          }
          else  {
            return ChatDetailPage();
          }

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

  Future<List<RecordViewData>> getVisitedRecords() async {
    var fc = FetchContent();
    return fc.collectibles;
  }
}
