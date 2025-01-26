import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/giphy_service.dart';

class GiphyPicker extends StatefulWidget {
  final Function(GiphyGif) onGifSelected;
  final double height;
  
  const GiphyPicker({
    Key? key,
    required this.onGifSelected,
    this.height = 300,
  }) : super(key: key);

  @override
  State<GiphyPicker> createState() => _GiphyPickerState();
}

class _GiphyPickerState extends State<GiphyPicker> {
  final GiphyService _giphyService = GiphyService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Timer? _debounce;
  List<GiphyGif> _gifs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTrendingGifs();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreGifs();
    }
  }

  Future<void> _loadTrendingGifs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentQuery = '';
    });

    try {
      final gifs = await _giphyService.getTrendingGifs(offset: _offset);
      setState(() {
        _gifs = gifs;
        _offset = gifs.length;
        _hasMore = gifs.length == 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load trending GIFs');
    }
  }

  Future<void> _searchGifs(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _loadTrendingGifs();
        return;
      }

      setState(() {
        _isLoading = true;
        _currentQuery = query;
        _offset = 0;
      });

      try {
        final gifs = await _giphyService.searchGifs(query);
        setState(() {
          _gifs = gifs;
          _offset = gifs.length;
          _hasMore = gifs.length == 20;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to search GIFs');
      }
    });
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final gifs = _currentQuery.isEmpty
          ? await _giphyService.getTrendingGifs(offset: _offset)
          : await _giphyService.searchGifs(_currentQuery, offset: _offset);

      setState(() {
        _gifs.addAll(gifs);
        _offset += gifs.length;
        _hasMore = gifs.length == 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load more GIFs');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search GIFs...',
              leading: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                    onPressed: () {
                      _searchController.clear();
                      _loadTrendingGifs();
                    },
                  ),
              ],
              onChanged: _searchGifs,
              backgroundColor: MaterialStateProperty.all(colorScheme.surfaceVariant),
              elevation: MaterialStateProperty.all(0),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          // GIF grid
          Expanded(
            child: _gifs.isEmpty && !_isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gif_box_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentQuery.isEmpty ? 'No trending GIFs' : 'No GIFs found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MasonryGridView.count(
                    controller: _scrollController,
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: _gifs.length + (_isLoading ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _gifs.length) {
                        return _buildShimmerItem();
                      }
                      return _buildGifItem(gif: _gifs[index]);
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGifItem({required GiphyGif gif}) {
    final image = gif.images['fixed_width']!;
    final aspectRatio = image.width / image.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onGifSelected(gif),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildShimmerItem(),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onGifSelected(gif),
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}