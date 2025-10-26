import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20.0,
    this.color = const Color(0xFF126E06),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => Icon(Icons.star, color: color),
      itemCount: 5,
      itemSize: size,
      direction: Axis.horizontal,
    );
  }
}
