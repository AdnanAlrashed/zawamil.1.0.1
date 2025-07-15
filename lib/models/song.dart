class Song {
  final String? id;
  final String title;
  final String artistId;
  final String audioUrl;

  Song({
    this.id,
    required this.title,
    required this.artistId,
    required this.audioUrl,
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
      id: map['id']?.toString(),
      title: map['title'],
      audioUrl: map['audio_url'],
      artistId: map['artist_id']?.toString() ?? '',
    );
  }

  factory Song.fromFirestore(Map<String, dynamic> data, String? id) {
    return Song(
      id: id,
      title: data['title'],
      artistId: data['artistId'],
      audioUrl: data['audioUrl'] ?? '',
    );
  }
}
