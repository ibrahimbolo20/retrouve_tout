import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications'), backgroundColor: Colors.white, elevation: 0),
      body: Center(child: Text('Aucune notification pour le moment')),
    );
  }
}