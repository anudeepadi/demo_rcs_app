import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class MediaPickerService {
  static Future<FilePickerResult?> pickMedia({
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? ['jpg', 'jpeg', 'png', 'gif', 'mp4'],
      allowMultiple: false,
    );
  }

  static bool isVideoFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType?.startsWith('video/') ?? false;
  }

  static bool isImageFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType?.startsWith('image/') ?? false;
  }

  static bool isGifFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType == 'image/gif';
  }

  static bool isAudioFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType?.startsWith('audio/') ?? false;
  }

  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  static String getFileName(String filePath) {
    return path.basename(filePath);
  }
}