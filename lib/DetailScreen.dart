import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final int id;
  final String title;
  final String location;
  final double latitude;
  final double longitude;
  final String imagePath;
  final String description;

  const DetailScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 0.1 * MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                maxLines: 2,
                              ),
                            )
                        ),
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(50.0, 10.0, 0, 20.0),
                            child: Text(
                                "Location: " + location,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 20,
                                )
                            ),
                          ),
                        )
                      ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: 0.4 * MediaQuery.of(context).size.height,
                          maxWidth: 0.8 * MediaQuery.of(context).size.width,
                        ),
                        child: Image.network(imagePath),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                                "Beschreibung:\n" + description,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 15,
                                )
                            ),
                          ),
                        )
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                            child: Text(
                                "Coordinates: " + latitude.toString() + "° N, " + longitude.toString() + "° W",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 15,
                                )
                            ),
                          ),
                        )
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Perform some action
                              },
                              child: const Text('Back'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Perform some action
                              },
                              child: const Text('Chat'),
                            ),
                          ],
                        ),
                      ]
                  )
                ]
            ),
          ),
        )
    );
  }
}
