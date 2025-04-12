import 'package:flutter/material.dart';
import 'package:love_gallery/core/models/whisper.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class WhisperScreen extends StatefulWidget {
  const WhisperScreen({super.key});

  @override
  State<WhisperScreen> createState() => _WhisperScreenState();
}

class _WhisperScreenState extends State<WhisperScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _selectedWhisperIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  late PageController _pageController;
  late Future<List<Whisper>> _whispersFuture;
  final AudioService _audioService = AudioService();
  final DataRepository _repository = getDataRepository();
  final AudioPlayer _whisperPlayer = AudioPlayer();

  // Cache for downloaded files
  final Map<String, String> _audioFileCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedWhisperIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _whispersFuture = _repository.getWhispers();
    _isLoading = false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _whisperPlayer.dispose();
    // Resume background music when leaving this screen
    if (_isPlaying) {
      _audioService.resume();
    }
    super.dispose();
  }

  Future<void> _playWhisperAudio(String audioPath) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Check if we already have the file cached
      String localPath = _audioFileCache[audioPath] ?? '';

      // If not in cache, download it
      if (localPath.isEmpty) {
        localPath = await _downloadAudioFile(audioPath);

        // If download failed, show error and return
        if (localPath.isEmpty) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not download audio. Please check your internet connection.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
          _audioService.resume();
          return;
        }

        // Add to cache
        _audioFileCache[audioPath] = localPath;
      }

      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });

      // Play from local file
      final file = File(localPath);
      if (await file.exists()) {
        await _whisperPlayer.setFilePath(localPath);
        await _whisperPlayer.play();

        // Listen for audio completion to reset the play state
        _whisperPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
              _audioService.resume();
            });
          }
        });
      } else {
        // File doesn't exist - clear from cache and show error
        _audioFileCache.remove(audioPath);
        setState(() {
          _isPlaying = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio file not found. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
        _audioService.resume();
      }
    } catch (e) {
      debugPrint('Error playing whisper audio: $e');
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      _audioService.resume();
    }
  }

  Future<String> _downloadAudioFile(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = url.split('/').last.split('?').first;
      final filePath = '${directory.path}/whispers_$filename';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // If not, download it
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        debugPrint('Failed to download file: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      debugPrint('Error downloading audio file: $e');
      return '';
    }
  }

  Future<void> _stopWhisperAudio() async {
    try {
      await _whisperPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping whisper audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.blushPink,
      appBar: AppBar(
        title: const Text('Whisper Corner'),
        backgroundColor: AppTheme.petalPink,
      ),
      body: FutureBuilder<List<Whisper>>(
        future: _whispersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No whispers found.'));
          }

          final whispers = snapshot.data!;

          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  AppTheme.blushPink,
                  AppTheme.petalPink.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: whispers.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedWhisperIndex = index;
                        if (_isPlaying) {
                          _isPlaying = false;
                          _stopWhisperAudio();
                          _audioService.resume();
                        }
                      });
                    },
                    itemBuilder: (context, index) {
                      final whisper = whispers[index];
                      return Column(
                        children: [
                          Text(
                            whisper.title,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(color: AppTheme.dustyMauve),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          _buildAudioPlayer(whisper),
                          const SizedBox(height: 40),
                          if (whisper.transcript != null)
                            _buildTranscript(context, whisper),
                        ],
                      );
                    },
                  ),
                ),
                _buildWhisperSelector(whispers),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioPlayer(Whisper whisper) {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return; // Prevent multiple taps while loading

        setState(() {
          _isPlaying = !_isPlaying;

          // Pause background music when whisper is playing
          if (_isPlaying) {
            _audioService.pause();
            _playWhisperAudio(whisper.audioPath);
          } else {
            _stopWhisperAudio();
            _audioService.resume();
          }
        });
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldWash.withValues(alpha: 0.2),
                border: Border.all(color: AppTheme.goldWash, width: 2),
                boxShadow:
                    _isPlaying
                        ? [
                          BoxShadow(
                            color: AppTheme.goldWash.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ]
                        : [],
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.dustyMauve,
                        ),
                      )
                      : Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 60,
                        color: AppTheme.dustyMauve,
                      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranscript(BuildContext context, Whisper whisper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.roseQuartz, width: 1),
        ),
        child: Column(
          children: [
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              whisper.transcript!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhisperSelector(List<Whisper> whispers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        whispers.length,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              _selectedWhisperIndex = index;
              _isPlaying = false;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          child: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _selectedWhisperIndex == index
                      ? AppTheme.dustyMauve
                      : AppTheme.petalPink,
              border: Border.all(color: AppTheme.dustyMauve, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
