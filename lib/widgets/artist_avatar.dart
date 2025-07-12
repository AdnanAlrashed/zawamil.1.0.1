import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ArtistAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? errorWidget;

  const ArtistAvatar({this.imageUrl, this.radius = 24.0, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: ClipOval(
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.asset(
                imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    errorWidget ??
                    Icon(Icons.person, size: radius, color: AppColors.primary),
              )
            : errorWidget ??
                  Icon(
                    Icons.music_note,
                    size: radius,
                    color: AppColors.primary,
                  ),
      ),
    );
  }
}
