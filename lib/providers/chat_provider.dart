import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart' show lookupMimeType;
import '../models/message.dart';
import '../models/quick_reply.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, {
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
  }) async {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(message);
    setTyping(true);
    notifyListeners();

    try {
      final response = await _apiService.sendMessage(message);
      _messages.add(response['botResponse']!);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }

    setTyping(false);
    notifyListeners();
  }

  Future<void> handleQuickReply(QuickReply reply) async {
    await sendMessage(reply.text);

    setTyping(true);
    notifyListeners();

    try {
      final botResponse = await _apiService.handleQuickReply(reply);
      _messages.add(botResponse);
    } catch (e) {
      debugPrint('Error handling quick reply: $e');
    }

    setTyping(false);
    notifyListeners();
  }

  Future<String?> uploadMedia(List<int> bytes, String fileName) async {
    try {
      String mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      return await _apiService.uploadMedia(bytes, fileName, mimeType);
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  Future<void> clearMessages() async {
    try {
      await _apiService.clearMessages();
      await loadMessages();
    } catch (e) {
      debugPrint('Error clearing messages: $e');
    }
  }
}