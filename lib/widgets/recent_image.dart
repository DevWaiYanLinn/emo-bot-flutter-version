import 'package:emobot/emotion.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class RecentImage extends StatefulWidget {
  const RecentImage({super.key});

  @override
  State<RecentImage> createState() => _RecentImageState();
}

class _RecentImageState extends State<RecentImage> {
  List<dynamic> recentImages = [];
  @override
  void initState() {
    super.initState();
    _setRecentImages();
  }

  Future<List<AssetEntity>> _getRecentImages() async {
    final permission = await Permission.storage.status;

    if (!permission.isGranted) {
      await Permission.storage.request();
    }

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

  void _setRecentImages() {
    _getRecentImages().then((images) {
      setState(() {
        recentImages = images;
      });
    });
  }

  Future<String?> _loadFile(AssetEntity entity) async {
    final file = await entity.loadFile();
    return file?.path;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1),
            physics: const BouncingScrollPhysics(),
            itemCount: recentImages.length,
            itemBuilder: (BuildContext context, int index) =>
                photo(recentImages[index], context)),
        onRefresh: () async {
          _setRecentImages();
        });
  }

  Widget photo(AssetEntity entity, BuildContext context) {
    return GestureDetector(
        onTap: () async {
          _loadFile(entity).then((path) {
            if (path != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Emotion(
                            path: path,
                          )));
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
