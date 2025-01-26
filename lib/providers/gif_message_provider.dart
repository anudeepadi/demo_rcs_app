import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/gif_message_model.dart';
import '../services/giphy_service.dart';

class GifMessageProvider with ChangeNotifier {
  final List<GifMessageModel> _messages = [];
  final _uuid = const Uuid();
  final GiphyService _giphyService = GiphyService();
  
  List<GifMessageModel> get messages => List.unmodifiable(_messages);

  Future<GifMessageModel> sendGifMessage({
    required String senderId,
    required GiphyGif gif,
    String? caption,
  }) async {
    // Create new message
    final message = GifMessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      gif: gif,
      timestamp: DateTime.now(),
      caption: caption,
      status: MessageStatus.sending,
    );

    // Add to messages list
    _messages.add(message);
    notifyListeners();

    try {
      // TODO: Implement actual server communication
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Update message status
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(status: MessageStatus.sent);
        notifyListeners();
      }

      return message;
    } catch (e) {
      // Update message status to failed
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
      rethrow;
    }
  }

  void updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void addMessage(GifMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}