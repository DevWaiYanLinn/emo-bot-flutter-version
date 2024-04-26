import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SafeAreaView extends StatelessWidget {
  final Widget child;
  const SafeAreaView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: AnnotatedRegion(
            value: const SystemUiOverlayStyle(statusBarColor: Colors.black),
            child: Scaffold(
                backgroundColor: Colors.black,
                body:
                    Padding(padding: const EdgeInsets.all(10), child: child))));
  }
}
