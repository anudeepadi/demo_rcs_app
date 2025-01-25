import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  Future<String?> uploadMedia(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      // Generate a unique filename based on content hash
      final fileBytes = await file.readAsBytes();
      final hash = sha256.convert(fileBytes).toString().substring(0, 10);
      final extension = path.extension(filePath);
      final fileName = '$hash$extension';

      // Save file to local app directory
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/media');
      await mediaDir.create(recursive: true);

      final destinationPath = '${mediaDir.path}/$fileName';
      await file.copy(destinationPath);

      // Return local file URL
      return 'file://$destinationPath';
    } catch (e) {
      debugPrint('Error handling media: $e');
      return null;
    }
  }

  Future<bool> deleteMedia(String url) async {
    try {
      if (url.startsWith('file://')) {
        final file = File(url.replaceFirst('file://', ''));
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting media: $e');
      return false;
    }
  }
}