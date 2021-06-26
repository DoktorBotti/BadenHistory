import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;


  const DetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          children: [
            ExhibitImage(imagePath: imagePath,),
            InfoTable(),
          ]
      )
    );
  }
}

class ExhibitImage extends StatelessWidget {
  final String imagePath;
  const ExhibitImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class InfoTable extends StatelessWidget {
  final String title = "Title-Placeholder";
  const InfoTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              Container(
                height: 32,
                color: Colors.green,
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Container(
                  height: 32,
                  width: 32,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          TableRow(
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
            children: <Widget>[
              Container(
                height: 64,
                width: 128,
                color: Colors.purple,
              ),
              Container(
                height: 32,
                color: Colors.yellow,
              ),
            ],
          ),
        ],
      );
    );
  }
}


class InfoTable2 extends StatelessWidget {
  const InfoTable2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.lightBlue,
            child: Column(
              children: [
                Text("Left")
              ]
            ),
          )
        ),
        Expanded(
          child: Container(
            color: Colors.lightGreen,
            child: Column(
              children: [
                Text("Right")
              ]
            ),
          )
        )
      ]
    );
  }
}
