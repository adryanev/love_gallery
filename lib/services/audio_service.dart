import 'package:just_audio/just_audio.dart';
import 'package:love_gallery/core/services/logging_service.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  AudioPlayer _player = AudioPlayer();
  // Add multiple players for louder volume if needed
  final List<AudioPlayer> _auxiliaryPlayers = [];
  bool _isMuted = false;
  static const String _audioAsset = 'assets/audio/midnight_letter.mp3';
  static const double _defaultVolume = 0.5;
  late final LoggingService _logger;
  bool _isInitialized = false;
  Timer? _volumeEnforceTimer;
  // Flag for extra loud mode if normal volume doesn't work
  bool _useExtraLoudMode = false;

  // Private constructor
  AudioService._internal() {
    _logger = getLogger();
    _addPlayerListeners();
  }

  // Singleton factory
  factory AudioService() {
    return _instance;
  }

  // Initialize the audio service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing AudioService');

      final success = await _loadAudioAsset();
      if (!success) {
        _logger.e('Failed to initialize audio service - asset loading failed');
        return;
      }

      await _configurePlayer();

      // Always start with audio unmuted
      _isMuted = false;
      _isInitialized = true;
      _logger.d('Audio initialized with mute state: $_isMuted');

      // Verify audio playback capability
      final volumeWorking = await _verifyAudioPlayback();

      // If volume is still stuck at a low level, switch to extra loud mode
      if (!volumeWorking) {
        _logger.w(
          'Normal volume control not working, switching to extra loud mode',
        );
        _useExtraLoudMode = true;
        await _setupExtraLoudMode();
      }

      _logger.i('AudioService initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Error initializing audio: ${e.toString()}', e, stackTrace);
      _isInitialized = false;
      throw Exception('AudioService initialization failed: $e');
    }
  }

  Future<void> _setupExtraLoudMode() async {
    _logger.d('Setting up extra loud mode with higher volume');

    // Create additional players as backups but don't use them simultaneously
    for (int i = 0; i < 2; i++) {
      try {
        final player = AudioPlayer();
        await player.setAsset(_audioAsset);
        await player.setLoopMode(LoopMode.all);
        await player.setVolume(_defaultVolume);
        _auxiliaryPlayers.add(player);
        _logger.d('Created auxiliary player #${i + 1}');
      } catch (e, stack) {
        _logger.e('Error creating auxiliary player', e, stack);
      }
    }

    _logger.d(
      'Extra loud mode setup complete with ${_auxiliaryPlayers.length} auxiliary players (will only use one player at a time)',
    );
  }

  Future<bool> _loadAudioAsset() async {
    try {
      _logger.d('Attempting to load audio asset: $_audioAsset');
      // Check if asset exists
      await _player.setAsset(_audioAsset);

      // Verify duration is valid
      final duration = _player.duration;
      if (duration != null && duration.inMilliseconds <= 0) {
        _logger.e('Audio asset loaded but has invalid duration: $duration');
        return false;
      }

      _logger.d(
        'Audio asset loaded successfully: $_audioAsset, duration: $duration',
      );
      return true;
    } catch (assetError, assetStack) {
      _logger.e(
        'Failed to load audio asset: ${assetError.toString()}',
        assetError,
        assetStack,
      );
      _logger.w('Continuing without audio due to asset loading error');
      return false;
    }
  }

  Future<void> _configurePlayer() async {
    try {
      await _player.setLoopMode(LoopMode.all);
      _logger.d('Loop mode set to: ${_player.loopMode}');
    } catch (e, stack) {
      _logger.e('Error setting loop mode', e, stack);
    }

    // Start a timer to periodically enforce volume
    _startVolumeEnforcer();
  }

  // Periodically enforce the correct volume
  void _startVolumeEnforcer() {
    _volumeEnforceTimer?.cancel();
    _volumeEnforceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_player.playing && !_isMuted) {
        _logger.v('Volume enforcer checking volume: ${_player.volume}');
        if (_player.volume < _defaultVolume - 0.05) {
          _logger.d(
            'Volume enforcer correcting volume from ${_player.volume} to $_defaultVolume',
          );
          _forceSetVolume(_defaultVolume);
        }
      }
    });
  }

  Future<bool> _verifyAudioPlayback() async {
    try {
      _logger.d('Verifying audio playback capability');

      // Try setting various volumes to see what works
      final volumeLevels = [0.1, 0.3, 0.5, 0.8, 1.0];
      bool volumeChangesWork = false;

      for (final testVolume in volumeLevels) {
        await _player.setVolume(testVolume);
        await Future.delayed(const Duration(milliseconds: 100));
        final actualVolume = _player.volume;
        _logger.d('Volume test - target: $testVolume, actual: $actualVolume');

        if ((actualVolume - testVolume).abs() < 0.05) {
          volumeChangesWork = true;
        }
      }

      // Test play at high volume
      await _player.setVolume(1.0);
      await _player.play();
      await Future.delayed(const Duration(milliseconds: 300));
      final isPlaying = _player.playing;
      final finalVolume = _player.volume;

      _logger.d('Audio test - playing: $isPlaying, volume: $finalVolume');

      // Check if volume is working as expected
      final volumeWorking = finalVolume > 0.5;
      if (!volumeWorking) {
        _logger.w(
          'Volume control appears to be limited! Max achieved: $finalVolume',
        );
      }

      // Stop test playback
      await _player.pause();
      await _player.seek(Duration.zero);
      await _player.setVolume(_defaultVolume);

      _logger.d(
        'Audio verification completed, volume control working: $volumeWorking',
      );
      return volumeWorking;
    } catch (e, stack) {
      _logger.e('Error during audio verification', e, stack);
      return false;
    }
  }

  // Helper method to force setting volume with verification
  Future<bool> _forceSetVolume(double volume) async {
    try {
      _logger.d('Force setting volume to $volume');

      // Try multiple approaches to set volume
      for (int i = 0; i < 3; i++) {
        await _player.setVolume(volume);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Check if it worked
      final newVolume = _player.volume;
      _logger.d('After force setting, volume is: $newVolume (target: $volume)');

      return (newVolume - volume).abs() < 0.05;
    } catch (e) {
      _logger.e('Error in force setting volume', e);
      return false;
    }
  }

  // Start playing the audio directly at full volume
  Future<void> play({double fadeDuration = 2.0}) async {
    if (!_isInitialized) {
      _logger.w('Attempted to play audio before initialization completed');
      return;
    }

    try {
      _logger.d('Attempting to play audio directly at maximum volume');

      await _ensurePlayerReady();

      if (!_isMuted) {
        if (_useExtraLoudMode) {
          await _playWithExtraLoudMode();
        } else {
          // Set maximum volume directly
          final volumeSet = await _forceSetVolume(_defaultVolume);
          _logger.d(
            'Starting audio playback at volume $_defaultVolume (success: $volumeSet)',
          );

          try {
            await _player.play();

            // Verify playback actually started
            await Future.delayed(const Duration(milliseconds: 100));
            final isPlaying = _player.playing;
            final currentVolume = _player.volume;

            _logger.d(
              'Play command sent: playing=$isPlaying, volume=$currentVolume',
            );

            if (!isPlaying) {
              _logger.w('Play command sent but player did not start playing');
              await _player.play();
            }
          } catch (e, stack) {
            _logger.e('Error during play() call', e, stack);
          }
        }
      } else {
        _logger.d('Audio playback skipped because audio is muted');
      }
    } catch (e, stackTrace) {
      _logger.e('Error playing audio: ${e.toString()}', e, stackTrace);
    }
  }

  // Play using all players for maximum volume
  Future<void> _playWithExtraLoudMode() async {
    _logger.d(
      'Playing with extra loud mode (${_auxiliaryPlayers.length + 1} players)',
    );

    // First set all players to max volume
    await _player.setVolume(_defaultVolume);
    for (final player in _auxiliaryPlayers) {
      await player.setVolume(_defaultVolume);
    }

    // Use only one player at a time instead of multiple overlapping players
    await _player.play();

    _logger.d('Audio playback started with extra loud mode (single player)');
  }

  // Stop all playback
  Future<void> stop({double fadeDuration = 2.0}) async {
    try {
      _logger.d('Stopping all audio playback');

      // Stop main player
      if (_player.playing) {
        await _player.stop();
      }

      // Stop auxiliary players if in extra loud mode
      for (final player in _auxiliaryPlayers) {
        if (player.playing) {
          await player.stop();
        }
      }

      _logger.d('All audio playback stopped');
    } catch (e, stackTrace) {
      _logger.e('Error stopping audio', e, stackTrace);
    }
  }

  // Pause all playback
  Future<void> pause({double fadeDuration = 2.0}) async {
    try {
      _logger.d('Pausing all audio playback');

      // Pause main player
      if (_player.playing) {
        await _player.pause();
      }

      // Pause auxiliary players if in extra loud mode
      for (final player in _auxiliaryPlayers) {
        if (player.playing) {
          await player.pause();
        }
      }

      _logger.d('All audio playback paused');
    } catch (e, stackTrace) {
      _logger.e('Error pausing audio', e, stackTrace);
    }
  }

  // Resume playback
  Future<void> resume({double fadeDuration = 2.0}) async {
    try {
      if (!_isMuted) {
        if (_useExtraLoudMode) {
          await _playWithExtraLoudMode();
        } else {
          await _player.setVolume(_defaultVolume);
          await _player.play();
        }
        _logger.d('Audio playback resumed');
      }
    } catch (e, stackTrace) {
      _logger.e('Error resuming audio', e, stackTrace);
    }
  }

  // Toggle mute state (in-memory only, not persisted)
  Future<void> toggleMute() async {
    _logger.d('Toggling mute state, current state: $_isMuted');
    _isMuted = !_isMuted;
    _logger.i('Audio ${_isMuted ? 'muted' : 'unmuted'}');

    try {
      if (_isMuted) {
        await pause();
      } else {
        await play();
      }
    } catch (e, stack) {
      _logger.e('Error during mute toggle', e, stack);
    }
  }

  // Get mute state
  bool get isMuted => _isMuted;

  // Force restart audio - comprehensive reset
  Future<void> forceRestart() async {
    _logger.i('Force restarting audio with maximum volume');

    try {
      // Stop and dispose all players
      await stop();
      await _player.dispose();
      for (final player in _auxiliaryPlayers) {
        await player.dispose();
      }
      _auxiliaryPlayers.clear();

      // Create new player
      _player = AudioPlayer();
      _addPlayerListeners();

      // Set up in extra loud mode by default for reliability
      _useExtraLoudMode = true;

      // Reload and configure
      await _loadAudioAsset();
      await _configurePlayer();
      await _setupExtraLoudMode();

      // Play at maximum volume
      await _playWithExtraLoudMode();

      _logger.i('Audio force restart completed in extra loud mode');
    } catch (e, stack) {
      _logger.e('Error during audio force restart', e, stack);
    }
  }

  void _addPlayerListeners() {
    _player.playerStateStream.listen((playerState) {
      _logger.d(
        'Player state changed: ${playerState.processingState}, playing: ${playerState.playing}',
      );
    });

    _player.positionStream.listen((position) {
      _logger.v('Position update: $position, volume: ${_player.volume}');
    });

    _player.volumeStream.listen((volume) {
      if (_player.playing && volume < 0.3 && !_isMuted) {
        _logger.w('Warning: Volume too low ($volume) while playing');
        // Only log to avoid excessive volume changes during normal operation
      }
    });
  }

  Future<void> _ensurePlayerReady() async {
    if (_player.processingState != ProcessingState.ready) {
      _logger.w(
        'Player not ready: ${_player.processingState}. Attempting to prepare...',
      );
      try {
        final success = await _loadAudioAsset();
        if (!success) {
          _logger.e('Failed to reload audio asset');
          throw Exception('Failed to reload audio asset');
        }
      } catch (e, stackTrace) {
        _logger.e('Failed to reload audio asset', e, stackTrace);
        rethrow;
      }
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    _logger.d('Disposing AudioService resources');
    _volumeEnforceTimer?.cancel();

    await _player.dispose();
    for (final player in _auxiliaryPlayers) {
      await player.dispose();
    }

    _logger.i('AudioService disposed');
  }
}
