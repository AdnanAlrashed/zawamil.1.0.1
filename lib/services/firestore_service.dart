import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== Artists ==========
  static Future<void> addArtist(
      {required String name, String? imageUrl}) async {
    await _db.collection('artists').add({
      'name': name,
      'image_url': imageUrl ?? '',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getArtistsStream() {
    try {
      return _db.collection('artists').snapshots();
    } catch (e) {
      print('Error getting artists stream: $e');
      rethrow;
    }
  }

  static Future<void> deleteArtist(String artistId) async {
    await _db.collection('artists').doc(artistId).delete();
    // حذف كل الزوامل المرتبطة بالفنان
    final songs = await _db
        .collection('songs')
        .where('artist_id', isEqualTo: artistId)
        .get();
    for (var doc in songs.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> updateArtist(
      {required String artistId,
      required String name,
      String? imageUrl}) async {
    await _db.collection('artists').doc(artistId).update({
      'name': name,
      'image_url': imageUrl ?? '',
    });
  }

  // ========== Songs ==========
  static Future<void> addSong(
      {required String title,
      required String audioUrl,
      required String artistId}) async {
    await _db.collection('songs').add({
      'title': title,
      'audio_url': audioUrl,
      'artist_id': artistId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getSongsByArtistStream(
      String artistId) {
    try {
      return _db
          .collection('songs')
          .where('artist_id', isEqualTo: artistId)
          .snapshots();
    } catch (e) {
      print('Error getting songs stream: $e');
      rethrow;
    }
  }

  static Future<void> deleteSong(String songId) async {
    await _db.collection('songs').doc(songId).delete();
  }

  static Future<void> updateSong(
      {required String songId,
      required String title,
      required String audioUrl,
      required String artistId}) async {
    await _db.collection('songs').doc(songId).update({
      'title': title,
      'audio_url': audioUrl,
      'artist_id': artistId,
    });
  }

  // ========== Utility Functions ==========

  // دالة لتحديث مسارات الملفات الصوتية القديمة
  static Future<void> updateOldAudioPaths() async {
    try {
      final songsSnapshot = await _db.collection('songs').get();

      for (var doc in songsSnapshot.docs) {
        final data = doc.data();
        final audioUrl = data['audio_url'] as String?;

        if (audioUrl != null && audioUrl.isNotEmpty) {
          // التحقق من أن المسار هو مسار مؤقت قديم
          if (audioUrl.contains('/cache/file_picker/') ||
              audioUrl.contains('زامل_')) {
            print('Found old audio path: $audioUrl');

            // حذف الزامل لأن الملف الصوتي غير موجود
            await doc.reference.delete();
            print('Deleted song with old audio path: ${data['title']}');
          }
        }
      }

      print('Finished updating old audio paths');
    } catch (e) {
      print('Error updating old audio paths: $e');
    }
  }

  // دالة لحذف جميع البيانات (للتطوير فقط)
  static Future<void> clearAllData() async {
    try {
      // حذف جميع الزوامل
      final songsSnapshot = await _db.collection('songs').get();
      for (var doc in songsSnapshot.docs) {
        await doc.reference.delete();
      }

      // حذف جميع الفنانين
      final artistsSnapshot = await _db.collection('artists').get();
      for (var doc in artistsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
