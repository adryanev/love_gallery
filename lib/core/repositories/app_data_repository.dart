import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/models/whisper.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/repositories/firestore_repository.dart';
import 'package:love_gallery/core/repositories/firebase_storage_repository.dart';
import 'package:love_gallery/core/services/firebase_service.dart';

class AppDataRepository implements DataRepository {
  final FirestoreRepository _firestoreRepo;
  final FirebaseStorageRepository _storageRepo;

  AppDataRepository({
    FirestoreRepository? firestoreRepo,
    FirebaseStorageRepository? storageRepo,
  }) : _firestoreRepo = firestoreRepo ?? FirestoreRepository(),
       _storageRepo = storageRepo ?? FirebaseStorageRepository();

  bool get _isFirebaseAvailable => FirebaseService.isInitialized;

  // MEMORY METHODS
  @override
  Future<List<Memory>> getMemories() async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getMemories();
      } catch (e) {
        debugPrint('Error fetching memories from Firestore: $e');
        return _getLocalMemories();
      }
    } else {
      return _getLocalMemories();
    }
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
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getMemory(id);
      } catch (e) {
        debugPrint('Error fetching memory from Firestore: $e');
        // Try to find in local data
        final memories = await _getLocalMemories();
        try {
          return memories.firstWhere((m) => m.id == id);
        } catch (_) {
          return null;
        }
      }
    } else {
      final memories = await _getLocalMemories();
      try {
        return memories.firstWhere((m) => m.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<String> addMemory(Memory memory) async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.addMemory(memory);
      } catch (e) {
        debugPrint('Error adding memory to Firestore: $e');
        throw Exception('Failed to add memory: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot add memory');
    }
  }

  @override
  Future<void> updateMemory(Memory memory) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.updateMemory(memory);
      } catch (e) {
        debugPrint('Error updating memory in Firestore: $e');
        throw Exception('Failed to update memory: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot update memory');
    }
  }

  @override
  Future<void> deleteMemory(String id) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.deleteMemory(id);
      } catch (e) {
        debugPrint('Error deleting memory from Firestore: $e');
        throw Exception('Failed to delete memory: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot delete memory');
    }
  }

  // WHISPER METHODS
  @override
  Future<List<Whisper>> getWhispers() async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getWhispers();
      } catch (e) {
        debugPrint('Error fetching whispers from Firestore: $e');
        return _getLocalWhispers();
      }
    } else {
      return _getLocalWhispers();
    }
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
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getWhisper(id);
      } catch (e) {
        debugPrint('Error fetching whisper from Firestore: $e');
        // Try to find in local data
        final whispers = await _getLocalWhispers();
        try {
          return whispers.firstWhere((w) => w.id == id);
        } catch (_) {
          return null;
        }
      }
    } else {
      final whispers = await _getLocalWhispers();
      try {
        return whispers.firstWhere((w) => w.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<String> addWhisper(Whisper whisper) async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.addWhisper(whisper);
      } catch (e) {
        debugPrint('Error adding whisper to Firestore: $e');
        throw Exception('Failed to add whisper: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot add whisper');
    }
  }

  @override
  Future<void> updateWhisper(Whisper whisper) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.updateWhisper(whisper);
      } catch (e) {
        debugPrint('Error updating whisper in Firestore: $e');
        throw Exception('Failed to update whisper: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot update whisper');
    }
  }

  @override
  Future<void> deleteWhisper(String id) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.deleteWhisper(id);
      } catch (e) {
        debugPrint('Error deleting whisper from Firestore: $e');
        throw Exception('Failed to delete whisper: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot delete whisper');
    }
  }

  // FUTURE DREAM METHODS
  @override
  Future<List<FutureDream>> getFutureDreams() async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getFutureDreams();
      } catch (e) {
        debugPrint('Error fetching future dreams from Firestore: $e');
        return _getLocalFutureDreams();
      }
    } else {
      return _getLocalFutureDreams();
    }
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
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.getFutureDream(id);
      } catch (e) {
        debugPrint('Error fetching future dream from Firestore: $e');
        // Try to find in local data
        final futureDreams = await _getLocalFutureDreams();
        try {
          return futureDreams.firstWhere((fd) => fd.id == id);
        } catch (_) {
          return null;
        }
      }
    } else {
      final futureDreams = await _getLocalFutureDreams();
      try {
        return futureDreams.firstWhere((fd) => fd.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<String> addFutureDream(FutureDream futureDream) async {
    if (_isFirebaseAvailable) {
      try {
        return await _firestoreRepo.addFutureDream(futureDream);
      } catch (e) {
        debugPrint('Error adding future dream to Firestore: $e');
        throw Exception('Failed to add future dream: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot add future dream');
    }
  }

  @override
  Future<void> updateFutureDream(FutureDream futureDream) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.updateFutureDream(futureDream);
      } catch (e) {
        debugPrint('Error updating future dream in Firestore: $e');
        throw Exception('Failed to update future dream: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot update future dream');
    }
  }

  @override
  Future<void> deleteFutureDream(String id) async {
    if (_isFirebaseAvailable) {
      try {
        await _firestoreRepo.deleteFutureDream(id);
      } catch (e) {
        debugPrint('Error deleting future dream from Firestore: $e');
        throw Exception('Failed to delete future dream: $e');
      }
    } else {
      throw Exception('Firebase not available, cannot delete future dream');
    }
  }

  // ASSET HANDLING METHODS
  @override
  Future<String> getImagePath(String path) async {
    if (_isFirebaseAvailable &&
        (path.startsWith('gs://') || path.startsWith('http'))) {
      try {
        return await _storageRepo.getDownloadURL(path);
      } catch (e) {
        debugPrint('Error getting download URL: $e');
        return path; // Return original path as fallback
      }
    } else {
      return path; // Return original path for local assets
    }
  }

  @override
  Future<String?> uploadFile(File file, String path) async {
    if (_isFirebaseAvailable) {
      try {
        return await _storageRepo.uploadFile(file, path);
      } catch (e) {
        debugPrint('Error uploading file: $e');
        return null;
      }
    } else {
      debugPrint('Firebase not initialized, cannot upload file');
      return null;
    }
  }
}
