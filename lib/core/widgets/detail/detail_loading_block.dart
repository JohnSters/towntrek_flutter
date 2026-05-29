import 'package:flutter/material.dart';

class DetailLoadingBlock extends StatelessWidget {
  const DetailLoadingBlock({
    super.key,
    required this.height,
    required this.color,
    this.borderRadius = 12,
  });

  final double height;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
