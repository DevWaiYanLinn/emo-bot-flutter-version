import 'package:emobot/emotion.dart';
import 'package:emobot/services/image_service.dart';
import 'package:emobot/widgets/recent_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: AnnotatedRegion(
            value: const SystemUiOverlayStyle(statusBarColor: Colors.black),
            child: Scaffold(
                backgroundColor: Colors.black,
                body: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                            'assets/images/logo.png',
                                            filterQuality: FilterQuality.high,
                                            fit: BoxFit.cover),
                                      )
                                    ],
                                  ),
                                ),
                                const Icon(Icons.settings,
                                    color: Colors.white, size: 40)
                              ],
                            )),
                        featureWiget(context),
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          child: const Text('Recent Images',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white)),
                        ),
                        const Expanded(child: RecentImage())
                      ],
                    )))));
  }

  Widget featureWiget(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(77, 114, 152, 1),
                ),
                height: 150,
                child: const Center(
                    child: Icon(
                  Icons.camera_enhance,
                  color: Colors.white,
                  size: 50,
                )))),
        const SizedBox(width: 20),
        Expanded(
            child: GestureDetector(
                onTap: () {
                  ImageService.pickImage().then((image) => {
                        if (image != null)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Emotion(
                                          image: image,
                                        )))
                          }
                      });
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 119, 166, 182),
                    ),
                    height: 150,
                    child: const Center(
                        child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 50,
                    ))))),
      ],
    );
  }
}
