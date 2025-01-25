import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';
import '../providers/server_provider.dart';

class ServerSidebar extends StatelessWidget {
  const ServerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildServerHeader(context),
          const Divider(),
          Expanded(
            child: _buildServerList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildServerHeader(BuildContext context) {
    final currentServer = context.select((ServerProvider p) => p.currentServer);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentServer?.name ?? 'Select a Server',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement server addition
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(BuildContext context) {
    return Consumer<ServerProvider>(
      builder: (context, provider, child) {
        return ListView(
          children: [
            ...provider.servers.map((server) => _buildServerTile(context, server)),
          ],
        );
      },
    );
  }

  Widget _buildServerTile(BuildContext context, Server server) {
    final provider = Provider.of<ServerProvider>(context, listen: false);
    final isSelected = context.select(
      (ServerProvider p) => p.currentServer?.id == server.id,
    );

    return ExpansionTile(
      key: ValueKey(server.id),
      leading: server.iconUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(server.iconUrl!))
          : CircleAvatar(child: Text(server.name[0])),
      title: Text(server.name),
      initiallyExpanded: isSelected,
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      children: [
        ...server.channels.map((channel) => _buildChannelTile(
              context,
              channel,
              isSelected: provider.currentChannel?.id == channel.id,
            )),
      ],
    );
  }

  Widget _buildChannelTile(
    BuildContext context,
    Channel channel, {
    bool isSelected = false,
  }) {
    final provider = Provider.of<ServerProvider>(context, listen: false);

    return ListTile(
      leading: Icon(_getChannelIcon(channel.type)),
      title: Text(channel.name),
      selected: isSelected,
      onTap: () => provider.selectChannel(channel),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
    );
  }

  IconData _getChannelIcon(ChannelType type) {
    switch (type) {
      case ChannelType.text:
        return Icons.tag;
      case ChannelType.voice:
        return Icons.mic;
      case ChannelType.video:
        return Icons.videocam;
    }
  }
}