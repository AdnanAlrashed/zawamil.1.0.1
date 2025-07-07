class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final List<Song> songs; // الآن كل فنان يحمل قائمة أغانيه مباشرة

  Artist({
    required this.id,
    required this.name,
    this.imageUrl = '', // جعل الصورة اختيارية
    required this.songs, // أصبح إجباري
  });
}

class Song {
  final String id;
  final String title;
  final String audioUrl;

  Song({required this.id, required this.title, required this.audioUrl});
}
