import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../models/server.dart';

class ServerSidebar extends StatelessWidget {
  const ServerSidebar({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerProvider>(
      builder: (context, serverProvider, child) {
        final selectedServer = serverProvider.selectedServer;
        final currentChannel = serverProvider.currentChannel;

        if (selectedServer == null) {
          return const Center(
            child: Text('No server selected'),
          );
        }

        return Container(
          width: 250,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedServer.iconUrl != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(selectedServer.iconUrl!),
                      )
                    else
                      CircleAvatar(
                        child: Text(selectedServer.name[0]),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedServer.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedServer.channels.length,
                  itemBuilder: (context, index) {
                    final channel = selectedServer.channels[index];
                    final isSelected = channel.id == currentChannel;
                    
                    return ListTile(
                      leading: Icon(_getChannelIcon(channel.type)),
                      title: Text(channel.name),
                      trailing: channel.unreadCount != null && channel.unreadCount! > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                channel.unreadCount.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.1),
                      onTap: () {
                        serverProvider.selectChannel(channel.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}