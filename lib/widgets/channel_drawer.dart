import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChannelDrawer extends StatelessWidget {
  const ChannelDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(),
          _buildChannelList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'RCS Demo User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implement settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChannelList(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildChannelTile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'General Chat',
            subtitle: 'Welcome to RCS Demo',
            isActive: true,
          ),
          _buildChannelTile(
            context,
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            subtitle: 'Important updates',
          ),
          _buildChannelTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
          ),
          const Divider(),
          _buildHeader2('Features'),
          _buildFeatureTile(
            context,
            icon: Icons.image_outlined,
            title: 'Media Sharing',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.gif_box_outlined,
            title: 'GIFs & Stickers',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.link_outlined,
            title: 'Rich Link Previews',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.reply_outlined,
            title: 'Quick Replies',
          ),
          const Divider(),
          _buildHeader2('Other'),
          _buildFeatureTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report Issue',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader2(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildChannelTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : null,
          color: isActive ? Theme.of(context).primaryColor : null,
        ),
      ),
      subtitle: Text(subtitle),
      selected: isActive,
      onTap: () {
        // Switch channel
      },
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Show feature details
      },
    );
  }
}