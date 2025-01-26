import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';
import '../models/channel.dart';

class ChannelList extends StatelessWidget {
  const ChannelList({Key? key}) : super(key: key);

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, child) {
        if (channelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (channelProvider.channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No channels yet',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Show add channel dialog
                  },
                  child: const Text('Create Channel'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: channelProvider.channels.length,
          itemBuilder: (context, index) {
            final channel = channelProvider.channels[index];
            return ChannelListTile(
              channel: channel,
              isSelected: channel.id == channelProvider.selectedChannelId,
              onTap: () => channelProvider.selectChannel(channel.id),
            );
          },
        );
      },
    );
  }
}

class ChannelListTile extends StatelessWidget {
  final Channel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const ChannelListTile({
    Key? key,
    required this.channel,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  channel.name[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (channel.lastMessageTime != null)
                          Text(
                            _formatTimestamp(channel.lastMessageTime),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                    if (channel.lastMessagePreview != null)
                      Text(
                        channel.lastMessagePreview!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (channel.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    channel.unreadCount.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}