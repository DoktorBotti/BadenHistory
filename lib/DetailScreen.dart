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
                      maxHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 0.4,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.lightBlue,
                        child: Column(
                          children: [
                            Text("Hallo")
                          ]
                        ),
                      )
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.lightGreen,
                        child: Column(
                          children: [
                            Text("Hallo")
                          ]
                        ),
                      )
                    )
                  ]
                )
              )
            )
          ]
      )
    );
  }
}
