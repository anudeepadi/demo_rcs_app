class LinkPreview {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;

  LinkPreview({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
  });

  factory LinkPreview.fromJson(Map<String, dynamic> json) {
    return LinkPreview(
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      siteName: json['siteName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'siteName': siteName,
    };
  }
}