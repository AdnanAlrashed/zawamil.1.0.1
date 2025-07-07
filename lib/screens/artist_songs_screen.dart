import 'package:flutter/material.dart';
import '../models/artist.dart';
import 'music_player_screen.dart';
import '../theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class ArtistSongsScreen extends StatelessWidget {
  final Artist artist;
  final List<Song> songs;

  const ArtistSongsScreen({required this.artist, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareArtist(context),
          ),
        ],
      ),
      body: songs.isEmpty
          ? Center(
              child: Column(
                children: [
                  Icon(
                    Icons.music_off,
                    size: 50,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  Text(
                    'لا يوجد زوامل متاحة حالياً',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (ctx, index) => Card(
                color: AppColors.getCardColor(context),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerScreen(
                          song: songs[index],
                          artist: artist,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Hero(
                      tag: 'song_${songs[index].id}_${artist.id}',
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                    title: Text(
                      songs[index].title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.getTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _shareArtist(BuildContext context) {
    final text =
        'استمع إلى ${artist.name} على تطبيق Zwamil\n'
        'عدد الزوامل: ${artist.songs.length}';
    Share.share(text);
  }
}
