import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;


  const DetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 2)
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text("Second row")
            ],
          ),
        ],
      )
    );
  }
}
