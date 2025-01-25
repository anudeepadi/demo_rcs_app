class Server {
  final String id;
  final String name;
  final String? iconUrl;
  final List<Channel> channels;

  Server({
    required this.id,
    required this.name,
    this.iconUrl,
    List<Channel>? channels,
  }) : channels = channels ?? [];

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String?,
      channels: (json['channels'] as List?)
          ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'channels': channels.map((e) => e.toJson()).toList(),
    };
  }
}

class Channel {
  final String id;
  final String name;
  final ChannelType type;
  final String serverId;

  Channel({
    required this.id,
    required this.name,
    required this.type,
    required this.serverId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ChannelType.values.firstWhere(
        (e) => e.toString() == 'ChannelType.${json['type']}',
        orElse: () => ChannelType.text,
      ),
      serverId: json['serverId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'serverId': serverId,
    };
  }
}

enum ChannelType {
  text,
  voice,
  video,
}