import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SuggestionBar extends StatelessWidget {
  const SuggestionBar({Key? key}) : super(key: key);

  static const List<String> _defaultSuggestions = [
    "What's new?",
    "Help",
    "Features",
    "Settings",
    "About",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: _defaultSuggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () {
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                chatProvider.addTextMessage(_defaultSuggestions[index]);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Text(_defaultSuggestions[index]),
            ),
          );
        },
      ),
    );
  }
}