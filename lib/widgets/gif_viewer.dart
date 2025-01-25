import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GifViewer extends StatelessWidget {
  final String gifUrl;
  final double? width;
  final double? height;

  const GifViewer({
    super.key,
    required this.gifUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: gifUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}