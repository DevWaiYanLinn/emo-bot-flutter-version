import 'package:emobot/widgets/safe_area_view.dart';
import 'package:emobot/emotion.dart';
import 'package:emobot/widgets/recent_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<String?> _pickImage({source = ImageSource.gallery}) async {
    final ImagePicker picker = ImagePicker();
    if (source == ImageSource.camera) {
      final request = await Permission.camera.request();
      if (request.isDenied) {
        return null;
      }
    }
    final XFile? pickImage = await picker.pickImage(source: source);
    return pickImage?.path;
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/images/logo.png',
                        filterQuality: FilterQuality.high, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            const Icon(Icons.settings, color: Colors.white, size: 40)
          ],
        ),
        const SizedBox(
            child: Text('Emobot AI Emotion Detector',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold))),
        Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text('What are you waiting for?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
        featureWiget(context),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: const Text('Recent Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              )),
        ),
        const Expanded(child: RecentImage())
      ],
    ));
  }

  Widget featureWiget(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: GestureDetector(
                onTap: () => {
                      _pickImage(source: ImageSource.camera).then((path) => {
                            if (path != null)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Emotion(
                                              path: path,
                                            )))
                              }
                          })
                    },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromRGBO(77, 114, 152, 1),
                    ),
                    height: 160,
                    child: const Center(
                        child: Icon(
                      Icons.camera_enhance,
                      color: Colors.white,
                      size: 50,
                    ))))),
        const SizedBox(width: 20),
        Expanded(
            child: GestureDetector(
                onTap: () {
                  _pickImage().then((path) => {
                        if (path != null)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Emotion(
                                          path: path,
                                        )))
                          }
                      });
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 119, 166, 182),
                    ),
                    height: 160,
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
