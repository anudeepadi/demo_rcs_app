import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class MediaPickerService {
  static Future<FilePickerResult?> pickMedia({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      return await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );
    } catch (e) {
      print('Error picking media: $e');
      return null;
    }
  }

  static bool isVideoFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType?.startsWith('video/') ?? false;
  }

  static bool isImageFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType?.startsWith('image/') ?? false;
  }

  static bool isGifFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType == 'image/gif';
  }
}