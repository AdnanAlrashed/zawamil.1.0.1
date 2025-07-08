class Reader {
  final String id;
  final String name;
  final String imageUrl;
  final List<Recitation> recitations; // الآن كل فنان يحمل قائمة أغانيه مباشرة

  Reader({
    required this.id,
    required this.name,
    this.imageUrl = '', // جعل الصورة اختيارية
    required this.recitations, // أصبح إجباري
  });
}

class Recitation {
  final String id;
  final String title;
  final String audioUrl;

  Recitation({required this.id, required this.title, required this.audioUrl});
}
