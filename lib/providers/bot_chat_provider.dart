import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';

class BotChatProvider with ChangeNotifier {
  final List<QuickReply> _defaultQuickReplies = [
    QuickReply(
      id: 'help',
      text: 'Help',
      postbackData: 'help',
    ),
    QuickReply(
      id: 'status',
      text: 'Check Status',
      postbackData: 'status',
    ),
    QuickReply(
      id: 'menu',
      text: 'Show Menu',
      postbackData: 'menu',
    ),
  ];

  List<QuickReply> get defaultQuickReplies => _defaultQuickReplies;

  Future<void> processQuickReply(QuickReply quickReply) async {
    // Implement quick reply processing logic here
    switch (quickReply.postbackData) {
      case 'help':
        // Handle help request
        break;
      case 'status':
        // Handle status check
        break;
      case 'menu':
        // Handle menu request
        break;
    }
  }
}