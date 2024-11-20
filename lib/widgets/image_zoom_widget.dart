import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageZoomWidget extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const ImageZoomWidget(
      {super.key, required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoViewGallery.builder(
        itemCount: photos.length,
        builder: (context, index) {
          String base64String = photos[index];
          if (base64String.contains('base64,')) {
            base64String = base64String.split('base64,')[1];
          }

          return PhotoViewGalleryPageOptions(
            imageProvider: MemoryImage(base64Decode(base64String)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
