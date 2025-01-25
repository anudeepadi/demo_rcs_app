import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoThumbnailViewer extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const VideoThumbnailViewer({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<VideoThumbnailViewer> createState() => _VideoThumbnailViewerState();
}

class _VideoThumbnailViewerState extends State<VideoThumbnailViewer> {
  File? _thumbnailFile;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      // Download video file if it's a URL
      if (widget.videoUrl.startsWith('http')) {
        final tempDir = await getTemporaryDirectory();
        final videoFile = File('${tempDir.path}/temp_video.mp4');
        
        final response = await http.get(Uri.parse(widget.videoUrl));
        await videoFile.writeAsBytes(response.bodyBytes);
        
        final thumbnail = await VideoCompress.getFileThumbnail(
          videoFile.path,
          quality: 50,
          position: -1, // milliseconds, -1 means the middle position
        );
        
        if (mounted) {
          setState(() {
            _thumbnailFile = thumbnail;
          });
        }
        
        // Clean up the temporary video file
        if (await videoFile.exists()) {
          await videoFile.delete();
        }
      } else {
        // Local file
        final thumbnail = await VideoCompress.getFileThumbnail(
          widget.videoUrl,
          quality: 50,
          position: -1,
        );
        
        if (mounted) {
          setState(() {
            _thumbnailFile = thumbnail;
          });
        }
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnailFile == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            _thumbnailFile!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
            ),
          ),
          Icon(
            Icons.play_circle_filled,
            size: (widget.height ?? 150) / 3,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}