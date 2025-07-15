class Artist {
  final String? id;
  final String name;
  final String imageUrl;
  final int songCount;

  Artist({
    this.id,
    required this.name,
    required this.imageUrl,
    this.songCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'song_count': songCount,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id']?.toString(),
      name: map['name'],
      imageUrl: map['image_url'],
      songCount: map['song_count'] ?? 0,
    );
  }
}
