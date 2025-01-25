class Server {
  final String id;
  final String name;
  final String url;
  final String? token;
  final String? iconUrl;
  final List<Channel> channels;
  final Map<String, dynamic>? headers;

  Server({
    required this.id,
    required this.name,
    required this.url,
    this.token,
    this.iconUrl,
    List<Channel>? channels,
    this.headers,
  }) : channels = channels ?? [];

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      token: json['token'] as String?,
      iconUrl: json['iconUrl'] as String?,
      channels: (json['channels'] as List<dynamic>?)
          ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      headers: json['headers'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'token': token,
      'iconUrl': iconUrl,
      'channels': channels.map((e) => e.toJson()).toList(),
      'headers': headers,
    };
  }

  Server copyWith({
    String? id,
    String? name,
    String? url,
    String? token,
    String? iconUrl,
    List<Channel>? channels,
    Map<String, dynamic>? headers,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      token: token ?? this.token,
      iconUrl: iconUrl ?? this.iconUrl,
      channels: channels ?? this.channels,
      headers: headers ?? this.headers,
    );
  }
}

enum ChannelType {
  text,
  voice,
  announcement
}

class Channel {
  final String id;
  final String name;
  final ChannelType type;
  final String? iconUrl;
  final int? unreadCount;

  Channel({
    required this.id,
    required this.name,
    this.type = ChannelType.text,
    this.iconUrl,
    this.unreadCount,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ChannelType.values.firstWhere(
        (e) => e.toString() == 'ChannelType.${json['type']}',
        orElse: () => ChannelType.text,
      ),
      iconUrl: json['iconUrl'] as String?,
      unreadCount: json['unreadCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'iconUrl': iconUrl,
      'unreadCount': unreadCount,
    };
  }

  Channel copyWith({
    String? id,
    String? name,
    ChannelType? type,
    String? iconUrl,
    int? unreadCount,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconUrl: iconUrl ?? this.iconUrl,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}