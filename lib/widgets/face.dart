// ignore: file_names
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Face extends StatefulWidget {
  final Map<String, dynamic> image;
  const Face({super.key, required this.image});
  @override
  State<Face> createState() => _FaceState();
}

class _FaceState extends State<Face> {
  List<dynamic> faces = [];
  List<dynamic> faceboxes = [];
  String message = '';

  @override
  void initState() {
    super.initState();
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
          double x = e['region']['x'] * widget.image['scaleWidth'];
          double y = e['region']['y'] * widget.image['scaleHeight'];
          double w = e['region']['w'] * widget.image['scaleWidth'];
          double h = e['region']['h'] * widget.image['scaleHeight'];
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
              width: widget.image['showWidth'] + .0,
              height: widget.image['showHeight'] + .0,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Image.memory(
                    Uint8List.fromList(widget.image['data']),
                  )),
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
                            style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.w500)),
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
            child: ListView(
          physics: const BouncingScrollPhysics(),
          children: List.generate(
              faces.length,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Table(
                      border: TableBorder.all(color: const Color.fromRGBO(77, 114, 152, 1)),
                      children: [
                        TableRow(children: [
                          SizedBox(
                            height: 50,
                            child: Center(
                                child: Text('Face ${index + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20))),
                          ),
                        ]),
                        ...faces[index]['emotion'].entries.map((entry) {
                          final String value = entry.value.toStringAsFixed(2);
                          final String key = entry.key;
                          return TableRow(children: [
                            TableCell(
                                child: Table(
                              border: const TableBorder(
                                  verticalInside:
                                      BorderSide(color: Color.fromRGBO(77, 114, 152, 1))),
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
                        })
                      ],
                    ),
                  )),
        ))
      ],
    );
  }
}
