import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/server.dart';

class ServerProvider with ChangeNotifier {
  List<Server> _servers = [];
  Server? _selectedServer;
  String? _currentChannel;
  
  List<Server> get servers => List.unmodifiable(_servers);
  Server? get selectedServer => _selectedServer;
  String? get currentChannel => _currentChannel;

  Future<void> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = prefs.getString('servers');
    if (serversJson != null) {
      final List<dynamic> serversList = jsonDecode(serversJson);
      _servers = serversList.map((e) => Server.fromJson(e)).toList();
      
      final selectedServerId = prefs.getString('selected_server');
      if (selectedServerId != null && _servers.isNotEmpty) {
        _selectedServer = _servers.firstWhere(
          (server) => server.id == selectedServerId,
          orElse: () => _servers.first,
        );
      }
      
      _currentChannel = prefs.getString('current_channel');
    }
    notifyListeners();
  }

  Future<void> saveServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = jsonEncode(_servers.map((e) => e.toJson()).toList());
    await prefs.setString('servers', serversJson);
    if (_selectedServer != null) {
      await prefs.setString('selected_server', _selectedServer!.id);
    }
    if (_currentChannel != null) {
      await prefs.setString('current_channel', _currentChannel!);
    }
  }

  Future<void> addServer(Server server) async {
    _servers.add(server);
    if (_servers.length == 1) {
      _selectedServer = server;
    }
    await saveServers();
    notifyListeners();
  }

  Future<void> updateServer(Server server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index != -1) {
      _servers[index] = server;
      if (_selectedServer?.id == server.id) {
        _selectedServer = server;
      }
      await saveServers();
      notifyListeners();
    }
  }

  Future<void> deleteServer(String serverId) async {
    _servers.removeWhere((server) => server.id == serverId);
    if (_selectedServer?.id == serverId) {
      _selectedServer = _servers.isNotEmpty ? _servers.first : null;
      _currentChannel = null;
    }
    await saveServers();
    notifyListeners();
  }

  Future<void> selectServer(String serverId) async {
    final server = _servers.firstWhere((s) => s.id == serverId);
    _selectedServer = server;
    _currentChannel = null;
    await saveServers();
    notifyListeners();
  }

  Future<void> selectChannel(String channelId) async {
    _currentChannel = channelId;
    await saveServers();
    notifyListeners();
  }
}