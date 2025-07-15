import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../models/song.dart'; // Added missing import
import 'music_player_screen.dart';
import '../theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../services/firestore_service.dart';

class ArtistSongsScreen extends StatelessWidget {
  final Artist artist;
  final List<Song> songs;

  const ArtistSongsScreen(
      {super.key, required this.artist, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArtist(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirestoreService.getSongsByArtistStream(artist.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as dynamic).docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
            );
          }
          final docs = (snapshot.data as dynamic).docs;
          final songs = docs.map<Song>((doc) {
            final data = doc.data();
            return Song(
              id: doc.id,
              title: data['title'] ?? '',
              audioUrl: data['audio_url'] ?? '',
              artistId: data['artist_id'] ?? '',
            );
          }).toList();
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (ctx, index) => Card(
              color: AppColors.getCardColor(context),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerScreen(
                        audioItem: AudioItem(
                          id: (songs[index].id ?? '').toString(),
                          title: songs[index].title,
                          audioUrl: songs[index].audioUrl,
                          imageUrl: artist.imageUrl,
                          artistName: artist.name,
                        ),
                        playlist: songs
                            .map(
                              (song) => AudioItem(
                                id: (song.id ?? '').toString(),
                                title: song.title,
                                audioUrl: song.audioUrl,
                                imageUrl: artist.imageUrl,
                                artistName: artist.name,
                              ),
                            )
                            .toList()
                            .cast<AudioItem>(),
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Hero(
                    tag: 'song_${songs[index].id}_${artist.id}',
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
          );
        },
      ),
    );
  }

  void _shareArtist(BuildContext context) {
    final text = 'استمع إلى ${artist.name} على تطبيق Zwamil\n'
        'عدد الزوامل: ${artist.songCount}';
    Share.share(text);
  }
}
