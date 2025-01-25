import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

class ChatDrawer extends StatefulWidget {
  final Function(String) onSelectChat;
  
  const ChatDrawer({
    super.key,
    required this.onSelectChat,
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final List<String> _chatRooms = ['General', 'Support', 'Feedback'];
  String _selectedRoom = 'General';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                'Chat Rooms',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chatRooms.length,
              itemBuilder: (context, index) {
                final room = _chatRooms[index];
                return ListTile(
                  leading: const Icon(Icons.chat),
                  title: Text(room),
                  selected: room == _selectedRoom,
                  onTap: () {
                    setState(() {
                      _selectedRoom = room;
                    });
                    widget.onSelectChat(room);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat Room'),
            onTap: () => _showAddRoomDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Chat Room'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            hintText: 'Enter room name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _chatRooms.add(name);
                  _selectedRoom = name;
                });
                widget.onSelectChat(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}