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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) {
            return Image.network(
              url,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              loadingBuilder: (context, child, loadingProgress) {
                return child;
              },
            );
          },
          errorWidget: (context, url, error) => const Icon(Icons.error),
          imageBuilder: (context, imageProvider) {
            // Called when image is fully loaded
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
