import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';
import '../providers/server_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/server_drawer.dart';
import '../widgets/chat_input.dart';
import '../widgets/quick_reply_bar.dart';
import '../widgets/bot_suggestions.dart';
import '../widgets/message_bubble.dart';  // Added this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('RCS Demo'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServerDialog(context),
          ),
        ],
      ),
      drawer: const ServerDrawer(),
      body: Column(
        children: [
          // Quick Reply Bar at top
          const QuickReplyBar(),
          
          // Chat Messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.currentMessages[index];
                    return MessageBubble(
                      message: message,
                      showSuggestions: !message.isUser && index == chatProvider.currentMessages.length - 1,
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom Input Area
          const ChatInput(),
        ],
      ),
    );
  }

  Future<void> _showAddServerDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Server Name',
                hintText: 'Enter server name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Server URL (Optional)',
                hintText: 'Enter server URL for API connection',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final serverProvider = Provider.of<ServerProvider>(
                  context,
                  listen: false,
                );
                
                final newServer = Server(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  url: urlController.text,
                  channels: [
                    Channel(
                      id: 'general',
                      name: 'General',
                      type: ChannelType.text,
                    ),
                  ],
                );

                serverProvider.addServer(newServer);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Server'),
          ),
        ],
      ),
    );
  }
}