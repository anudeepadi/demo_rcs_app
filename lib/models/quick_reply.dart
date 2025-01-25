class QuickReply {
  final String id;
  final String text;
  final String? postbackData;
  final String? imageUrl;

  QuickReply({
    required this.id,
    required this.text,
    this.postbackData,
    this.imageUrl,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] as String,
      text: json['text'] as String,
      postbackData: json['postbackData'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'postbackData': postbackData,
      'imageUrl': imageUrl,
    };
  }
}