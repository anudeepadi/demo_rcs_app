import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  String? _clientId;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  void connect(String clientId) {
    _clientId = clientId;
    _connectToServer();
  }

  void _connectToServer() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws/$_clientId'),
      );
      
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _messageController.add(data);
        },
        onDone: () {
          _isConnected = false;
          _scheduleReconnect();
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

    } catch (e) {
      print('WebSocket Connection Error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && _clientId != null) {
        _connectToServer();
      }
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      _channel!.sink.add(json.encode(message));
    }
  }

  void sendChatMessage(String content) {
    sendMessage({
      'type': 'message',
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendTypingStatus(bool isTyping) {
    sendMessage({
      'type': 'typing',
      'is_typing': isTyping,
    });
  }

  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _messageController.close();
  }
}