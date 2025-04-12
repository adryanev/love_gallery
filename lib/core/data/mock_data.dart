import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/models/whisper.dart';
import 'package:love_gallery/core/repositories/firestore_repository.dart';
import 'package:love_gallery/core/repositories/firebase_storage_repository.dart';
import 'package:love_gallery/core/services/firebase_service.dart';

class MockData {
  static final FirestoreRepository _firestoreRepo = FirestoreRepository();
  static final FirebaseStorageRepository _storageRepo =
      FirebaseStorageRepository();

  // Get Memories - fallback to local JSON if Firebase is not available
  static Future<List<Memory>> getMemories() async {
    if (FirebaseService.isInitialized) {
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

  // Get local memories from JSON
  static Future<List<Memory>> _getLocalMemories() async {
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

  // Get Whispers - fallback to local JSON if Firebase is not available
  static Future<List<Whisper>> getWhispers() async {
    if (FirebaseService.isInitialized) {
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

  // Get local whispers from JSON
  static Future<List<Whisper>> _getLocalWhispers() async {
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

  // Get Future Dreams - fallback to local JSON if Firebase is not available
  static Future<List<FutureDream>> getFutureDreams() async {
    if (FirebaseService.isInitialized) {
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

  // Get local future dreams from JSON
  static Future<List<FutureDream>> _getLocalFutureDreams() async {
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

  // Get a file from Firebase Storage or local assets
  static Future<String> getImagePath(String path) async {
    if (FirebaseService.isInitialized && path.startsWith('gs://') ||
        path.startsWith('http')) {
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

  // Upload a file to Firebase Storage
  static Future<String?> uploadFile(File file, String path) async {
    if (FirebaseService.isInitialized) {
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
