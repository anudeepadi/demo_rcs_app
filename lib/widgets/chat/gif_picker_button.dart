import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../giphy/giphy_picker.dart';
import '../../providers/gif_message_provider.dart';
import '../../services/giphy_service.dart';

class GifPickerButton extends StatelessWidget {
  final String senderId;
  final VoidCallback? onPickingStarted;
  final VoidCallback? onPickingEnded;

  const GifPickerButton({
    Key? key,
    required this.senderId,
    this.onPickingStarted,
    this.onPickingEnded,
  }) : super(key: key);

  void _showGifPicker(BuildContext context) {
    onPickingStarted?.call();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiphyPicker(
        onGifSelected: (gif) {
          _handleGifSelected(context, gif);
          Navigator.pop(context);
        },
      ),
    ).then((_) => onPickingEnded?.call());
  }

  Future<void> _handleGifSelected(BuildContext context, GiphyGif gif) async {
    try {
      final provider = context.read<GifMessageProvider>();
      await provider.sendGifMessage(
        senderId: senderId,
        gif: gif,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send GIF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return IconButton(
      icon: Icon(
        Icons.gif_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Send GIF',
      onPressed: () => _showGifPicker(context),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}