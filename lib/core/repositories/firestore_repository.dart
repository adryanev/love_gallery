import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/models/whisper.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Memories Collection
  CollectionReference<Map<String, dynamic>> get memoriesCollection =>
      _firestore.collection('memories');

  // Whispers Collection
  CollectionReference<Map<String, dynamic>> get whispersCollection =>
      _firestore.collection('whispers');

  // Future Dreams Collection
  CollectionReference<Map<String, dynamic>> get futureDreamsCollection =>
      _firestore.collection('future_dreams');

  // MEMORIES METHODS
  Future<List<Memory>> getMemories() async {
    try {
      final snapshot = await memoriesCollection.orderBy('date').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure the document ID is set
        return Memory.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting memories: $e');
      return [];
    }
  }

  Future<Memory?> getMemory(String id) async {
    try {
      final doc = await memoriesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Memory.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting memory: $e');
      return null;
    }
  }

  Future<String> addMemory(Memory memory) async {
    try {
      final docRef = await memoriesCollection.add(memory.toJson());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding memory: $e');
      rethrow;
    }
  }

  Future<void> updateMemory(Memory memory) async {
    try {
      await memoriesCollection.doc(memory.id).update(memory.toJson());
    } catch (e) {
      debugPrint('Error updating memory: $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(String id) async {
    try {
      await memoriesCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting memory: $e');
      rethrow;
    }
  }

  // WHISPERS METHODS
  Future<List<Whisper>> getWhispers() async {
    try {
      final snapshot = await whispersCollection.orderBy('id').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Whisper.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting whispers: $e');
      return [];
    }
  }

  Future<Whisper?> getWhisper(String id) async {
    try {
      final doc = await whispersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Whisper.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting whisper: $e');
      return null;
    }
  }

  Future<String> addWhisper(Whisper whisper) async {
    try {
      final docRef = await whispersCollection.add(whisper.toJson());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding whisper: $e');
      rethrow;
    }
  }

  Future<void> updateWhisper(Whisper whisper) async {
    try {
      await whispersCollection.doc(whisper.id).update(whisper.toJson());
    } catch (e) {
      debugPrint('Error updating whisper: $e');
      rethrow;
    }
  }

  Future<void> deleteWhisper(String id) async {
    try {
      await whispersCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting whisper: $e');
      rethrow;
    }
  }

  // FUTURE DREAMS METHODS
  Future<List<FutureDream>> getFutureDreams() async {
    try {
      final snapshot = await futureDreamsCollection.orderBy('id').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FutureDream.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting future dreams: $e');
      return [];
    }
  }

  Future<FutureDream?> getFutureDream(String id) async {
    try {
      final doc = await futureDreamsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return FutureDream.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting future dream: $e');
      return null;
    }
  }

  Future<String> addFutureDream(FutureDream futureDream) async {
    try {
      final docRef = await futureDreamsCollection.add(futureDream.toJson());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding future dream: $e');
      rethrow;
    }
  }

  Future<void> updateFutureDream(FutureDream futureDream) async {
    try {
      await futureDreamsCollection
          .doc(futureDream.id)
          .update(futureDream.toJson());
    } catch (e) {
      debugPrint('Error updating future dream: $e');
      rethrow;
    }
  }

  Future<void> deleteFutureDream(String id) async {
    try {
      await futureDreamsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting future dream: $e');
      rethrow;
    }
  }
}
