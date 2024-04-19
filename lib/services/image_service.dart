import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageService {
  static Map<String, Object> getImageProperties(image) {
    int width = 300;
    int height = ((width / image.width) * image.height).round();
    int showWidth = 200;
    int showHeight =( (showWidth / width) * height).round();
    double scaleWidth = showWidth / width;
    double scaleHeight = showHeight / height;
    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);
    List<int> compressedBytes = img.encodePng(resizedImage);
    return {
      'data': compressedBytes,
      'width': width,
      'height': height,
      'showWidth': showWidth,
      'showHeight': showHeight,
      'scaleWidth': scaleWidth,
      'scaleHeight': scaleHeight,
    };
  }

  static Future<Map<String, Object>?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickImage == null) return null;
    final image = await img.decodeImageFile(pickImage.path);
    if (image != null) {
      return getImageProperties(image);
    }
    return null;
  }

  static Future<img.Image?> entityToImage(AssetEntity entity) async {
    final file = await entity.loadFile();
    if (file != null) {
      final image = img.decodeImageFile(file.path);
      return image;
    }
    return null;
  }
}
