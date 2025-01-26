import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/video_message_model.dart';
import '../services/video_service.dart';

class VideoMessageProvider with ChangeNotifier {
  final VideoService _videoService = VideoService();
  final List<VideoMessageModel> _messages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  List<VideoMessageModel> get messages => List.unmodifiable(_messages);
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  Future<VideoMessageModel> sendVideoMessage({
    required String senderId,
    required File videoFile,
    String? caption,
  }) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Create local video message
      final message = await _videoService.createVideoMessage(
        senderId: senderId,
        videoFile: videoFile,
        caption: caption,
      );

      // Add to messages list
      _messages.add(message);
      notifyListeners();

      // TODO: Implement actual server upload
      // Simulate upload progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        _uploadProgress = i / 10;
        notifyListeners();
      }

      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();

      return message;
    } catch (e) {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final message = _messages[messageIndex];
        
        // Delete local file if it exists
        if (message.isLocalFile) {
          await _videoService.deleteVideo(message.videoUrl);
        }

        _messages.removeAt(messageIndex);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting video message: $e');
      rethrow;
    }
  }

  Future<void> downloadVideo(VideoMessageModel message) async {
    if (message.isLocalFile) return;

    try {
      final file = await _videoService.downloadVideo(
        message.videoUrl,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // Update message with local file path
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(
          videoUrl: file.path,
          isLocalFile: true,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error downloading video: $e');
      rethrow;
    }
  }

  void addMessage(VideoMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}