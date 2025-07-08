import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../models/artist.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Song song;
  final Artist artist;

  const MusicPlayerScreen({required this.song, required this.artist});

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

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _initAudio();
    _setupAudioPlayer();
  }

  Future<void> _initAudio() async {
    try {
      setState(() => _isBuffering = true);
      await _audioPlayer.setSource(AssetSource(widget.song.audioUrl));
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint('Audio initialization error: $e');
      _showErrorSnackbar('حدث خطأ في بدء التشغيل: ${e.toString()}');
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
          await _audioPlayer.play(AssetSource(widget.song.audioUrl));
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

  void _handleSongCompletion() {
    if (!mounted) return;
    setState(() {
      _position = Duration.zero;
      _isPlaying = false;
    });
    if (_isLooping) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.resume();
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تشغيل الزامل'),
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
                tag: 'song_${widget.song.id}_${widget.artist.id}',
                child: CircleAvatar(
                  radius: 120,
                  backgroundImage: widget.artist.imageUrl.isNotEmpty
                      ? AssetImage(widget.artist.imageUrl) as ImageProvider
                      : null,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: widget.artist.imageUrl.isEmpty
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
                widget.song.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.artist.name,
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
                    onPressed: () {},
                  ),
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 32),
                    onPressed: () {},
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
