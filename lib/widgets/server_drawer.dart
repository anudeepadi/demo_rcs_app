import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../models/server.dart';

class ServerDrawer extends StatelessWidget {
  const ServerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ServerProvider>(
        builder: (context, serverProvider, child) {
          final servers = serverProvider.servers;
          final selectedServer = serverProvider.selectedServer;

          return Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Center(
                  child: Text(
                    'RCS Servers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              if (servers.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No servers added yet'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final isSelected = server.id == selectedServer?.id;

                      return ExpansionTile(
                        title: Text(server.name),
                        leading: CircleAvatar(
                          child: Text(server.name[0]),
                        ),
                        initiallyExpanded: isSelected,
                        children: [
                          ...server.channels.map((channel) => ListTile(
                            leading: Icon(_getChannelIcon(channel.type)),
                            title: Text(channel.name),
                            selected: isSelected && serverProvider.currentChannel == channel.id,
                            onTap: () {
                              serverProvider.selectServer(server.id);
                              serverProvider.selectChannel(channel.id);
                              Navigator.pop(context);
                            },
                          )),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getChannelIcon(ChannelType type) {
    switch (type) {
      case ChannelType.text:
        return Icons.chat;
      case ChannelType.voice:
        return Icons.mic;
      case ChannelType.announcement:
        return Icons.campaign;
    }
  }
}