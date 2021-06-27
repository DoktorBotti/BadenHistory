import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String? location;
  final String imagePath;
  final String title;
  final String? description;

  const DetailScreen({
    Key? key,
    required this.location,
    required this.imagePath,
    required this.title,
    required this.description
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 0.1 * MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: Text(
                    title
                ),
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  (location != null ? location : "")!,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: 0.4 * MediaQuery.of(context).size.height,
                ),
                child: Image.network(imagePath),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  (description != null ? location : "")!,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.6)),
                ),
              ),
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
                    child: const Text('ACTION 1'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Perform some action
                    },
                    child: const Text('ACTION 2'),
                  ),
                ],
              ),
            ]
          )
        ]
      ),
    );
  }
}
