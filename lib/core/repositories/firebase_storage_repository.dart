import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseStorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  // Download a file from Firebase Storage
  Future<File> downloadFile(String path, String fileName) async {
    try {
      final ref = _storage.ref().child(path);
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File downloadToFile = File('${appDocDir.path}/$fileName');

      await ref.writeToFile(downloadToFile);
      return downloadToFile;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      rethrow;
    }
  }

  // Get download URL for a file
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      rethrow;
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }
}
