import 'dart:io';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/models/whisper.dart';

abstract class DataRepository {
  // Memory methods
  Future<List<Memory>> getMemories();
  Future<Memory?> getMemory(String id);
  Future<String> addMemory(Memory memory);
  Future<void> updateMemory(Memory memory);
  Future<void> deleteMemory(String id);

  // Whisper methods
  Future<List<Whisper>> getWhispers();
  Future<Whisper?> getWhisper(String id);
  Future<String> addWhisper(Whisper whisper);
  Future<void> updateWhisper(Whisper whisper);
  Future<void> deleteWhisper(String id);

  // Future Dream methods
  Future<List<FutureDream>> getFutureDreams();
  Future<FutureDream?> getFutureDream(String id);
  Future<String> addFutureDream(FutureDream futureDream);
  Future<void> updateFutureDream(FutureDream futureDream);
  Future<void> deleteFutureDream(String id);

  // Asset handling methods
  Future<String> getImagePath(String path);
  Future<String?> uploadFile(File file, String path);
}
