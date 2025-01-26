import 'package:flutter/material.dart';

class QuickReply {
  final String text;
  final String value;
  final IconData? icon;

  QuickReply({
    required this.text,
    required this.value,
    this.icon,
  });
}