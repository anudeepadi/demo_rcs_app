enum MediaType {
  text,
  image,
  gif,
  video,
  youtube
}

class Message {
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final MediaType mediaType;

  Message({
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.mediaType = MediaType.text,
  });
}