import 'package:emobot/widgets/predict.dart';
import 'package:emobot/widgets/safe_area_view.dart';
import 'package:flutter/material.dart';

class Emotion extends StatelessWidget {
  final Map<String, dynamic> image;
  const Emotion({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SafeAreaView(child: Predict(image: image));
  }
}
