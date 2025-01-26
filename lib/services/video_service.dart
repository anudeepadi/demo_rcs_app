import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import '../models/video_message_model.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  final _uuid = const Uuid();
  
  factory VideoService() {
    return _instance;
  }

  VideoService._internal();

  Future<String> saveVideoLocally(File videoFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDirectory = Directory('${directory.path}/videos');
      
      if (!await videoDirectory.exists()) {
        await videoDirectory.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}${path.extension(videoFile.path)}';
      final savedFile = await videoFile.copy('${videoDirectory.path}/$fileName');
      
      return savedFile.path;
    } catch (e) {
      print('Error saving video locally: $e');
      rethrow;
    }
  }

  Future<String?> generateThumbnail(String videoPath) async {
    try {
      final videoPlayerController = videoPath.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
          : VideoPlayerController.file(File(videoPath));

      await videoPlayerController.initialize();
      
      // Seek to the first frame
      await videoPlayerController.seekTo(Duration.zero);
      
      // TODO: Implement actual thumbnail generation
      // For now, we'll return null as thumbnail generation requires
      // additional packages like video_thumbnail or ffmpeg
      
      await videoPlayerController.dispose();
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<Duration?> getVideoDuration(String videoPath) async {
    try {
      final videoPlayerController = videoPath.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
          : VideoPlayerController.file(File(videoPath));

      await videoPlayerController.initialize();
      final duration = videoPlayerController.value.duration;
      await videoPlayerController.dispose();
      return duration;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }

  Future<VideoMessageModel> createVideoMessage({
    required String senderId,
    required File videoFile,
    String? caption,
  }) async {
    try {
      // Save video locally
      final localPath = await saveVideoLocally(videoFile);
      
      // Get video metadata
      final duration = await getVideoDuration(localPath);
      final size = await videoFile.length();
      
      // Generate thumbnail (if implemented)
      final thumbnailUrl = await generateThumbnail(localPath);

      return VideoMessageModel(
        id: _uuid.v4(),
        senderId: senderId,
        videoUrl: localPath,
        thumbnailUrl: thumbnailUrl,
        timestamp: DateTime.now(),
        isLocalFile: true,
        caption: caption,
        duration: duration,
        size: size,
        metadata: {
          'originalFileName': path.basename(videoFile.path),
          'mimeType': 'video/${path.extension(videoFile.path).replaceAll('.', '')}',
        },
      );
    } catch (e) {
      print('Error creating video message: $e');
      rethrow;
    }
  }

  Future<void> deleteVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting video: $e');
      rethrow;
    }
  }

  Future<File> downloadVideo(String url, {Function(double)? onProgress}) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      final directory = await getApplicationDocumentsDirectory();
      final videoDirectory = Directory('${directory.path}/videos');
      
      if (!await videoDirectory.exists()) {
        await videoDirectory.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}${path.extension(url)}';
      final filePath = '${videoDirectory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      return file;
    } catch (e) {
      print('Error downloading video: $e');
      rethrow;
    }
  }
}