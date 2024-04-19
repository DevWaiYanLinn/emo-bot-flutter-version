import 'package:emobot/emotion.dart';
import 'package:emobot/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class RecentImage extends StatefulWidget {
  const RecentImage({super.key});

  @override
  State<RecentImage> createState() => _RecentImageState();
}

Future<List<AssetEntity>> getRecentImages() async {
  final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: FilterOptionGroup(orders: [
        const OrderOption(
          type: OrderOptionType.createDate,
          asc: false,
        ),
      ]));
  final recentAlbum = paths.first;
  final recentAssets = await recentAlbum.getAssetListPaged(page: 0, size: 50);
  return recentAssets;
}

class _RecentImageState extends State<RecentImage> {
  List<dynamic> recentImages = [];
  @override
  void initState() {
    super.initState();
    getRecentImages().then((images) {
      setState(() {
        recentImages = images;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 4 / 3),
        physics: const BouncingScrollPhysics(),
        itemCount: recentImages.length,
        itemBuilder: (BuildContext context, int index) =>
            photo(recentImages[index]));
  }

  Widget photo(AssetEntity entity) {
    return GestureDetector(
        onTap: () async {
          ImageService.entityToImage(entity).then((image) => {
                if (image != null)
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Emotion(
                                  image: ImageService.getImageProperties(image),
                                )))
                  }
              });
        },
        child: AssetEntityImage(entity,
            isOriginal: false, // Defaults to `true`.
            thumbnailSize: const ThumbnailSize.square(250), // Preferred value.
            thumbnailFormat: ThumbnailFormat.jpeg,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        }));
  }
}
