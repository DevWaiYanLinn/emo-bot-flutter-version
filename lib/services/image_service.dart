import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageService {
  static Map<String, Object> processingImage(image) {
    double width = 300;
    Image resize =
        copyResize(image, width: width.toInt(), maintainAspect: true);
    double height = resize.height.toDouble();
    double showWidth = 200;
    double showHeight = ((showWidth / width) * height).toDouble();
    double scaleWidth = showWidth / width;
    double scaleHeight = showHeight / height;
    List<int> compressedBytes = encodePng(resize);
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

  static Future<Map<String, Object>?> getImageProperties(path) async {
    try {
      final image = await decodeImageFile(path);
      return processingImage(image);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, Object>?> pickImage(
      {source = ImageSource.gallery}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickImage =
        await picker.pickImage(source:source);
    return getImageProperties(pickImage?.path);
  }

  static Future<Map<String, Object>?> entityToImage(AssetEntity entity) async {
    final file = await entity.loadFile();
    return getImageProperties(file?.path);
  }
}
