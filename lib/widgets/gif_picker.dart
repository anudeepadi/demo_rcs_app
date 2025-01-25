import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' show pow, log;

class GifPicker extends StatefulWidget {
  final Function(String) onGifSelected;

  const GifPicker({
    Key? key,
    required this.onGifSelected,
  }) : super(key: key);

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _gifs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTrendingGifs();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchQuery) {
        _searchQuery = _searchController.text;
        if (_searchQuery.isEmpty) {
          _loadTrendingGifs();
        } else {
          _searchGifs(_searchQuery);
        }
      }
    });
  }

  Future<void> _loadTrendingGifs() async {
    setState(() => _isLoading = true);
    try {
      // Here you would typically use a GIF API like GIPHY or Tenor
      // For demo purposes, we'll use placeholder GIFs
      _gifs = List.generate(20, (index) => 
        'https://via.placeholder.com/200x200.gif?text=GIF+$index'
      );
    } catch (e) {
      debugPrint('Error loading GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchGifs(String query) async {
    setState(() => _isLoading = true);
    try {
      // Here you would typically search using a GIF API
      // For demo purposes, we'll use placeholder GIFs
      _gifs = List.generate(10, (index) => 
        'https://via.placeholder.com/200x200.gif?text=$query+$index'
      );
    } catch (e) {
      debugPrint('Error searching GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search GIFs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _gifs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => widget.onGifSelected(_gifs[index]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _gifs[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}