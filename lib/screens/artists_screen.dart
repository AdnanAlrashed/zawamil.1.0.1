import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../models/artist.dart';
import '../models/song.dart';
import 'artist_songs_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/artist_avatar.dart';
import '../database/database_helper.dart';
import 'dart:io';

class ArtistsScreen extends StatefulWidget {
  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  List<Artist> artists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final artistsData = await DatabaseHelper.instance.getAllArtists();
    final List<Artist> loadedArtists = [];

    for (var artistData in artistsData) {
      final songsData = await DatabaseHelper.instance
          .getSongsByArtist(artistData['id'] as int);
      loadedArtists.add(Artist(
        id: artistData['id'],
        name: artistData['name'],
        imageUrl: artistData['image_url'] ?? '',
        songCount: songsData.length,
      ));
    }

    setState(() {
      artists = loadedArtists;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفنانين'),
        actions: [
          IconButton(
            icon: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) => Icon(
                themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : artists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا يوجد فنانين حالياً',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('قم بإضافة فنانين من شاشة الإدارة',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: artists.length,
                    itemBuilder: (ctx, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        color: AppColors.getCardColor(context),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final songsData = await DatabaseHelper.instance
                                .getSongsByArtist(artists[index].id!);
                            final songs = songsData
                                .map((songData) => Song(
                                      id: songData['id'],
                                      title: songData['title'],
                                      audioUrl: songData['audio_url'],
                                      artistId: songData['artist_id'],
                                    ))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistSongsScreen(
                                  artist: artists[index],
                                  songs: songs,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: artists[index].imageUrl.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: FileImage(
                                        File(artists[index].imageUrl)),
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                            title: Text(artists[index].name),
                            subtitle: Text(
                                'عدد الزوامل: ${artists[index].songCount}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
