import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class AudioFileService {
  static Future<String> copyAudioFileToPermanentLocation(
      String sourcePath) async {
    try {
      // الحصول على مجلد التطبيق الدائم
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDir.path}/audio_files');

      // إنشاء مجلد الملفات الصوتية إذا لم يكن موجوداً
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // إنشاء اسم فريد للملف
      final fileName = path.basename(sourcePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName =
          '${timestamp}_${fileName.replaceAll(RegExp(r'[^\w\s-]'), '_')}';
      final destinationPath = '${audioDir.path}/$uniqueFileName';

      // نسخ الملف
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        print('Audio file copied to: $destinationPath');
        return destinationPath;
      } else {
        throw Exception('Source file does not exist: $sourcePath');
      }
    } catch (e) {
      print('Error copying audio file: $e');
      rethrow;
    }
  }

  static Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Audio file deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting audio file: $e');
      return false;
    }
  }

  static Future<bool> audioFileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking audio file existence: $e');
      return false;
    }
  }

  static Future<String> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/audio_files';
  }

  static Future<String> downloadAudioFile(String url, String fileName) async {
    try {
      final audioDir = Directory(await getAudioDirectory());
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final filePath = '${audioDir.path}/$fileName';
      final file = File(filePath);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('Audio file downloaded to: $filePath');
        return filePath;
      } else {
        throw Exception(
            'Failed to download audio file: \\${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading audio file: $e');
      rethrow;
    }
  }
}
