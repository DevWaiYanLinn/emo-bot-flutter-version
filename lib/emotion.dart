import 'package:emobot/widgets/face.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Emotion extends StatelessWidget {
  final Map<String, dynamic> image;
  const Emotion({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: AnnotatedRegion(
            value: const SystemUiOverlayStyle(statusBarColor: Colors.black),
            child: Scaffold(
                backgroundColor: Colors.black,
                body: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Face(image: image)))));
  }
}
