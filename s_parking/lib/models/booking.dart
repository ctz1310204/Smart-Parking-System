// lib/models/booking.dart

class Booking {
  final String id;
  final String userId; // UID Firebase Auth
  final String phoneNumber; // Thêm trường phoneNumber
  final String lotId;
  final String spotId;
  final String bookingCreationTime;
  final String bookingStartTime;
  final String? bookingEndTime; // Có thể là null
  final String rfidTagExpected; // Bắt buộc

  final String
  status; // 'confirmed', 'active', 'completed', 'cancelled', 'expired'

  Booking({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.lotId,
    required this.spotId,
    required this.bookingCreationTime,
    required this.bookingStartTime,
    this.bookingEndTime,
    required this.rfidTagExpected,
    required this.status,
  });

  factory Booking.fromJson(String id, Map<dynamic, dynamic> json) {
    return Booking(
      id: id,
      userId: json['userID'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      lotId: json['lot_ID'] ?? '',
      spotId: json['spot_ID'] ?? '',
      bookingCreationTime: json['booking_creation_time'] ?? '',
      bookingStartTime: json['booking_start_time'] ?? '',
      bookingEndTime: json['booking_end_time'],
      rfidTagExpected: json['rfid_tag_expected'] ?? '',
      status: json['status'] ?? 'unknown', // Đảm bảo đọc đúng từ JSON
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'phone_number': phoneNumber,
      'lot_ID': lotId,
      'spot_ID': spotId,
      'booking_creation_time': bookingCreationTime,
      'booking_start_time': bookingStartTime,
      'booking_end_time': bookingEndTime,
      'rfid_tag_expected': rfidTagExpected,
      'status': status,
    };
  }
}
