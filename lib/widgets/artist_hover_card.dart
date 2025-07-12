import 'package:flutter/material.dart';
import '../models/artist.dart';
import 'artist_avatar.dart';
import 'hover_reveal_card.dart';

class ArtistHoverCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistHoverCard({
    Key? key,
    required this.artist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: HoverRevealCard(
        frontContent: ArtistAvatar(imageUrl: artist.imageUrl),
        hiddenContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              artist.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              '${artist.songCount} songs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
