import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../models/artist.dart';
import 'artist_songs_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/artist_avatar.dart';

class ArtistsScreen extends StatelessWidget {
  final List<Artist> artists = [
    Artist(
      id: '1',
      name: 'عيسى الليث',
      imageUrl: 'assets/images/Essa.jpg',
      songs: [
        Song(
          id: '1',
          title: 'غايتنا رضاك - عيسى الليث 1446هـ',
          audioUrl: 'audio/essa_alyth/ghayatuna_ridak.mp3',
        ),
        Song(
          id: '2',
          title: 'هامات عملاقة - عيسى الليث وحسن المؤيد 1446هـ',
          audioUrl: 'audio/essa_alyth/hamat_eimalaqih.mp3',
        ),
        Song(
          id: '3',
          title: 'عيد الجهاد المقدس - عيسى الليث 1446هـ',
          audioUrl: 'audio/essa_alyth/eid_aljihad_almuqadas.mp3',
        ),
      ],
    ),
    Artist(
      id: '2',
      name: 'حسين الطير',
      imageUrl: 'assets/images/Hussan_Altir.jpg',
      songs: [
        Song(
          id: '1',
          title: 'الموريات اليمانيه - حسين الطير 1446هـ',
          audioUrl: 'audio/hussan_altyr/almuriat_alyamanih.mp3',
        ),
        Song(
          id: '2',
          title: ' حسين الطير بلسم الروح 1446هـ',
          audioUrl: 'audio/hussan_altyr/zamil_balsam_aljurh.mp3',
        ),
      ],
    ),
    Artist(
      id: '3',
      name: 'حسن المؤيد',
      imageUrl: 'assets/images/default_artist.png',
      songs: [
        Song(
          id: '1',
          title: 'يا زهراء - حسن المؤيد 1446هـ',
          audioUrl: 'audio/hassan_moayed/ya_zahra.mp3',
        ),
        Song(
          id: '2',
          title: 'يا زهراء - حسن المؤيد 1446هـ',
          audioUrl: 'audio/hassan_moayed/ya_zahra_2.mp3',
        ),
      ],
    ),
    // يمكن إضافة المزيد من الفنانين هنا
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفنانين'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistSongsScreen(
                        artist: artists[index],
                        songs: artists[index].songs,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Hero(
                    tag: 'artist_${artists[index].id}',
                    child: ArtistAvatar(
                      imageUrl: artists[index].imageUrl,
                      radius: 28,
                    ),
                  ),
                  title: Text(
                    artists[index].name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'عدد الزوامل: ${artists[index].songs.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(context: context, delegate: ArtistSearchDelegate(artists));
        },
        child: Icon(Icons.search),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

// إضافة كلاس للبحث
class ArtistSearchDelegate extends SearchDelegate {
  final List<Artist> artists;

  ArtistSearchDelegate(this.artists);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = artists
        .where(
          (artist) => artist.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildArtistsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = artists
        .where(
          (artist) => artist.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildArtistsList(suggestions);
  }

  Widget _buildArtistsList(List<Artist> artists) {
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: ArtistAvatar(imageUrl: artists[index].imageUrl, radius: 24),
        title: Text(artists[index].name),
        onTap: () {
          close(ctx, artists[index]);
        },
      ),
    );
  }
}
