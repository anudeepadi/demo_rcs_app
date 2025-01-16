import 'package:flutter/material.dart';

class ChatDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const ChatDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.chat, size: 40, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'RCS Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildChatItem(
                  context,
                  index: 0,
                  title: 'Bot Chat',
                  subtitle: 'Quick Replies & Media',
                  icon: Icons.android,
                ),
                _buildChatItem(
                  context,
                  index: 1,
                  title: 'API Chat',
                  subtitle: 'localhost:3000',
                  icon: Icons.api,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.2),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        selected: isSelected,
        onTap: () => onSelect(index),
      ),
    );
  }
}