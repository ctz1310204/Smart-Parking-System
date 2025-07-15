// lib/models/spot.dart

class Spot {
  final String id;
  String status; // empty, reserved, occupied
  String? rfidTag;
  String? timeIn; // Thời gian xe thực tế vào
  String? timeOut; // Thời gian xe thực tế ra
  String? userId; // UID của Firebase Auth của người đặt/đỗ
  String? bookingRef; // ID của booking liên quan
  String? phoneNumber; // Thêm số điện thoại của người đặt
  String? bookingStartTime; // Thời gian bắt đầu dự kiến của booking
  String? bookingEndTime; // Thời gian kết thúc dự kiến của booking

  Spot({
    required this.id,
    required this.status,
    this.rfidTag,
    this.timeIn,
    this.timeOut,
    this.userId,
    this.bookingRef,
    this.phoneNumber, // Cập nhật constructor
    this.bookingStartTime, // Cập nhật constructor
    this.bookingEndTime, // Cập nhật constructor
  });

  factory Spot.fromJson(String id, Map<dynamic, dynamic> json) {
    return Spot(
      id: id,
      status: json['status'] ?? 'unknown',
      rfidTag: json['rfid_tag'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      userId: json['userID'], // Chú ý key là 'userID' trong JSON
      bookingRef: json['booking_ref'],
      phoneNumber: json['phone_number'], // Đọc phoneNumber từ JSON
      bookingStartTime:
          json['booking_start_time'], // Đọc thời gian bắt đầu dự kiến từ JSON
      bookingEndTime:
          json['booking_end_time'], // Đọc thời gian kết thúc dự kiến từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'rfid_tag': rfidTag,
      'time_in': timeIn,
      'time_out': timeOut,
      'userID': userId,
      'booking_ref': bookingRef,
      'phone_number': phoneNumber, // Ghi phoneNumber vào JSON
      'booking_start_time':
          bookingStartTime, // Ghi thời gian bắt đầu dự kiến vào JSON
      'booking_end_time':
          bookingEndTime, // Ghi thời gian kết thúc dự kiến vào JSON
    };
  }
}
