import 'package:flutter/material.dart';

class SuccessItem extends StatelessWidget {
  final String item;
  final String location;
  final String time;
  final String status;

  SuccessItem({required this.item, required this.location, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                Text('$location - $time', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(status, style: TextStyle(fontSize: 14, color: Colors.green)),
        ],
      ),
    );
  }
}