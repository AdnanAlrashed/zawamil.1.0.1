import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../models/artist.dart';
import '../models/song.dart'; // Added missing import
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
          audioUrl: 'assets/audio/essa_alyth/ghayatuna_ridak.mp3', // Fixed path
        ),
        Song(
          id: '2',
          title: 'هامات عملاقة - عيسى الليث وحسن المؤيد 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/hamat_eimalaqih.mp3', // Fixed path
        ),
        Song(
          id: '3',
          title: 'عيد الجهاد المقدس - عيسى الليث 1446هـ',
          audioUrl:
              'assets/audio/essa_alyth/eid_aljihad_almuqadas.mp3', // Fixed path
        ),
        Song(
          id: '4',
          title: 'عيدالولايه - عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/ead_alwlayh.mp3', // Fixed path
        ),
        Song(
          id: '5',
          title: 'السراج الوهاج - عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/alsrag_alwhag.mp3', // Fixed path
        ),
        Song(
          id: '6',
          title: 'جند ربي - عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/jnen_rabe.mp3', // Fixed path
        ),
        Song(
          id: '7',
          title: 'عيدمبارك - عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/ead_mobark.mp3', // Fixed path
        ),
        Song(
          id: '8',
          title: 'فرط صوتي نسخه معدله - عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/fart_soty.mp3', // Fixed path
        ),
        Song(
          id: '9',
          title: 'كسرناهيبة امريكا -قناف المقبلي&عيسى الليث 1446هـ',
          audioUrl:
              'assets/audio/essa_alyth/ksrna_hebat_amrica.mp3', // Fixed path
        ),
        Song(
          id: '10',
          title: 'كليب مع غزة-حسين الؤيد&عيسى الليث 1446هـ',
          audioUrl: 'assets/audio/essa_alyth/kolap_mah_gazah.mp3', // Fixed path
        ),
        Song(
          id: '11',
          title: 'لن نترك فلسطين - عيسى الليث 1446هـ',
          audioUrl:
              'assets/audio/essa_alyth/lan_natrk_phlistain.mp3', // Fixed path
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
          audioUrl:
              'assets/audio/hussan_altyr/almuriat_alyamanih.mp3', // Fixed path
        ),
        Song(
          id: '2',
          title: ' حسين الطير بلسم الروح 1446هـ',
          audioUrl:
              'assets/audio/hussan_altyr/zamil_balsam_aljurh.mp3', // Fixed path
        ),
      ],
    ),
    // حسن المؤيد removed until audio files are added
    // يمكن إضافة المزيد من الفنانين هنا
  ];

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
                      errorWidget: Icon(Icons.person, size: 40),
                    ),
                  ),
                  title: Text(
                    artists[index].name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'عدد الزوامل: ${artists[index].songs.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
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
