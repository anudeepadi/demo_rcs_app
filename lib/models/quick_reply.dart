import 'package:flutter/material.dart';

class QuickReply {
  final String id;
  final String text;
  final String? postbackData;
  final IconData? icon;

  QuickReply({
    required this.id,
    required this.text,
    this.postbackData,
    this.icon,
  });
}