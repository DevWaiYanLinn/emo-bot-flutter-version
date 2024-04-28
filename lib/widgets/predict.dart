// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';

class Predict extends StatefulWidget {
  final String path;
  final double scale = (200.0 / 300);
  const Predict({super.key, required this.path});
  @override
  State<Predict> createState() => _FaceState();
}

class _FaceState extends State<Predict> {
  late final http.Client client;
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
      client = http.Client();
      final image = await img.decodeImageFile(widget.path);
      final resize = img.copyResize(image as img.Image, width: 300);
      final png = img.encodePng(resize);
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://waiyanlynn-fast-api-emotion.hf.space/api/emotions'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          png,
          filename: 'image.png', // Provide a filename for the image
          contentType: MediaType('image', 'png'), // Set the content type
        ),
      );
      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();
      final faceList = jsonDecode(responseBody) as List;
      if (faceList.isNotEmpty) {
        List<dynamic> retangle = faceList.map((e) {
          double x = e['region']['x'] * widget.scale;
          double y = e['region']['y'] * widget.scale;
          double w = e['region']['w'] * widget.scale;
          double h = e['region']['h'] * widget.scale;
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
  void dispose() {
    super.dispose();
    client.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.file(
                  File(widget.path),
                  width: 200,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                            child: Icon(Icons.error, color: Colors.red)));
                  },
                ),
                if (faces.isEmpty && message.isEmpty)
                  Positioned.fill(
                      child: Lottie.asset('assets/lottie/scanning.json',
                          frameRate: const FrameRate(60))),
                ...List.generate(faceboxes.length, (index) {
                  return Positioned(
                    left: faceboxes[index]['x'],
                    top: faceboxes[index]['y'],
                    width: faceboxes[index]['w'],
                    height: faceboxes[index]['h'],
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan, width: 2.0),
                      ),
                      child: Text("${index + 1}",
                          style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    ),
                  );
                })
              ],
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
                                color:
                                    const Color.fromARGB(255, 119, 166, 182)),
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
      final String value = entry.value.toStringAsFixed(2);
      final String key = entry.key;
      return TableRow(children: [
        TableCell(
            child: Table(
          border: const TableBorder(
              verticalInside:
                  BorderSide(color: Color.fromARGB(255, 119, 166, 182))),
          children: [
            TableRow(children: [
              SizedBox(
                height: 50,
                child: Center(
                    child: Text(key,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15))),
              ),
              SizedBox(
                height: 50,
                child: Center(
                    child: Text('$value%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15))),
              ),
            ])
          ],
        ))
      ]);
    }).toList();
  }
}
