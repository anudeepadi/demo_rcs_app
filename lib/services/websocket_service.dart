import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws'),
      );
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          onMessageReceived?.call(data);
        },
        onDone: () {
          onDisconnected?.call();
          _reconnect();
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _reconnect();
        },
      );
      onConnected?.call();
    } catch (e) {
      print('WebSocket Connection Error: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}