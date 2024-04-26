// ignore: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';

class Predict extends StatefulWidget {
  final Map<String, dynamic> image;
  const Predict({super.key, required this.image});
  @override
  State<Predict> createState() => _FaceState();
}

class _FaceState extends State<Predict> {
  List<dynamic> faces = [];
  List<dynamic> faceboxes = [];
  List<double> dimensions = [];
  List<double> rescaleDimensions = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    double height = (200 / widget.image['width']) * widget.image['height'];
    double rescaleHight = height / widget.image['height'];
    double rescaleWidth = 200.0 / widget.image['width'];
    rescaleDimensions = [rescaleWidth, rescaleHight];
    dimensions = [200, height];
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://waiyanlynn-fast-api-emotion.hf.space/api/emotions'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          widget.image['data'],
          filename: 'image.png', // Provide a filename for the image
          contentType: MediaType('image', 'png'), // Set the content type
        ),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final faceList = jsonDecode(responseBody) as List;
      if (faceList.isNotEmpty) {
        List<dynamic> retangle = faceList.map((e) {
          double x = e['region']['x'] * rescaleDimensions[0];
          double y = e['region']['y'] * rescaleDimensions[1];
          double w = e['region']['w'] * rescaleDimensions[0];
          double h = e['region']['h'] * rescaleDimensions[1];
          return {
            'x': x,
            'y': y,
            'w': w,
            'h': h,
          };
        }).toList();
        setState(() {
          faceboxes = retangle;
          faces = faceList;
        });
      } else {
        setState(() {
          message = 'No Face';
        });
      }
      // Process response here
    } catch (error) {
      setState(() {
        message = 'Network Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: dimensions[0],
              height: dimensions[1],
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Image.memory(
                    widget.image['data'],
                  )),
                  if (faces.isEmpty && message.isEmpty)
                    Positioned(
                        top: 0,
                        left: 0,
                        width: dimensions[0],
                        height: dimensions[1],
                        child: Lottie.asset('assets/lottie/scanning.json',
                            frameRate: const FrameRate(60))),
                  ...List.generate(faceboxes.length, (index) {
                    return Positioned(
                      left: faceboxes[index]['x'],
                      top: faceboxes[index]['y'],
                      width: faceboxes[index]['w'],
                      height: faceboxes[index]['h'],
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan, width: 2.0),
                        ),
                        child: Text("${index + 1}",
                            style: const TextStyle(
                                color: Colors.cyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
        if (message.isNotEmpty)
          SizedBox(
            height: 50,
            child: Center(
                child: Text(
              message,
              style: TextStyle(color: Colors.red[500]),
            )),
          ),
        const SizedBox(
          height: 50,
        ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: List.generate(
                    faces.length,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Table(
                            border: TableBorder.all(
                                color: const Color.fromRGBO(77, 114, 152, 1)),
                            children: [
                              TableRow(children: [
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                      child: Text('Face ${index + 1}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15))),
                                ),
                              ]),
                              ..._emotionList(faces[index]['emotion'])
                            ],
                          ),
                        )),
              )),
        )
      ],
    );
  }

  List<TableRow> _emotionList(Map<String, dynamic> emotion) {
        return emotion.entries.map((entry) {
                                final String value =
                                    entry.value.toStringAsFixed(2);
                                final String key = entry.key;
                                return TableRow(children: [
                                  TableCell(
                                      child: Table(
                                    border: const TableBorder(
                                        verticalInside: BorderSide(
                                            color: Color.fromRGBO(
                                                77, 114, 152, 1))),
                                    children: [
                                      TableRow(children: [
                                        SizedBox(
                                          height: 50,
                                          child: Center(
                                              child: Text(key,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15))),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          child: Center(
                                              child: Text('$value%',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15))),
                                        ),
                                      ])
                                    ],
                                  ))
                                ]);
                              }).toList();
  }
}
