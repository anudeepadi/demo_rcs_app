import 'package:flutter/material.dart';

class QuickReply {
  final String id;
  final String text;
  final String value;
  final IconData? icon;
  final String? iconName;
  final String? payload;
  final bool isEnabled;

  QuickReply({
    required this.id,
    required this.text,
    required this.value,
    this.icon,
    this.iconName,
    this.payload,
    this.isEnabled = true,
  });

  factory QuickReply.fromString(String text) {
    return QuickReply(
      id: text.toLowerCase().replaceAll(' ', '_'),
      text: text,
      value: text,
    );
  }

  QuickReply copyWith({
    String? id,
    String? text,
    String? value,
    IconData? icon,
    String? iconName,
    String? payload,
    bool? isEnabled,
  }) {
    return QuickReply(
      id: id ?? this.id,
      text: text ?? this.text,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      payload: payload ?? this.payload,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] as String,
      text: json['text'] as String,
      value: json['value'] as String,
      icon: json['icon'] != null ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons') : null,
      iconName: json['iconName'] as String?,
      payload: json['payload'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'value': value,
      'icon': icon?.codePoint,
      'iconName': iconName,
      'payload': payload,
      'isEnabled': isEnabled,
    };
  }
}