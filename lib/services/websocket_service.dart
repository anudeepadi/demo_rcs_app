// This class is kept for future online functionality
// Currently only serving as a placeholder
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();
}