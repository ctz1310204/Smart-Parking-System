// lib/blocs/parking_lot/parking_lot_cubic.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/parking_lot.dart';
import '../../services/firebase_db_service.dart';

part 'parking_lot_state.dart';

class ParkingLotCubit extends Cubit<ParkingLotState> {
  final FirebaseDbService _dbService;
  StreamSubscription<ParkingLot?>? _parkingLotSubscription;

  final String parkingLotId;

  ParkingLotCubit(this._dbService, this.parkingLotId)
    : super(ParkingLotInitial()) {
    loadParkingLot();
  }

  void loadParkingLot() {
    emit(ParkingLotLoading());
    _parkingLotSubscription?.cancel();
    _parkingLotSubscription = _dbService
        .getParkingLotStream(parkingLotId)
        .listen(
          (parkingLot) {
            if (parkingLot != null) {
              emit(ParkingLotLoaded(parkingLot));
            } else {
              final currentState = state;
              final currentParkingLot =
                  currentState is ParkingLotLoaded
                      ? currentState.parkingLot
                      : null;
              emit(
                ParkingLotError(
                  'Không thể tải dữ liệu bãi đỗ xe.',
                  currentParkingLot: currentParkingLot,
                ),
              );
            }
          },
          onError: (error) {
            final currentState = state;
            final currentParkingLot =
                currentState is ParkingLotLoaded
                    ? currentState.parkingLot
                    : null;
            emit(
              ParkingLotError(
                'Lỗi stream dữ liệu bãi đỗ: ${error.toString()}',
                currentParkingLot: currentParkingLot,
              ),
            );
          },
        );
  }

  Future<void> createBooking({
    required String userId,
    required String phoneNumber,
    required String spotId,
    required DateTime startTime,
    DateTime? endTime,
    required String rfidTagExpected,
  }) async {
    final currentState = state;
    if (currentState is! ParkingLotLoaded) {
      emit(
        ParkingLotError(
          'Không thể đặt chỗ khi dữ liệu chưa sẵn sàng.',
          currentParkingLot:
              currentState is ParkingLotError
                  ? currentState.currentParkingLot
                  : null,
        ),
      );
      return;
    }

    // --- LOGIC KIỂM TRA THỜI GIAN ĐẶT CHỖ MỚI (Đã sửa đổi) ---
    // Lấy thời gian hiện tại, làm tròn đến phút để so sánh ổn định
    final DateTime now = DateTime.now();
    final DateTime nowTruncatedToMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    // Làm tròn startTime đến phút để so sánh nhất quán
    final DateTime startTimeTruncatedToMinute = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      startTime.hour,
      startTime.minute,
    );

    // Định nghĩa ranh giới thời gian cho thời gian BẮT ĐẦU
    final DateTime oneMinuteAgoTruncated = nowTruncatedToMinute.subtract(
      Duration(minutes: 1),
    );
    final DateTime oneHourFromNowTruncated = nowTruncatedToMinute.add(
      Duration(hours: 1),
    );

    // Kiểm tra 1: Thời gian bắt đầu không ở trong quá khứ quá 1 phút
    if (startTimeTruncatedToMinute.isBefore(oneMinuteAgoTruncated)) {
      emit(
        ParkingLotError(
          'Thời gian bắt đầu không thể ở trong quá khứ quá 1 phút so với hiện tại.',
          currentParkingLot: currentState.parkingLot,
        ),
      );
      return;
    }

    // Kiểm tra 2: Thời gian bắt đầu không quá 1 giờ kể từ hiện tại
    if (startTimeTruncatedToMinute.isAfter(oneHourFromNowTruncated)) {
      emit(
        ParkingLotError(
          'Thời gian bắt đầu không thể quá 1 giờ kể từ hiện tại.',
          currentParkingLot: currentState.parkingLot,
        ),
      );
      return;
    }

    // Nếu endTime là null, mặc định là 1 giờ sau startTime
    DateTime actualEndTime = endTime ?? startTime.add(Duration(hours: 1));
    // Làm tròn actualEndTime đến phút để so sánh (tùy chọn nhưng nên làm cho nhất quán)
    final DateTime actualEndTimeTruncatedToMinute = DateTime(
      actualEndTime.year,
      actualEndTime.month,
      actualEndTime.day,
      actualEndTime.hour,
      actualEndTime.minute,
    );

    // Kiểm tra 3: Thời gian kết thúc KHÔNG ĐƯỢC TRƯỚC thời gian bắt đầu
    if (actualEndTimeTruncatedToMinute.isBefore(startTimeTruncatedToMinute)) {
      emit(
        ParkingLotError(
          'Thời gian kết thúc không thể trước thời gian bắt đầu.',
          currentParkingLot: currentState.parkingLot,
        ),
      );
      return;
    }

    // Kiểm tra 4: Thời gian kết thúc phải sau thời điểm hiện tại
    // Điều này quan trọng nếu người dùng chọn startTime trong tương lai gần
    // nhưng endTime lại ở quá khứ so với "hiện tại".
    if (actualEndTimeTruncatedToMinute.isBefore(nowTruncatedToMinute)) {
      emit(
        ParkingLotError(
          'Thời gian kết thúc không thể ở trong quá khứ so với hiện tại.',
          currentParkingLot: currentState.parkingLot,
        ),
      );
      return;
    }

    // *Đã loại bỏ kiểm tra "Thời gian đặt chỗ không thể quá 1 giờ."*
    // *Và loại bỏ kiểm tra "Thời gian kết thúc đặt chỗ không thể quá 1 giờ kể từ hiện tại."*
    // Vì yêu cầu là thời gian kết thúc có thể bao lâu cũng được, miễn là sau hiện tại.

    // --- KẾT THÚC LOGIC KIỂM TRA THỜI GIAN ĐẶT CHỖ MỚI ---

    emit(
      ParkingLotActionInProgress(
        'Đang xử lý đặt chỗ...',
        currentParkingLot: currentState.parkingLot,
      ),
    );

    try {
      bool success = await _dbService.createBooking(
        userId: userId,
        phoneNumber: phoneNumber,
        lotId: parkingLotId,
        spotId: spotId,
        startTime: startTime,
        endTime: actualEndTime, // Sử dụng actualEndTime đã được xử lý
        rfidTagExpected: rfidTagExpected,
      );

      if (success) {
        // State sẽ tự cập nhật khi stream trả về data mới
      } else {
        emit(
          ParkingLotError(
            'Đặt chỗ thất bại.',
            currentParkingLot: currentState.parkingLot,
          ),
        );
      }
    } catch (e) {
      emit(
        ParkingLotError(
          'Lỗi khi đặt chỗ: ${e.toString()}',
          currentParkingLot: currentState.parkingLot,
        ),
      );
    }
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String spotId,
  }) async {
    final currentState = state;
    if (currentState is! ParkingLotLoaded) {
      emit(
        ParkingLotError(
          'Không thể hủy chỗ khi dữ liệu chưa sẵn sàng.',
          currentParkingLot:
              currentState is ParkingLotError
                  ? currentState.currentParkingLot
                  : null,
        ),
      );
      return;
    }

    emit(
      ParkingLotActionInProgress(
        'Đang xử lý hủy chỗ...',
        currentParkingLot: currentState.parkingLot,
      ),
    );

    try {
      bool success = await _dbService.cancelBooking(
        bookingId: bookingId,
        lotId: parkingLotId,
        spotId: spotId,
      );

      if (success) {
        // State sẽ tự cập nhật khi stream trả về data mới
      } else {
        emit(
          ParkingLotError(
            'Hủy chỗ thất bại.',
            currentParkingLot: currentState.parkingLot,
          ),
        );
      }
    } catch (e) {
      emit(
        ParkingLotError(
          'Lỗi khi hủy chỗ: ${e.toString()}',
          currentParkingLot: currentState.parkingLot,
        ),
      );
    } finally {
      // Để stream tự cập nhật trạng thái cuối cùng
    }
  }

  @override
  Future<void> close() {
    _parkingLotSubscription?.cancel();
    return super.close();
  }
}
