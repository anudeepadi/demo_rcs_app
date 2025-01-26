import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../models/channel.dart';
import '../services/api_service.dart';

class ChannelProvider extends ChangeNotifier {
  final List<Channel> _channels = [];
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;
  String? _selectedChannelId;
  bool _isLoading = false;

  List<Channel> get channels => _channels;
  String? get selectedChannelId => _selectedChannelId;
  bool get isLoading => _isLoading;

  ChannelProvider() {
    _initWebSocket();
    fetchChannels();
  }

  void _initWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws'),
    );

    _channel!.stream.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'new_message' && data['channel_id'] == _selectedChannelId) {
        // Handle new message
        notifyListeners();
      }
    });
  }

  Future<void> fetchChannels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final channels = await _apiService.getChannels();
      _channels.clear();
      _channels.addAll(channels);
    } catch (e) {
      print('Error fetching channels: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createChannel(String name, String description, {String? icon}) async {
    try {
      final channel = await _apiService.createChannel(
        Channel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          icon: icon,
        ),
      );
      _channels.add(channel);
      notifyListeners();
    } catch (e) {
      print('Error creating channel: $e');
      rethrow;
    }
  }

  void selectChannel(String channelId) {
    _selectedChannelId = channelId;
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}