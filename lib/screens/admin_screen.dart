import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/admin_config.dart';
import '../services/notification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  int? _selectedArtistId;
  int? _editingArtistId;
  int? _editingSongId;
  bool _isAuthenticated = false;

  List<Map<String, dynamic>> artists = [];
  List<Map<String, dynamic>> songs = [];

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
        title: Text('الوصول للإدارة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل كلمة المرور للوصول لشاشة الإدارة:'),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
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
                      SnackBar(content: Text('كلمة مرور خاطئة')),
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
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadArtists() async {
    final data = await DatabaseHelper.instance.getAllArtists();
    setState(() {
      artists = data;
    });
  }

  Future<void> _loadSongs() async {
    final data = await DatabaseHelper.instance.getAllSongs();
    setState(() {
      songs = data;
    });
  }

  Future<void> _addArtist() async {
    if (_artistNameController.text.isEmpty) return;
    await DatabaseHelper.instance.createArtist({
      'name': _artistNameController.text,
      'image_url': _artistImageController.text,
    });

    // إرسال إشعار للمستخدمين
    await NotificationService.showNewArtistNotification(
        _artistNameController.text);

    _clearArtistForm();
    _loadArtists();

    // رسالة تأكيد للمدير
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة الفنان وإرسال الإشعار للمستخدمين')),
      );
    }
  }

  Future<void> _updateArtist() async {
    if (_artistNameController.text.isEmpty || _editingArtistId == null) return;
    await DatabaseHelper.instance.updateArtist({
      'id': _editingArtistId,
      'name': _artistNameController.text,
      'image_url': _artistImageController.text,
    });
    _clearArtistForm();
    _loadArtists();
  }

  Future<void> _deleteArtist(int artistId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content:
            Text('هل أنت متأكد من حذف هذا الفنان؟ سيتم حذف جميع زوامله أيضاً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteArtist(artistId);
      _loadArtists();
      _loadSongs();
    }
  }

  void _editArtist(Map<String, dynamic> artist) {
    setState(() {
      _editingArtistId = artist['id'];
      _artistNameController.text = artist['name'];
      _artistImageController.text = artist['image_url'] ?? '';
    });
  }

  void _clearArtistForm() {
    setState(() {
      _editingArtistId = null;
      _artistNameController.clear();
      _artistImageController.clear();
    });
  }

  Future<void> _addSong() async {
    if (_songTitleController.text.isEmpty || _selectedArtistId == null) return;

    // الحصول على اسم الفنان
    final artist = artists.firstWhere(
      (a) => a['id'] == _selectedArtistId,
      orElse: () => {'name': 'غير معروف'},
    );

    await DatabaseHelper.instance.createSong({
      'title': _songTitleController.text,
      'audio_url': _songAudioController.text,
      'artist_id': _selectedArtistId,
    });

    // إرسال إشعار للمستخدمين
    await NotificationService.showNewSongNotification(
      _songTitleController.text,
      artist['name'],
    );

    _clearSongForm();
    _loadSongs();

    // رسالة تأكيد للمدير
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة الزامل وإرسال الإشعار للمستخدمين')),
      );
    }
  }

  Future<void> _updateSong() async {
    if (_songTitleController.text.isEmpty ||
        _editingSongId == null ||
        _selectedArtistId == null) return;
    await DatabaseHelper.instance.updateSong({
      'id': _editingSongId,
      'title': _songTitleController.text,
      'audio_url': _songAudioController.text,
      'artist_id': _selectedArtistId,
    });
    _clearSongForm();
    _loadSongs();
  }

  Future<void> _deleteSong(int songId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا الزامل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteSong(songId);
      _loadSongs();
    }
  }

  void _editSong(Map<String, dynamic> song) {
    setState(() {
      _editingSongId = song['id'];
      _selectedArtistId = song['artist_id'];
      _songTitleController.text = song['title'];
      _songAudioController.text = song['audio_url'];
    });
  }

  void _clearSongForm() {
    setState(() {
      _editingSongId = null;
      _songTitleController.clear();
      _songAudioController.clear();
    });
  }

  Future<void> _pickArtistImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _artistImageController.text = picked.path;
      });
    }
  }

  Future<void> _pickSongAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _songAudioController.text = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الملف: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('الوصول للإدارة'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة الإدارة'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingArtistId != null ? 'تعديل الفنان' : 'إضافة فنان جديد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _artistNameController,
              decoration: InputDecoration(
                labelText: 'اسم الفنان',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _artistImageController,
                    decoration: InputDecoration(
                      labelText: 'مسار الصورة',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickArtistImage,
                ),
                if (_artistImageController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.file(
                      File(_artistImageController.text),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
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
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearArtistForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text('إلغاء التعديل'),
                  ),
                ],
              ],
            ),
            Divider(height: 32),
            Text(
              _editingSongId != null ? 'تعديل الزامل' : 'إضافة زامل جديد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedArtistId,
              items: artists.map((artist) {
                return DropdownMenuItem<int>(
                  value: artist['id'],
                  child: Text(artist['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedArtistId = val),
              decoration: InputDecoration(
                labelText: 'اختر الفنان',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _songTitleController,
              decoration: InputDecoration(
                labelText: 'عنوان الزامل',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _songAudioController,
                    decoration: InputDecoration(
                      labelText: 'مسار الملف الصوتي',
                      hintText: 'اختر ملف صوتي من الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.audiotrack),
                  onPressed: _pickSongAudio,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _editingSongId != null ? _updateSong : _addSong,
                  child: Text(
                      _editingSongId != null ? 'تحديث الزامل' : 'إضافة الزامل'),
                ),
                if (_editingSongId != null) ...[
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearSongForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text('إلغاء التعديل'),
                  ),
                ],
              ],
            ),
            Divider(height: 32),
            Text('الفنانون الحاليون:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            ...artists.map((artist) => Card(
                  child: ListTile(
                    leading: artist['image_url'] != null &&
                            artist['image_url'].toString().isNotEmpty
                        ? Image.file(
                            File(artist['image_url']),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person),
                    title: Text(artist['name'] ?? ''),
                    subtitle: Text(artist['image_url'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editArtist(artist),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteArtist(artist['id']),
                        ),
                      ],
                    ),
                  ),
                )),
            Divider(height: 32),
            Text('الزوامل المضافة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            ...songs.map((song) {
              final artist = artists.firstWhere(
                (a) => a['id'] == song['artist_id'],
                orElse: () => {'name': 'غير معروف'},
              );
              return Card(
                child: ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text(song['title'] ?? ''),
                  subtitle: Text('الفنان: ${artist['name']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editSong(song),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSong(song['id']),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
