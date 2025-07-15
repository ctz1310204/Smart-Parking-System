import 'package:flutter/material.dart';
import '../models/spot.dart'; //

class SpotWidget extends StatelessWidget {
  final Spot spot; //
  final VoidCallback? onTap; //

  const SpotWidget({Key? key, required this.spot, this.onTap})
    : super(key: key); //

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'empty': //
        return Colors.green; //
      case 'reserved': //
        return Colors.orange; //
      case 'occupied': //
        return Colors.red; //
      case 'pending_entries': // THÊM CASE NÀY hoặc SỬA ĐỔI
        return Colors.amber; // Ví dụ: Màu vàng hổ phách
      default: //
        return Colors.grey; //
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'empty': //
        return Icons.check_circle_outline; //
      case 'reserved': //
        return Icons.access_time; //
      case 'occupied': //
        return Icons.directions_car; //
      case 'pending_entries': // THÊM CASE NÀY hoặc SỬA ĐỔI
        return Icons.directions_walk; // Ví dụ: icon người đang đi
      default: //
        return Icons.help_outline; //
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Sử dụng InkWell để có hiệu ứng tap
      onTap: onTap, //
      child: Container(
        margin: EdgeInsets.all(4.0), //
        decoration: BoxDecoration(
          color: _getStatusColor(spot.status), //
          borderRadius: BorderRadius.circular(8.0), //
          boxShadow: [
            //
            BoxShadow(
              //
              color: Colors.black.withOpacity(0.2), //
              spreadRadius: 1, //
              blurRadius: 3, //
              offset: Offset(0, 2), //
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //
          children: [
            Icon(_getStatusIcon(spot.status), color: Colors.white, size: 30), //
            SizedBox(height: 4), //
            Text(
              spot.id.toUpperCase(), //
              style: TextStyle(
                //
                color: Colors.white, //
                fontWeight: FontWeight.bold, //
                fontSize: 16, //
              ),
            ),
            Text(
              spot.status.toUpperCase(), //
              style: TextStyle(color: Colors.white70, fontSize: 12), //
            ),
          ],
        ),
      ),
    );
  }
}
