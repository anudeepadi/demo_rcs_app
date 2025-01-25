import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;
import '../models/chat_message.dart';
import '../models/quick_reply.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _channelMessages = {};
  String _currentChannelId = 'default';
  String _currentServerId = '';
  
  List<ChatMessage> get currentMessages => _channelMessages[_currentChannelId] ?? [];
  String get currentChannelId => _currentChannelId;
  String get currentServerId => _currentServerId;
  List<String> get channels => _channelMessages.keys.toList();

  Future<void> loadMessages(String channelId, String serverId) async {
    _currentChannelId = channelId;
    _currentServerId = serverId;
    if (!_channelMessages.containsKey(channelId)) {
      _channelMessages[channelId] = [];
    }
    notifyListeners();
  }

  List<ChatMessage> getMessagesForChannel(String channelId) {
    return _channelMessages[channelId] ?? [];
  }

  void switchChannel(String channelId) {
    _currentChannelId = channelId;
    if (!_channelMessages.containsKey(channelId)) {
      _channelMessages[channelId] = [];
    }
    notifyListeners();
  }

  void sendMessage(String text, {String? channelId, String? serverId}) {
    final targetChannel = channelId ?? _currentChannelId;
    final message = ChatMessage(
      text: text,
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.text,
      channelId: targetChannel,
    );
    _addMessage(message);

    // Generate bot response
    _generateBotResponse(text);
  }

  Future<void> sendImage(String imagePath, {String? thumbnailUrl}) async {
    final message = ChatMessage(
      text: '',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.image,
      mediaUrl: imagePath,
      thumbnailUrl: thumbnailUrl,
      channelId: _currentChannelId,
    );
    _addMessage(message);
  }

  Future<void> sendVideo(String videoPath) async {
    // Generate thumbnail
    final thumbnailFile = await VideoCompress.getFileThumbnail(
      videoPath,
      quality: 50,
      position: -1,
    );

    final message = ChatMessage(
      text: '',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.video,
      mediaUrl: videoPath,
      thumbnailUrl: thumbnailFile.path,
      fileName: path.basename(videoPath),
      channelId: _currentChannelId,
    );
    _addMessage(message);
  }

  void sendGif(String gifPath) {
    final message = ChatMessage(
      text: '',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.gif,
      mediaUrl: gifPath,
      channelId: _currentChannelId,
    );
    _addMessage(message);
  }

  void sendFile(String filePath, String fileName, String fileSize) {
    final message = ChatMessage(
      text: '',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.file,
      mediaUrl: filePath,
      fileName: fileName,
      fileSize: fileSize,
      channelId: _currentChannelId,
    );
    _addMessage(message);
  }

  Future<void> handleQuickReply(QuickReply quickReply) async {
    sendMessage(quickReply.text);
  }

  void _addMessage(ChatMessage message) {
    if (!_channelMessages.containsKey(message.channelId)) {
      _channelMessages[message.channelId] = [];
    }
    _channelMessages[message.channelId]!.add(message);
    notifyListeners();
  }

  Future<void> _generateBotResponse(String userMessage) async {
    // Simulate typing delay
    await Future.delayed(const Duration(seconds: 1));

    String response;
    if (userMessage.toLowerCase().contains('hello') || 
        userMessage.toLowerCase().contains('hi')) {
      response = 'Hello! How can I help you today?';
    } else if (userMessage.toLowerCase().contains('help')) {
      response = 'I can help you with:\n- Sending messages\n- Sharing media\n- Getting information';
    } else if (userMessage.toLowerCase().contains('feature')) {
      response = 'Here are some features:\n- Rich media messaging\n- Quick replies\n- Link previews\n- Video thumbnails';
    } else if (userMessage.toLowerCase().contains('about')) {
      response = 'This is an RCS Demo App showcasing rich communication features.';
    } else if (userMessage.toLowerCase().contains('yes')) {
      response = 'Great! What would you like to know more about?';
    } else if (userMessage.toLowerCase().contains('no')) {
      response = 'No problem! Let me know if you need anything else.';
    } else {
      response = 'I understand. Would you like to know more about our features?';
    }

    final message = ChatMessage(
      text: response,
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
      channelId: _currentChannelId,
    );
    _addMessage(message);
  }

  void clearChannel(String channelId) {
    _channelMessages[channelId]?.clear();
    notifyListeners();
  }

  void clearAllChannels() {
    _channelMessages.clear();
    notifyListeners();
  }
}