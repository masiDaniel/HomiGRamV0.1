import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BlurCachedImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const BlurCachedImage({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = 180,
    this.fit = BoxFit.cover,
  });

  @override
  State<BlurCachedImage> createState() => _BlurCachedImageState();
}

class _BlurCachedImageState extends State<BlurCachedImage> {
  bool _isLoading = true;

  bool get _isNetworkImage =>
      widget.imageUrl.startsWith("http://") ||
      widget.imageUrl.startsWith("https://");

  @override
  Widget build(BuildContext context) {
    if (!_isNetworkImage) {
      // Show asset directly (no blur needed)
      return Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    // Otherwise, load network image with blur while loading
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) => Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300], // simple grey placeholder
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          imageBuilder: (context, imageProvider) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_isLoading) {
                setState(() {
                  _isLoading = false;
                });
              }
            });

            return Image(
              image: imageProvider,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            );
          },
        ),
        if (_isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}
