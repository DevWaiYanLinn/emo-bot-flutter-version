import 'package:emobot/widgets/safe_area_view.dart';
import 'package:image/image.dart' as img;
import 'package:emobot/emotion.dart';
import 'package:emobot/widgets/recent_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<Map<String, dynamic>?> _pickImage(
      {source = ImageSource.gallery}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickImage = await picker.pickImage(source: source);

    if (pickImage != null) {
      final decodeImage =
          await img.decodeImageFile(pickImage.path) as img.Image;
      final resize = img.copyResize(decodeImage, width: 300);
      return {
        'data': img.encodePng(resize),
        'width': resize.width,
        'height': resize.height
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaView(
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
                  width: 130,
                  height: 130,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset('assets/images/logo.png',
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.settings, color: Colors.white, size: 40)
              ],
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text('Emotbot AI emotion detector',
                style: TextStyle(color: Colors.white, fontSize: 20 ,fontWeight: FontWeight.bold))),
        featureWiget(context),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: const Text('Recent Images',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white)),
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
                      _pickImage(source: ImageSource.camera).then((image) => {
                            if (image != null)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Emotion(
                                              image: image,
                                            )))
                              }
                          })
                    },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromRGBO(77, 114, 152, 1),
                    ),
                    height: 150,
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
                  _pickImage().then((image) => {
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
                      borderRadius: BorderRadius.circular(5),
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
