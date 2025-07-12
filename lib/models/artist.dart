import '../models/song.dart';

class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final List<Song> songs;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.songs,
  });
}
