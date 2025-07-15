import 'spot.dart';

class ParkingLot {
  final String id;
  final int totalSpots;
  int availableSpots;
  final String location;
  final String name;
  final List<Spot> spots;

  ParkingLot({
    required this.id,
    required this.totalSpots,
    required this.availableSpots,
    required this.location,
    required this.name,
    required this.spots,
  });

  factory ParkingLot.fromJson(String id, Map<dynamic, dynamic> json) {
    var spotsList = <Spot>[];
    if (json['spots'] != null) {
      json['spots'].forEach((spotId, spotData) {
        if (spotData is Map) {
          spotsList.add(Spot.fromJson(spotId, spotData));
        }
      });
      // Sắp xếp các spots theo ID (ví dụ: spot_1, spot_2)
      spotsList.sort((a, b) => a.id.compareTo(b.id));
    }

    // Đảm bảo totalSpots là một số nguyên, mặc định là 0 nếu null hoặc sai định dạng
    final int totalSpots =
        int.tryParse(json['total_spots']?.toString() ?? '0') ?? 0;
    // Đảm bảo availableSpots là một số nguyên
    final int availableSpots =
        int.tryParse(json['available_spots']?.toString() ?? '0') ?? 0;

    return ParkingLot(
      id: id,
      totalSpots: totalSpots, // Lấy từ JSON
      availableSpots: availableSpots, // Lấy từ JSON
      location: json['location'] ?? 'Unknown Location',
      name: json['name'] ?? 'Unknown Lot',
      spots: spotsList,
    );
  }
}
