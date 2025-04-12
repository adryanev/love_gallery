import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/models/whisper.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';

/// A repository implementation that only uses local data sources
/// Useful for testing and offline development
class MockDataRepository implements DataRepository {
  // MEMORY METHODS
  @override
  Future<List<Memory>> getMemories() async {
    return _getLocalMemories();
  }

  Future<List<Memory>> _getLocalMemories() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/memories.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Memory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading local memories: $e');
      return [];
    }
  }

  @override
  Future<Memory?> getMemory(String id) async {
    final memories = await _getLocalMemories();
    try {
      return memories.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> addMemory(Memory memory) async {
    throw UnimplementedError('Cannot add memory in mock mode');
  }

  @override
  Future<void> updateMemory(Memory memory) async {
    throw UnimplementedError('Cannot update memory in mock mode');
  }

  @override
  Future<void> deleteMemory(String id) async {
    throw UnimplementedError('Cannot delete memory in mock mode');
  }

  // WHISPER METHODS
  @override
  Future<List<Whisper>> getWhispers() async {
    return _getLocalWhispers();
  }

  Future<List<Whisper>> _getLocalWhispers() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/whispers.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Whisper.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading local whispers: $e');
      return [];
    }
  }

  @override
  Future<Whisper?> getWhisper(String id) async {
    final whispers = await _getLocalWhispers();
    try {
      return whispers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> addWhisper(Whisper whisper) async {
    throw UnimplementedError('Cannot add whisper in mock mode');
  }

  @override
  Future<void> updateWhisper(Whisper whisper) async {
    throw UnimplementedError('Cannot update whisper in mock mode');
  }

  @override
  Future<void> deleteWhisper(String id) async {
    throw UnimplementedError('Cannot delete whisper in mock mode');
  }

  // FUTURE DREAM METHODS
  @override
  Future<List<FutureDream>> getFutureDreams() async {
    return _getLocalFutureDreams();
  }

  Future<List<FutureDream>> _getLocalFutureDreams() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/future_dreams.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FutureDream.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading local future dreams: $e');
      return [];
    }
  }

  @override
  Future<FutureDream?> getFutureDream(String id) async {
    final futureDreams = await _getLocalFutureDreams();
    try {
      return futureDreams.firstWhere((fd) => fd.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> addFutureDream(FutureDream futureDream) async {
    throw UnimplementedError('Cannot add future dream in mock mode');
  }

  @override
  Future<void> updateFutureDream(FutureDream futureDream) async {
    throw UnimplementedError('Cannot update future dream in mock mode');
  }

  @override
  Future<void> deleteFutureDream(String id) async {
    throw UnimplementedError('Cannot delete future dream in mock mode');
  }

  // ASSET HANDLING METHODS
  @override
  Future<String> getImagePath(String path) async {
    return path; // Just return original path for local assets
  }

  @override
  Future<String?> uploadFile(File file, String path) async {
    throw UnimplementedError('Cannot upload file in mock mode');
  }
}
