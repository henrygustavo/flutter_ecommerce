import 'dart:ui';

import 'package:flutter/material.dart';

class MessageNotification {
  final String title;
  final String body;
  final Color color;
  const MessageNotification(
      {@required this.title, @required this.body, @required this.color});
}