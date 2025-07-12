import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

// نموذج مشترك لكلا النوعين (أغاني وتلاوات)
class AudioItem {
  final String id;
  final String title;
  final String audioUrl;
  final String? imageUrl;
  final String artistName;

  AudioItem({
    required this.id,
    required this.title,
    required this.audioUrl,
    this.imageUrl,
    required this.artistName,
  });
}

class MusicPlayerScreen extends StatefulWidget {
  final AudioItem audioItem;
  final List<AudioItem>? playlist; // قائمة تشغيل اختيارية

  const MusicPlayerScreen({required this.audioItem, this.playlist});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = 0;
  List<AudioItem> _playlist = [];
  bool _initError = false;
  String? _initErrorMessage;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist ?? [widget.audioItem];
    _currentIndex = _findCurrentIndex();
    if (_playlist.isNotEmpty) {
      _initAudio();
      _setupAudioPlayer();
    } else {
      _showErrorSnackbar('لا توجد عناصر صوتية متاحة');
    }
  }

  int _findCurrentIndex() {
    final index = _playlist.indexOf(widget.audioItem);
    return index >= 0 ? index : 0; // العودة إلى 0 إذا لم يتم العثور على العنصر
  }

  Future<void> _playItem(int index) async {
    if (index < 0 || index >= _playlist.length) {
      _showErrorSnackbar('عنصر غير صالح');
      return;
    }

    try {
      setState(() {
        _currentIndex = index;
        _isBuffering = true;
        _position = Duration.zero;
      });

      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource(_playlist[index].audioUrl));
      await _audioPlayer.play(AssetSource(_playlist[index].audioUrl));
    } catch (e) {
      debugPrint('Play item error: $e');
      _showErrorSnackbar('حدث خطأ أثناء تشغيل العنصر');
      if (mounted) {
        setState(() => _isBuffering = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initError && mounted) {
      _showErrorSnackbar(_initErrorMessage ?? 'حدث خطأ في بدء التشغيل');
      _initError = false;
    }
  }

  Future<void> _initAudio() async {
    try {
      setState(() => _isBuffering = true);
      await _audioPlayer.setSource(
        AssetSource(_playlist[_currentIndex].audioUrl),
      );
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint('Audio initialization error: $e');
      _initError = true;
      _initErrorMessage = 'حدث خطأ في بدء التشغيل: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() => _isBuffering = false);
      }
    }
  }

  void _setupAudioPlayer() {
    _subscriptions.addAll([
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isBuffering = state == PlayerState.playing ? false : _isBuffering;
        });
      }),
      _audioPlayer.onDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() => _duration = duration);
      }),
      _audioPlayer.onPositionChanged.listen((position) {
        if (!mounted) return;
        setState(() => _position = position);
      }),
      _audioPlayer.onPlayerComplete.listen((_) {
        _handleSongCompletion();
      }),
    ]);
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position.inMilliseconds == 0 || _position == _duration) {
          await _audioPlayer.play(
            AssetSource(_playlist[_currentIndex].audioUrl),
          );
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint('Play/pause error: $e');
      _showErrorSnackbar('حدث خطأ أثناء التشغيل');
    }
  }

  Future<void> _toggleLoop() async {
    try {
      await _audioPlayer.setReleaseMode(
        _isLooping ? ReleaseMode.release : ReleaseMode.loop,
      );
      setState(() => _isLooping = !_isLooping);
    } catch (e) {
      debugPrint('Loop toggle error: $e');
      _showErrorSnackbar('حدث خطأ في تكرار التشغيل');
    }
  }

  Future<void> _skipForward() async {
    try {
      final newPosition = _position + Duration(seconds: 10);
      if (newPosition < _duration) {
        await _audioPlayer.seek(newPosition);
      } else {
        await _audioPlayer.seek(_duration);
      }
    } catch (e) {
      debugPrint('Skip forward error: $e');
      _showErrorSnackbar('حدث خطأ في التخطي للأمام');
    }
  }

  Future<void> _skipBackward() async {
    try {
      final newPosition = _position - Duration(seconds: 10);
      if (newPosition > Duration.zero) {
        await _audioPlayer.seek(newPosition);
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    } catch (e) {
      debugPrint('Skip backward error: $e');
      _showErrorSnackbar('حدث خطأ في التخطي للخلف');
    }
  }

  Future<void> _playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await _playItem(_currentIndex + 1);
    } else {
      await _playItem(0); // العودة إلى أول عنصر في القائمة
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex > 0) {
      await _playItem(_currentIndex - 1);
    } else {
      await _playItem(_playlist.length - 1); // الانتقال إلى آخر عنصر في القائمة
    }
  }

  void _handleSongCompletion() {
    if (!mounted) return;
    setState(() {
      _position = Duration.zero;
      _isPlaying = false;
    });
    if (_isLooping) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.resume();
    } else if (_playlist.length > 1) {
      _playNext(); // تشغيل العنصر التالي تلقائياً إذا كانت هناك قائمة تشغيل
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentItem = _playlist[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('المشغل'),
        actions: [
          IconButton(
            icon: Icon(_isLooping ? Icons.repeat_one : Icons.repeat),
            onPressed: _toggleLoop,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [Colors.grey.shade900, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'audio_item_${currentItem.id}',
                child: CircleAvatar(
                  radius: 120,
                  backgroundImage:
                      currentItem.imageUrl != null &&
                          currentItem.imageUrl!.isNotEmpty
                      ? AssetImage(currentItem.imageUrl!) as ImageProvider
                      : null,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child:
                      currentItem.imageUrl == null ||
                          currentItem.imageUrl!.isEmpty
                      ? Icon(
                          Icons.music_note,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 24),
              Text(
                currentItem.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                currentItem.artistName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 32),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          _formatTime(_position),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blueAccent,
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: Colors.blue,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                            ),
                            child: Slider(
                              min: 0,
                              max: _duration.inMilliseconds.toDouble(),
                              value: _position.inMilliseconds.toDouble().clamp(
                                0,
                                _duration.inMilliseconds.toDouble(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _position = Duration(
                                    milliseconds: value.toInt(),
                                  );
                                });
                              },
                              onChangeEnd: (value) async {
                                await _audioPlayer.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(_duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.onPositionChanged,
                    builder: (context, snapshot) {
                      final bufferedPosition = snapshot.data ?? Duration.zero;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LinearProgressIndicator(
                          value:
                              bufferedPosition.inMilliseconds /
                              _duration.inMilliseconds.clamp(
                                1,
                                double.maxFinite,
                              ),
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
                          minHeight: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_10, size: 32),
                    onPressed: _skipBackward,
                  ),
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 56,
                      color: Colors.blue,
                    ),
                    onPressed: _togglePlay,
                  ),
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(Icons.forward_10, size: 32),
                    onPressed: _skipForward,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isLooping ? Icons.repeat_one : Icons.repeat,
                      color: _isLooping ? Colors.blue : Colors.grey[700],
                    ),
                    onPressed: _toggleLoop,
                  ),
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 32),
                    onPressed: _playPrevious,
                  ),
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 32),
                    onPressed: _playNext,
                  ),
                ],
              ),
              if (_isBuffering)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
