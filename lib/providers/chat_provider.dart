import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../models/message.dart';
import '../services/media_service.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<Message>> _channelMessages = {};
  final MediaService _mediaService = MediaService();
  bool _isLoading = false;
  bool _isTyping = false;
  
  static const String _storageKey = 'chat_messages';

  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _loadStoredMessages();
  }

  Future<MediaAttachment?> uploadMedia(String filePath) async {
    try {
      final url = await _mediaService.uploadMedia(filePath);
      if (url == null) return null;

      // Create MediaAttachment with local file information
      return MediaAttachment(
        url: url,
        mimeType: path.extension(filePath).toLowerCase(),
      );
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }

  List<Message> getMessagesForChannel(String channelId) {
    return List.unmodifiable(_channelMessages[channelId] ?? []);
  }

  Future<void> _loadStoredMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedMessages = prefs.getString(_storageKey);
      
      if (storedMessages != null) {
        final decodedMessages = json.decode(storedMessages) as Map<String, dynamic>;
        decodedMessages.forEach((channelId, messages) {
          _channelMessages[channelId] = (messages as List)
              .map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading stored messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _storeMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedMessages = json.encode(_channelMessages.map(
        (key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()),
      ));
      await prefs.setString(_storageKey, encodedMessages);
    } catch (e) {
      debugPrint('Error storing messages: $e');
    }
  }

  Future<void> loadMessages({String? channelId}) async {
    if (channelId != null && !_channelMessages.containsKey(channelId)) {
      _channelMessages[channelId] = [];
      
      // Add welcome message for new channels
      _addMessage(Message(
        id: DateTime.now().toString(),
        content: 'Welcome to the channel! You are in offline mode.',
        channelId: channelId,
        serverId: 'system',
        isMe: false,
        timestamp: DateTime.now(),
        senderName: 'System',
      ));
    }
  }

  void _addMessage(Message message) {
    if (!_channelMessages.containsKey(message.channelId)) {
      _channelMessages[message.channelId] = [];
    }
    
    _channelMessages[message.channelId]!.add(message);
    notifyListeners();
    _storeMessages();
  }

  Future<void> sendMessage(
    String content, {
    required String channelId,
    required String serverId,
    MessageType type = MessageType.text,
    MediaAttachment? mediaAttachment,
  }) async {
    if (content.trim().isEmpty && mediaAttachment == null) return;

    final message = Message(
      id: DateTime.now().toString(),
      content: content,
      channelId: channelId,
      serverId: serverId,
      isMe: true,
      timestamp: DateTime.now(),
      type: type,
      mediaAttachment: mediaAttachment,
      senderName: 'Me',
    );

    _addMessage(message);

    // Simulate response in offline mode
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (content.toLowerCase().contains('hello') || content.toLowerCase().contains('hi')) {
      _addMessage(Message(
        id: DateTime.now().toString(),
        content: 'Hello! How can I help you today?',
        channelId: channelId,
        serverId: serverId,
        isMe: false,
        timestamp: DateTime.now(),
        senderName: 'Bot',
      ));
    }
  }

  Future<void> handleQuickReply(String text, String channelId, String serverId) async {
    _isTyping = true;
    notifyListeners();
    
    await sendMessage(text, channelId: channelId, serverId: serverId);
    
    await Future.delayed(const Duration(seconds: 1));
    
    _isTyping = false;
    notifyListeners();
  }
}