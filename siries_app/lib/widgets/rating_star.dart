import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color filledColor;
  final Color emptyColor;
  final TextStyle? textStyle;
  final double padding;
  final VoidCallback? onTap;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 24.0,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
    this.textStyle,
    this.padding = 4.0,
    this.onTap,
  });

  Color _getRatingColor(double rating) {
    if (rating >= 1 && rating < 3) {
      return Colors.red;
    } else if (rating >= 3 && rating < 4) {
      return Colors.amber;
    } else if (rating >= 4 && rating <= 5) {
      return Colors.green;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    double remainder = rating - fullStars;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              if (index < fullStars) {
                return Icon(Icons.star, size: starSize, color: filledColor);
              } else if (index == fullStars && remainder > 0) {
                return Stack(
                  children: [
                    Icon(Icons.star, size: starSize, color: emptyColor),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: remainder,
                        child: Icon(Icons.star, size: starSize, color: filledColor),
                      ),
                    ),
                  ],
                );
              } else {
                return Icon(Icons.star, size: starSize, color: emptyColor);
              }
            }),
          ),
          SizedBox(width: padding),
          Text(
            '(${rating.toStringAsFixed(1)})',
            style: (textStyle ?? const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )).copyWith(
              color: _getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }
}
