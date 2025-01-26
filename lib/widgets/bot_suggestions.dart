import 'package:flutter/material.dart';
import '../services/bot_service.dart';

class BotSuggestions extends StatelessWidget {
  final Function(String) onSuggestionSelected;

  const BotSuggestions({
    Key? key,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestions = BotService.getSuggestedResponses();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            onTap: () => onSuggestionSelected(suggestions[index]),
            title: Text(
              suggestions[index],
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}