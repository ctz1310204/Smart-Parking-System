// lib/services/firebase_db_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../models/parking_lot.dart';
import '../models/booking.dart';

class FirebaseDbService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Stream để lắng nghe thay đổi dữ liệu bãi đỗ xe theo thời gian thực
  Stream<ParkingLot?> getParkingLotStream(String lotId) {
    return _databaseRef.child('parking_lots/$lotId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        return ParkingLot.fromJson(lotId, data);
      }
      return null;
    });
  }

  // Tạo một đặt chỗ mới
  Future<bool> createBooking({
    required String userId, // UID Firebase Auth
    required String phoneNumber,
    required String lotId,
    required String spotId,
    required DateTime startTime,
    required DateTime? endTime, // Thời gian kết thúc có thể là null
    required String rfidTagExpected,
  }) async {
    try {
      final newBookingRef = _databaseRef.child('bookings').push();
      final bookingId = newBookingRef.key;

      if (bookingId == null) {
        print("Error: Could not generate booking ID.");
        return false;
      }

      // Tạo đối tượng Booking với trạng thái ban đầu là 'confirmed'
      final newBooking = Booking(
        id: bookingId,
        userId: userId,
        phoneNumber: phoneNumber,
        lotId: lotId,
        spotId: spotId,
        bookingCreationTime: DateTime.now().toIso8601String(),
        bookingStartTime: startTime.toIso8601String(),
        bookingEndTime: endTime?.toIso8601String(),
        rfidTagExpected: rfidTagExpected,
        status: 'confirmed', // Đặt trạng thái ban đầu là 'confirmed'
      );

      // Lưu Booking vào Firebase
      Map<String, dynamic> bookingData = newBooking.toJson();
      await newBookingRef.set(bookingData);

      // Cập nhật trạng thái của Spot trong bãi đỗ xe
      await _databaseRef.child('parking_lots/$lotId/spots/$spotId').update({
        'status': 'reserved', // Chỗ đỗ được đánh dấu là "đã đặt"
        'userID': userId,
        'booking_ref': bookingId,
        'rfid_tag': rfidTagExpected,
        'phone_number': phoneNumber,
        'booking_start_time': startTime.toIso8601String(),
        'booking_end_time': endTime?.toIso8601String(),
      });

      print("Booking created successfully: $bookingId");
      return true;
    } catch (e) {
      print("Error creating booking: $e");
      return false;
    }
  }

  // Hủy đặt chỗ (xóa hẳn booking và cập nhật trạng thái spot)
  Future<bool> cancelBooking({
    required String bookingId,
    required String lotId,
    required String spotId,
  }) async {
    try {
      // Xóa hẳn booking khỏi collection 'bookings'
      await _databaseRef.child('bookings/$bookingId').remove();

      // Cập nhật trạng thái của Spot trong bãi đỗ xe trở lại 'empty'
      // Đồng thời xóa các thông tin liên quan đến booking trên spot
      await _databaseRef.child('parking_lots/$lotId/spots/$spotId').update({
        'status': 'empty',
        'userID': null, // Xóa user ID liên quan
        'booking_ref': null, // Xóa tham chiếu booking
        'rfid_tag': null, // Xóa RFID tag
        'phone_number': null, // Xóa số điện thoại
        'time_in': null, // Xóa thời gian vào (nếu có)
        'time_out': null, // Xóa thời gian ra (nếu có)
        'booking_start_time': null, // Xóa thời gian bắt đầu dự kiến
        'booking_end_time': null, // Xóa thời gian kết thúc dự kiến
      });

      print("Booking cancelled successfully: $bookingId");
      return true;
    } catch (e) {
      print("Error cancelling booking: $e");
      return false;
    }
  }

  // Phương thức để cập nhật trạng thái spot khi xe vào/ra (đây là logic bạn sẽ cần ở Node-RED)
  // Tuy nhiên, bạn cũng có thể định nghĩa nó ở đây nếu muốn có cách gọi thủ công từ app
  // Ví dụ:
  /*
  Future<bool> updateSpotStatus({
    required String lotId,
    required String spotId,
    required String newStatus, // 'occupied' hoặc 'empty'
    String? rfidTag,
    String? timeIn, // Nếu status là 'occupied'
    String? timeOut, // Nếu status là 'empty'
    String? userId,
    String? bookingRef,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'status': newStatus,
        'rfid_tag': rfidTag,
        'time_in': timeIn,
        'time_out': timeOut,
        'userID': userId,
        'booking_ref': bookingRef,
        'phone_number': phoneNumber,
        // ... các trường khác cần cập nhật hoặc reset
      };
      // Loại bỏ các giá trị null khỏi map để không ghi đè giá trị cũ bằng null một cách không mong muốn
      updates.removeWhere((key, value) => value == null);

      await _databaseRef.child('parking_lots/$lotId/spots/$spotId').update(updates);
      print("Spot $spotId status updated to $newStatus");
      return true;
    } catch (e) {
      print("Error updating spot status: $e");
      return false;
    }
  }
  */
}
