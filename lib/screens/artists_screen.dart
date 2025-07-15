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
import '../services/firestore_service.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفنانين'),
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
      body: StreamBuilder(
        stream: FirestoreService.getArtistsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as dynamic).docs.isEmpty) {
            return const Center(
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
            );
          }
          final docs = (snapshot.data as dynamic).docs;
          final artists = docs.map<Artist>((doc) {
            final data = doc.data();
            return Artist(
              id: doc.id,
              name: data['name'] ?? '',
              imageUrl: data['image_url'] ?? '',
              songCount: 0, // سيتم حسابها لاحقاً إذا لزم الأمر
            );
          }).toList();
          return Padding(
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistSongsScreen(
                            artist: artists[index],
                            songs: const [],
                          ),
                        ),
                      );
                    },
                    child: FutureBuilder<int>(
                      future: FirestoreService.getSongsByArtistStream(
                              artists[index].id!)
                          .first
                          .then((snapshot) => snapshot.docs.length),
                      builder: (context, snapshot) {
                        final songCount = snapshot.data ?? 0;
                        return ListTile(
                          leading: artists[index].imageUrl.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      FileImage(File(artists[index].imageUrl)),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                          title: Text(artists[index].name),
                          subtitle: Text('عدد الزوامل: $songCount'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
