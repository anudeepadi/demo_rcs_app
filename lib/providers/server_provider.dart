import 'package:flutter/foundation.dart';
import '../models/server.dart';

class ServerProvider with ChangeNotifier {
  final List<Server> _servers = [];
  Server? _currentServer;
  Channel? _currentChannel;

  List<Server> get servers => List.unmodifiable(_servers);
  Server? get currentServer => _currentServer;
  Channel? get currentChannel => _currentChannel;

  ServerProvider() {
    _loadInitialServers();
  }

  void _loadInitialServers() {
    // Add mock servers for demo
    _addServer(Server(
      id: '1',
      name: 'General',
      channels: [
        Channel(id: '1', name: 'general', type: ChannelType.text, serverId: '1'),
        Channel(id: '2', name: 'media', type: ChannelType.text, serverId: '1'),
        Channel(id: '3', name: 'voice-chat', type: ChannelType.voice, serverId: '1'),
      ],
    ));

    _addServer(Server(
      id: '2',
      name: 'Media',
      channels: [
        Channel(id: '4', name: 'images', type: ChannelType.text, serverId: '2'),
        Channel(id: '5', name: 'videos', type: ChannelType.text, serverId: '2'),
        Channel(id: '6', name: 'video-chat', type: ChannelType.video, serverId: '2'),
      ],
    ));

    // Set initial selections
    if (_servers.isNotEmpty) {
      _currentServer = _servers.first;
      if (_currentServer!.channels.isNotEmpty) {
        _currentChannel = _currentServer!.channels.first;
      }
    }

    notifyListeners();
  }

  void _addServer(Server server) {
    if (!_servers.any((s) => s.id == server.id)) {
      _servers.add(server);
      notifyListeners();
    }
  }

  void selectServer(Server server) {
    _currentServer = server;
    _currentChannel = server.channels.isNotEmpty ? server.channels.first : null;
    notifyListeners();
  }

  void selectChannel(Channel channel) {
    _currentChannel = channel;
    notifyListeners();
  }
}