import 'package:flutter/material.dart';
import '../models/reader.dart';
import 'music_player_screen.dart';
import '../theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class ReaderRecitationsScreen extends StatelessWidget {
  final Reader reader;
  final List<Recitation> recitations;

  const ReaderRecitationsScreen({
    required this.reader,
    required this.recitations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reader.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareArtist(context),
          ),
        ],
      ),
      body: recitations.isEmpty
          ? Center(
              child: Column(
                children: [
                  Icon(
                    Icons.music_off,
                    size: 50,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  Text(
                    'لا توجد سور متاحة حالياً',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: recitations.length,
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
                          audioItem: AudioItem(
                            id: recitations[index].id,
                            title: recitations[index].title,
                            audioUrl: recitations[index].audioUrl,
                            imageUrl: reader.imageUrl,
                            artistName: reader.name,
                          ),
                          playlist: recitations
                              .map(
                                (recitation) => AudioItem(
                                  id: recitation.id,
                                  title: recitation.title,
                                  audioUrl: recitation.audioUrl,
                                  imageUrl: reader.imageUrl,
                                  artistName: reader.name,
                                ),
                              )
                              .toList(),
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
                      tag: 'recitation_${recitations[index].id}_${reader.id}',
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
                      recitations[index].title,
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
        'استمع إلى ${reader.name} على تطبيق Zwamil\n'
        'عدد الزوامل: ${reader.recitations.length}';
    Share.share(text);
  }
}
