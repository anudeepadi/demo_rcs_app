import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/giphy_service.dart';

class GifMessage extends StatelessWidget {
  final GiphyGif gif;
  final bool isOutgoing;
  final VoidCallback? onTap;
  final double maxWidth;
  
  const GifMessage({
    Key? key,
    required this.gif,
    this.isOutgoing = false,
    this.onTap,
    this.maxWidth = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final image = gif.images['fixed_width']!;
    final aspectRatio = image.width / image.height;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxWidth / aspectRatio,
        ),
        child: Card(
          color: isOutgoing ? colorScheme.primaryContainer : colorScheme.surfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isOutgoing 
                      ? colorScheme.primaryContainer 
                      : colorScheme.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.errorContainer,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load GIF',
                          style: TextStyle(
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onTap != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}