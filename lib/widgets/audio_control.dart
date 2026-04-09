import 'package:flutter/material.dart';
import 'package:love_gallery/services/audio_service.dart';

class AudioControl extends StatefulWidget {
  const AudioControl({super.key});

  @override
  State<AudioControl> createState() => _AudioControlState();
}

class _AudioControlState extends State<AudioControl> {
  final AudioService _audioService = AudioService();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isMuted = _audioService.isMuted;
    // Force a restart to ensure audio is playing
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    // Ensure audio is properly initialized when widget is created
    if (!_audioService.isMuted) {
      // Brief delay to ensure context is ready
      await Future.delayed(const Duration(milliseconds: 200));
      await _audioService.forceRestart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          // First update UI for immediate feedback
          setState(() {
            _isMuted = !_isMuted;
          });

          // Then toggle the actual audio state
          await _audioService.toggleMute();

          // Then check if the state was properly updated
          if (_isMuted != _audioService.isMuted) {
            // If there's a mismatch, log it and correct our UI
            debugPrint(
              'Mute state mismatch! Widget: $_isMuted, Service: ${_audioService.isMuted}',
            );
            setState(() {
              _isMuted = _audioService.isMuted;
            });
          }

          // Force a restart if unmuting to ensure audio plays
          if (!_isMuted) {
            await _audioService.forceRestart();
          }
        } catch (e) {
          debugPrint('Error toggling audio: $e');
          // Try the brute force approach if normal toggle fails
          await _audioService.forceRestart();
          setState(() {
            _isMuted = _audioService.isMuted;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _isMuted ? Icons.music_off : Icons.music_note,
          size: 20,
          color: _isMuted ? Colors.red[300] : Colors.white,
        ),
      ),
    );
  }
}
