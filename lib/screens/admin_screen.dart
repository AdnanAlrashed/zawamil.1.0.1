import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/admin_config.dart';
import '../services/notification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audio_file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _artistNameController = TextEditingController();
  final _artistImageController = TextEditingController();
  final _songTitleController = TextEditingController();
  final _songAudioController = TextEditingController();
  String? _selectedArtistId;
  String? _editingArtistId;
  String? _editingSongId;
  bool _isAuthenticated = false;

  List<Map<String, dynamic>> artists = [];
  List<Map<String, dynamic>> songs = [];
  List<String> artistIds = [];

  @override
  void initState() {
    super.initState();
    // تأخير فحص المصادقة حتى اكتمال تهيئة الـ widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() {
    // استخدام كلمة المرور من ملف الإعدادات
    const adminPassword = AdminConfig.adminPassword;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('الوصول للإدارة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل كلمة المرور للوصول لشاشة الإدارة:'),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value == adminPassword) {
                  Navigator.pop(context);
                  setState(() {
                    _isAuthenticated = true;
                  });
                  _loadArtists();
                  _loadSongs();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('كلمة مرور خاطئة')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadArtists() async {
    try {
      FirestoreService.getArtistsStream().listen((snapshot) {
        if (mounted) {
          setState(() {
            artists = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
            // ترتيب الفنانين حسب تاريخ الإنشاء (الأحدث أولاً)
            artists.sort((a, b) {
              final aCreated = a['created_at'] as Timestamp?;
              final bCreated = b['created_at'] as Timestamp?;
              if (aCreated == null && bCreated == null) return 0;
              if (aCreated == null) return 1;
              if (bCreated == null) return -1;
              return bCreated.compareTo(aCreated);
            });
            artistIds =
                artists.map((artist) => artist['id'].toString()).toList();
            // تعيين أول فنان تلقائياً إذا لم يكن محدداً
            if (_selectedArtistId == null && artists.isNotEmpty) {
              _selectedArtistId = artists.first['id'].toString();
            } else if (_selectedArtistId != null && artists.isNotEmpty) {
              // التحقق من أن الفنان المحدد لا يزال موجوداً
              final artistExists = artists.any(
                  (artist) => artist['id'].toString() == _selectedArtistId);
              if (!artistExists) {
                _selectedArtistId = artists.first['id'].toString();
              }
            }
          });
        }
      }, onError: (error) {
        print('Error loading artists: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل الفنانين: $error')),
          );
        }
      });
    } catch (e) {
      print('Error in _loadArtists: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الفنانين: $e')),
        );
      }
    }
  }

  Future<void> _loadSongs() async {
    try {
      // لا نعيد تعيين _selectedArtistId إذا كان محدداً بالفعل
      if (_selectedArtistId == null && artistIds.isNotEmpty) {
        _selectedArtistId = artistIds.first;
      }
      if (_selectedArtistId != null) {
        FirestoreService.getSongsByArtistStream(_selectedArtistId!).listen(
            (snapshot) {
          if (mounted) {
            setState(() {
              songs = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList();
              // ترتيب الزوامل حسب تاريخ الإنشاء (الأحدث أولاً)
              songs.sort((a, b) {
                final aCreated = a['created_at'] as Timestamp?;
                final bCreated = b['created_at'] as Timestamp?;
                if (aCreated == null && bCreated == null) return 0;
                if (aCreated == null) return 1;
                if (bCreated == null) return -1;
                return bCreated.compareTo(aCreated);
              });
            });
          }
        }, onError: (error) {
          print('Error loading songs: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في تحميل الزوامل: $error')),
            );
          }
        });
      }
    } catch (e) {
      print('Error in _loadSongs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الزوامل: $e')),
        );
      }
    }
  }

  Future<void> _addArtist() async {
    try {
      if (_artistNameController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى إدخال اسم الفنان')),
          );
        }
        return;
      }
      await FirestoreService.addArtist(
        name: _artistNameController.text,
        imageUrl: _artistImageController.text,
      );
      await NotificationService.showNewArtistNotification(
          _artistNameController.text);
      // إرسال إشعار جماعي تلقائيًا بعد إضافة الفنان
      await NotificationService.sendNotificationViaServer(
        title: '🎤 فنان جديد في التطبيق!',
        body:
            'تمت إضافة الفنان: ${_artistNameController.text}. اكتشف زوامله الآن!',
      );
      _clearArtistForm();
      // لا داعي لاستدعاء _loadArtists لأن stream سيحدث تلقائياً
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إضافة الفنان وإرسال الإشعار للمستخدمين')),
        );
      }
    } catch (e) {
      print('Error adding artist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إضافة الفنان: $e')),
        );
      }
    }
  }

  Future<void> _updateArtist() async {
    if (_artistNameController.text.isEmpty || _editingArtistId == null) return;
    await FirestoreService.updateArtist(
      artistId: _editingArtistId!,
      name: _artistNameController.text,
      imageUrl: _artistImageController.text,
    );
    _clearArtistForm();
    // لا داعي لاستدعاء _loadArtists لأن stream سيحدث تلقائياً
  }

  Future<void> _deleteArtist(String artistId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد من حذف هذا الفنان؟ سيتم حذف جميع زوامله أيضاً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // البحث عن الفنان لحذف صورته
        final artist =
            artists.firstWhere((a) => a['id'].toString() == artistId);
        final imageUrl = artist['image_url'] as String?;

        // حذف صورة الفنان إذا كانت موجودة
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final imageFile = File(imageUrl);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }

        // حذف جميع الملفات الصوتية للفنان
        final artistSongs =
            songs.where((s) => s['artist_id'].toString() == artistId).toList();
        for (final song in artistSongs) {
          final audioUrl = song['audio_url'] as String?;
          if (audioUrl != null && audioUrl.isNotEmpty) {
            await AudioFileService.deleteAudioFile(audioUrl);
          }
        }

        // حذف الفنان من Firestore (سيحذف الزوامل تلقائياً)
        await FirestoreService.deleteArtist(artistId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الفنان وجميع زوامله بنجاح')),
          );
        }
      } catch (e) {
        print('Error deleting artist: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف الفنان: $e')),
          );
        }
      }
    }
  }

  void _editArtist(Map<String, dynamic> artist) {
    setState(() {
      _editingArtistId = artist['id']?.toString();
      _artistNameController.text = artist['name'];
      _artistImageController.text = artist['image_url'] ?? '';
    });
  }

  void _clearArtistForm() {
    setState(() {
      _editingArtistId = null;
      _artistNameController.clear();
      _artistImageController.clear();
      // لا نعيد تعيين _selectedArtistId لتجنب إعادة تحميل القائمة
    });
  }

  Future<void> _addSong() async {
    try {
      if (_songTitleController.text.isEmpty || _selectedArtistId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
          );
        }
        return;
      }

      // التحقق من وجود الملف الصوتي
      if (_songAudioController.text.isNotEmpty) {
        final fileExists =
            await AudioFileService.audioFileExists(_songAudioController.text);
        if (!fileExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('الملف الصوتي غير موجود، يرجى اختيار ملف آخر')),
            );
          }
          return;
        }
      }

      final artist = artists.firstWhere(
        (a) => a['id'].toString() == _selectedArtistId,
        orElse: () => {'name': 'غير معروف'},
      );
      await FirestoreService.addSong(
        title: _songTitleController.text,
        audioUrl: _songAudioController.text,
        artistId: _selectedArtistId!,
      );
      await NotificationService.showNewSongNotification(
        _songTitleController.text,
        artist['name'],
      );
      // إرسال إشعار جماعي تلقائيًا بعد إضافة الزامل
      await NotificationService.sendNotificationViaServer(
        title: '🎵 زامل جديد متاح الآن!',
        body:
            'استمع الآن إلى "${_songTitleController.text}" بصوت الفنان: ${artist['name']}',
      );
      _clearSongForm();
      // لا داعي لاستدعاء _loadSongs لأن stream سيحدث تلقائياً
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إضافة الزامل وإرسال الإشعار للمستخدمين')),
        );
      }
    } catch (e) {
      print('Error adding song: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إضافة الزامل: $e')),
        );
      }
    }
  }

  Future<void> _updateSong() async {
    if (_songTitleController.text.isEmpty ||
        _editingSongId == null ||
        _selectedArtistId == null) {
      return;
    }
    await FirestoreService.updateSong(
      songId: _editingSongId.toString(),
      title: _songTitleController.text,
      audioUrl: _songAudioController.text,
      artistId: _selectedArtistId!,
    );
    _clearSongForm();
  }

  Future<void> _deleteSong(String songId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الزامل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // البحث عن الزامل لحذف الملف الصوتي
        final song = songs.firstWhere((s) => s['id'].toString() == songId);
        final audioUrl = song['audio_url'] as String?;

        // حذف الملف الصوتي إذا كان موجوداً
        if (audioUrl != null && audioUrl.isNotEmpty) {
          await AudioFileService.deleteAudioFile(audioUrl);
        }

        // حذف الزامل من Firestore
        await FirestoreService.deleteSong(songId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الزامل بنجاح')),
          );
        }
      } catch (e) {
        print('Error deleting song: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف الزامل: $e')),
          );
        }
      }
    }
  }

  void _editSong(Map<String, dynamic> song) {
    setState(() {
      _editingSongId = song['id']?.toString();
      _selectedArtistId = song['artist_id']?.toString();
      _songTitleController.text = song['title'];
      _songAudioController.text = song['audio_url'];
    });
  }

  void _clearSongForm() {
    setState(() {
      _editingSongId = null;
      _songTitleController.clear();
      _songAudioController.clear();
      // لا نعيد تعيين _selectedArtistId لتجنب إعادة تحميل القائمة
    });
  }

  Future<void> _pickArtistImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        // نسخ الصورة إلى مكان دائم
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/artist_images');

        // إنشاء مجلد الصور إذا لم يكن موجوداً
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        // إنشاء اسم فريد للصورة
        final fileName = path.basename(picked.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName =
            '${timestamp}_${fileName.replaceAll(RegExp(r'[^\w\s-]'), '_')}';
        final destinationPath = '${imagesDir.path}/$uniqueFileName';

        // نسخ الصورة
        final sourceFile = File(picked.path);
        await sourceFile.copy(destinationPath);

        setState(() {
          _artistImageController.text = destinationPath;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم اختيار صورة الفنان بنجاح')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _pickSongAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;

        // نسخ الملف إلى مكان دائم
        final permanentPath =
            await AudioFileService.copyAudioFileToPermanentLocation(sourcePath);

        setState(() {
          _songAudioController.text = permanentPath;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم اختيار الملف الصوتي بنجاح')),
          );
        }
      }
    } catch (e) {
      print('Error picking audio file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الملف: $e')),
        );
      }
    }
  }

  Future<void> _cleanOldData() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تنظيف البيانات القديمة'),
          content: const Text(
              'سيتم حذف جميع الزوامل التي تحتوي على مسارات ملفات قديمة. هل أنت متأكد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('تنظيف', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await FirestoreService.updateOldAudioPaths();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تنظيف البيانات القديمة بنجاح')),
          );
        }
      }
    } catch (e) {
      print('Error cleaning old data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تنظيف البيانات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الوصول للإدارة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingArtistId != null ? 'تعديل الفنان' : 'إضافة فنان جديد',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _artistNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الفنان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _artistImageController,
                    decoration: const InputDecoration(
                      labelText: 'مسار الصورة',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickArtistImage,
                ),
                if (_artistImageController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Builder(
                      builder: (context) {
                        final imageFile = File(_artistImageController.text);
                        if (imageFile.existsSync()) {
                          return Image.file(
                            imageFile,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const Icon(Icons.image, size: 40);
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed:
                      _editingArtistId != null ? _updateArtist : _addArtist,
                  child: Text(_editingArtistId != null
                      ? 'تحديث الفنان'
                      : 'إضافة الفنان'),
                ),
                if (_editingArtistId != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearArtistForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('إلغاء التعديل'),
                  ),
                ],
              ],
            ),
            const Divider(height: 32),
            Text(
              _editingSongId != null ? 'تعديل الزامل' : 'إضافة زامل جديد',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedArtistId,
              items: artists.map((artist) {
                return DropdownMenuItem<String>(
                  value: artist['id'].toString(),
                  child: Text(artist['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedArtistId = val),
              decoration: const InputDecoration(
                labelText: 'اختر الفنان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _songTitleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الزامل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _songAudioController,
                    decoration: const InputDecoration(
                      labelText: 'مسار الملف الصوتي',
                      hintText: 'اختر ملف صوتي من الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.audiotrack),
                  onPressed: _pickSongAudio,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _editingSongId != null ? _updateSong : _addSong,
                  child: Text(
                      _editingSongId != null ? 'تحديث الزامل' : 'إضافة الزامل'),
                ),
                if (_editingSongId != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearSongForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('إلغاء التعديل'),
                  ),
                ],
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الفنانون الحاليون:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton(
                  onPressed: _cleanOldData,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('تنظيف البيانات القديمة'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...artists.map((artist) => Card(
                  child: ListTile(
                    leading: artist['image_url'] != null &&
                            artist['image_url'].toString().isNotEmpty
                        ? Builder(
                            builder: (context) {
                              final imageFile = File(artist['image_url']);
                              if (imageFile.existsSync()) {
                                return Image.file(
                                  imageFile,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Icon(Icons.person, size: 40);
                              }
                            },
                          )
                        : const Icon(Icons.person),
                    title: Text(artist['name'] ?? ''),
                    subtitle: Text(artist['image_url'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editArtist(artist),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteArtist(artist['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                )),
            const Divider(height: 32),
            const Text('الزوامل المضافة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: FirestoreService.getSongsByArtistStream(
                  _selectedArtistId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    (snapshot.data as dynamic).docs.isEmpty) {
                  return const Text('لا يوجد زوامل مضافة حالياً');
                }
                final docs = (snapshot.data as dynamic).docs;
                final songs = docs.map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  return data;
                }).toList();
                return Column(
                  children: songs.map<Widget>((song) {
                    final artist = artists.firstWhere(
                      (a) => a['id'] == song['artist_id'],
                      orElse: () => {'name': 'غير معروف'},
                    );
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(song['title'] ?? ''),
                        subtitle: Text('الفنان: ${artist['name']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editSong(song),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteSong(song['id'].toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
