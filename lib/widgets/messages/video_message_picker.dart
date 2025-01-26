import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/video_message_provider.dart';

class VideoMessagePicker extends StatefulWidget {
  final String senderId;
  final Function(bool)? onPickingStateChanged;

  const VideoMessagePicker({
    Key? key,
    required this.senderId,
    this.onPickingStateChanged,
  }) : super(key: key);

  @override
  State<VideoMessagePicker> createState() => _VideoMessagePickerState();
}

class _VideoMessagePickerState extends State<VideoMessagePicker> {
  File? _selectedVideo;
  final TextEditingController _captionController = TextEditingController();
  bool _isPicking = false;

  Future<void> _pickVideo() async {
    try {
      setState(() {
        _isPicking = true;
      });
      widget.onPickingStateChanged?.call(true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedVideo = File(result.files.first.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    } finally {
      setState(() {
        _isPicking = false;
      });
      widget.onPickingStateChanged?.call(false);
    }
  }

  Future<void> _sendVideo() async {
    if (_selectedVideo == null) return;

    try {
      final provider = context.read<VideoMessageProvider>();
      await provider.sendVideoMessage(
        senderId: widget.senderId,
        videoFile: _selectedVideo!,
        caption: _captionController.text.trim(),
      );

      // Clear selection after successful send
      setState(() {
        _selectedVideo = null;
        _captionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoMessageProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedVideo != null) ...[
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.video_file,
                        size: 48,
                        color: Colors.white70,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _selectedVideo = null;
                              _captionController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    hintText: 'Add a caption...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.video_library),
                    onPressed: _isPicking ? null : _pickVideo,
                    tooltip: 'Pick Video',
                  ),
                  if (_selectedVideo != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isUploading ? null : _sendVideo,
                        child: provider.isUploading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(provider.uploadProgress * 100).toInt()}%',
                                  ),
                                ],
                              )
                            : const Text('Send Video'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}