import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/message_notification.dart';
class MessagingWidget extends StatefulWidget {
  
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {

  final List<MessageNotification> notifications = [];
  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {

     final MessageNotification args = ModalRoute.of(context).settings.arguments;
      notifications.add(args);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: notifications.map(buildNotification).toList(),
      ),
    );
  }

  Widget buildNotification(MessageNotification notification) {
    
    return ListTile(
      title: Text(
        notification.title,
        style: TextStyle(
          color: notification.color,
        ),
      ),
      subtitle: Text(notification.body),
    );
  }
}
