import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ArtistAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ArtistAvatar({this.imageUrl, this.radius = 24.0});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? AssetImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.music_note, size: radius, color: AppColors.primary)
          : null,
    );
  }
}
