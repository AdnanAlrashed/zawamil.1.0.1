class Song {
  final int? id;
  final String title;
  final String audioUrl;
  final int artistId;

  Song({
    this.id,
    required this.title,
    required this.audioUrl,
    required this.artistId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audio_url': audioUrl,
      'artist_id': artistId,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      audioUrl: map['audio_url'],
      artistId: map['artist_id'],
    );
  }
}
