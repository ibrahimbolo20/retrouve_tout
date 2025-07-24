import 'package:flutter/material.dart';

class CityItem extends StatelessWidget {
  final String city;
  final String count;
  final String rank;

  CityItem({required this.city, required this.count, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              city,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
            ),
          ),
          Text(
            count,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}