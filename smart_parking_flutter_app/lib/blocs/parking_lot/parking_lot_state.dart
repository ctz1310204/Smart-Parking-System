part of 'parking_lot_cubit.dart'; // Liên kết với file parking_lot_cubit.dart

// Định nghĩa các trạng thái có thể có của dữ liệu bãi đỗ xe và các hành động liên quan
abstract class ParkingLotState extends Equatable {
  const ParkingLotState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class ParkingLotInitial extends ParkingLotState {}

// Trạng thái đang tải dữ liệu
class ParkingLotLoading extends ParkingLotState {}

// Trạng thái tải dữ liệu thành công
class ParkingLotLoaded extends ParkingLotState {
  final ParkingLot parkingLot; // Dữ liệu bãi đỗ xe đã tải

  const ParkingLotLoaded(this.parkingLot);

  @override
  List<Object?> get props => [parkingLot];
}

// Trạng thái lỗi khi tải dữ liệu hoặc thực hiện hành động
class ParkingLotError extends ParkingLotState {
  final String message;
  // Có thể giữ lại trạng thái data cũ khi có lỗi hành động (ví dụ đặt chỗ lỗi)
  final ParkingLot? currentParkingLot;

  const ParkingLotError(this.message, {this.currentParkingLot});

  @override
  List<Object?> get props => [message, currentParkingLot];
}

// Trạng thái đang thực hiện hành động (ví dụ: đang đặt chỗ, đang hủy chỗ)
class ParkingLotActionInProgress extends ParkingLotState {
  // Có thể giữ lại trạng thái data cũ trong khi loading hành động
  final ParkingLot? currentParkingLot;
  final String actionMessage; // Thông báo hành động đang diễn ra

  const ParkingLotActionInProgress(
    this.actionMessage, {
    this.currentParkingLot,
  });

  @override
  List<Object?> get props => [actionMessage, currentParkingLot];
}

// Có thể thêm trạng thái cho hành động thành công nếu cần hiển thị thông báo riêng (tùy chọn)
/*
class ParkingLotActionSuccess extends ParkingLotState {
   final String successMessage;
   final ParkingLot parkingLot; // Dữ liệu sau khi hành động thành công
   const ParkingLotActionSuccess(this.successMessage, this.parkingLot);
    @override
   List<Object?> get props => [successMessage, parkingLot];
}
*/
