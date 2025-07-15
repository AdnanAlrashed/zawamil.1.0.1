import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../models/reader.dart';
import 'reader_recitations_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/artist_avatar.dart';

class ReadersScreen extends StatelessWidget {
  final List<Reader> recitations = [
    Reader(
      id: '1',
      name: 'المنشاوي',
      imageUrl: '',
      recitations: [
        Recitation(
          id: '1',
          title: 'المنشاوي - سورة البقرة',
          audioUrl: 'audio/alminshawi/albaqaruh.mp3',
        ),
      ],
    ),

    // يمكن إضافة المزيد من الفنانين هنا
  ];

  // const ReadersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القراء'),
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
          itemCount: recitations.length,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              color: AppColors.getCardColor(context),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderRecitationsScreen(
                        reader: recitations[index],
                        recitations: recitations[index].recitations,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Hero(
                    tag: 'reader_${recitations[index].id}',
                    child: ArtistAvatar(
                      imageUrl: recitations[index].imageUrl,
                      radius: 28,
                    ),
                  ),
                  title: Text(
                    recitations[index].name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.getTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text(
                    'عدد السور: ${recitations[index].recitations.length}',
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
          showSearch(
            context: context,
            delegate: ReaderSearchDelegate(recitations),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.search),
      ),
    );
  }
}

// إضافة كلاس للبحث
class ReaderSearchDelegate extends SearchDelegate {
  final List<Reader> recitations;

  ReaderSearchDelegate(this.recitations);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = recitations
        .where(
          (reader) => reader.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildArtistsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = recitations
        .where(
          (reader) => reader.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildArtistsList(suggestions);
  }

  Widget _buildArtistsList(List<Reader> recitations) {
    return ListView.builder(
      itemCount: recitations.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: ArtistAvatar(
          imageUrl: recitations[index].imageUrl,
          radius: 24,
        ),
        title: Text(recitations[index].name),
        onTap: () {
          close(ctx, recitations[index]);
        },
      ),
    );
  }
}
