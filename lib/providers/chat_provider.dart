import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'package:path/path.dart' as path;

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  String? _currentUserId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get currentUserId => _currentUserId;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<void> addTextMessage({
    required String content,
    String? replyToMessageId,
    String? threadId,
  }) async {
    if (_currentUserId == null) return;

    final message = ChatMessage(
      senderId: _currentUserId!,
      type: MessageType.text,
      content: content,
      isMe: true,
      parentMessageId: replyToMessageId,
      threadId: threadId,
      status: MessageStatus.sending,
    );

    _messages.add(message);
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message.copyWith(status: MessageStatus.sent);
      notifyListeners();
    }
  }

  Future<void> sendMedia({
    required File file,
    required MessageType type,
    String? caption,
    String? replyToMessageId,
  }) async {
    if (_currentUserId == null) return;

    final fileName = path.basename(file.path);
    final fileSize = await file.length();

    final message = ChatMessage(
      senderId: _currentUserId!,
      type: type,
      content: caption ?? '',
      isMe: true,
      mediaUrl: file.path,
      fileName: fileName,
      fileSize: fileSize,
      parentMessageId: replyToMessageId,
      status: MessageStatus.sending,
    );

    _messages.add(message);
    notifyListeners();

    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));

    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message.copyWith(status: MessageStatus.sent);
      notifyListeners();
    }
  }

  Future<void> sendFile({
    required File file,
    String? caption,
    String? replyToMessageId,
  }) async {
    await sendMedia(
      file: file,
      type: MessageType.file,
      caption: caption,
      replyToMessageId: replyToMessageId,
    );
  }

  Future<void> sendQuickReplies({
    required List<QuickReply> replies,
    String? content,
    String? replyToMessageId,
  }) async {
    if (_currentUserId == null) return;

    final message = ChatMessage(
      senderId: _currentUserId!,
      type: MessageType.quickReply,
      content: content ?? '',
      isMe: true,
      suggestedReplies: replies.map((r) => r.text).toList(),
      parentMessageId: replyToMessageId,
      status: MessageStatus.sending,
    );

    _messages.add(message);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message.copyWith(status: MessageStatus.sent);
      notifyListeners();
    }
  }

  void addReaction(String messageId, String emoji) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _currentUserId != null) {
      final message = _messages[index];
      final existingReactionIndex = message.reactions
          .indexWhere((r) => r.userId == _currentUserId);

      if (existingReactionIndex != -1) {
        // Update existing reaction
        final updatedReactions = List<MessageReaction>.from(message.reactions);
        updatedReactions[existingReactionIndex] = MessageReaction(
          userId: _currentUserId!,
          emoji: emoji,
        );
        _messages[index] = message.copyWith(reactions: updatedReactions);
      } else {
        // Add new reaction
        final updatedReactions = List<MessageReaction>.from(message.reactions)
          ..add(MessageReaction(
            userId: _currentUserId!,
            emoji: emoji,
          ));
        _messages[index] = message.copyWith(reactions: updatedReactions);
      }
      notifyListeners();
    }
  }

  void removeReaction(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _currentUserId != null) {
      final message = _messages[index];
      final updatedReactions = message.reactions
          .where((r) => r.userId != _currentUserId)
          .toList();
      _messages[index] = message.copyWith(reactions: updatedReactions);
      notifyListeners();
    }
  }

  void updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}