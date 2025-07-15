import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/parking_lot/parking_lot_cubit.dart';
import '../models/parking_lot.dart';
import '../models/spot.dart';
import '../widgets/spot_widget.dart';

class HomeScreen extends StatelessWidget {
  // Hàm định dạng thời gian từ chuỗi ISO sang định dạng dễ đọc
  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Không hợp lệ';
    }
  }

  // Hiển thị dialog chi tiết chỗ đỗ và các hành động liên quan
  void _showSpotDetailsDialog(BuildContext context, Spot spot) {
    // Lấy instance của Cubit và ID người dùng hiện tại
    final parkingLotCubit = context.read<ParkingLotCubit>();
    final currentUserId =
        context.read<AuthCubit>().state is Authenticated
            ? (context.read<AuthCubit>().state as Authenticated).user.uid
            : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Chi tiết chỗ đỗ: ${spot.id.toUpperCase()}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Trạng thái: ${spot.status.toUpperCase()}'),
                Text('RFID Tag: ${spot.rfidTag ?? 'N/A'}'),
                Text('Thời gian vào: ${_formatDateTime(spot.timeIn)}'),
                Text('Thời gian ra: ${_formatDateTime(spot.timeOut)}'),
                if (spot.status == 'reserved' && spot.bookingStartTime != null)
                  Text(
                    'Vào dự kiến: ${_formatDateTime(spot.bookingStartTime)}',
                  ),
                if (spot.status == 'reserved' && spot.bookingEndTime != null)
                  Text('Ra dự kiến: ${_formatDateTime(spot.bookingEndTime)}'),
                Text('SĐT đặt chỗ: ${spot.phoneNumber ?? 'N/A'}'),
                Text('Booking Ref: ${spot.bookingRef ?? 'N/A'}'),
                // Nút "Đặt chỗ" chỉ hiển thị khi chỗ trống và có người dùng đăng nhập
                if (spot.status == 'empty' && currentUserId != null) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Đóng dialog hiện tại
                      _showBookingTimePicker(context, spot.id, currentUserId);
                    },
                    child: Text('Đặt chỗ'),
                  ),
                ],
                // Nút "Hủy đặt chỗ" chỉ hiển thị khi chỗ đã đặt và người dùng hiện tại là người đặt
                if (spot.status == 'reserved' &&
                    currentUserId != null &&
                    spot.userId == currentUserId) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Đóng dialog hiện tại
                      if (spot.bookingRef != null) {
                        _handleCancelBooking(
                          context,
                          spot.bookingRef!,
                          spot.id,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Không tìm thấy thông tin Booking để hủy.',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('Hủy đặt chỗ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
                // Thông báo khi chỗ đã được người khác đặt
                if (spot.status == 'reserved' &&
                    currentUserId != null &&
                    spot.userId != null &&
                    spot.userId != currentUserId) ...[
                  SizedBox(height: 10),
                  Text(
                    'Chỗ này đã được đặt bởi người khác.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
                // Thông báo khi chỗ đang có xe đỗ
                if (spot.status == 'occupied') ...[
                  SizedBox(height: 10),
                  Text(
                    'Chỗ này đang có xe đỗ.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Hiển thị dialog chọn thời gian và nhập thông tin đặt chỗ
  void _showBookingTimePicker(
    BuildContext context,
    String spotId,
    String firebaseAuthUserId,
  ) {
    // Thời gian hiện tại, làm tròn đến phút để so sánh nhất quán
    final DateTime now = DateTime.now();
    final DateTime nowTruncatedToMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    // Cửa sổ cho phép đặt thời gian BẮT ĐẦU: 1 giờ kể từ thời điểm hiện tại (đã làm tròn phút)
    final DateTime oneHourFromNowTruncated = nowTruncatedToMinute.add(
      Duration(hours: 1),
    );

    // Thời gian bắt đầu mặc định là thời điểm hiện tại (làm tròn đến phút)
    DateTime _selectedStartTime = nowTruncatedToMinute;

    DateTime? _selectedEndTime; // Thời gian kết thúc tùy chọn

    String _rfidTagExpected = '';
    String _phoneNumber = '';
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Đặt chỗ đỗ xe: ${spotId.toUpperCase()}'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Mã RFID của xe (ví dụ: ABCD123)',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _rfidTagExpected = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã RFID.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _phoneNumber = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại.';
                          }
                          // Regex cơ bản cho số điện thoại Việt Nam (0xxxx, +84xxxx)
                          if (!RegExp(
                            r'^(0|\+84)[35789]\d{8}$',
                          ).hasMatch(value)) {
                            return 'Vui lòng nhập số điện thoại hợp lệ.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Chọn thời gian bắt đầu
                      ListTile(
                        title: Text(
                          'Thời gian bắt đầu:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${_selectedStartTime.day}/${_selectedStartTime.month}/${_selectedStartTime.year} ${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedStartTime,
                            // Cho phép chọn từ 1 phút trước thời điểm hiện tại đã làm tròn phút
                            firstDate: nowTruncatedToMinute.subtract(
                              Duration(minutes: 1),
                            ),
                            // Chỉ cho phép chọn đến 1 giờ sau thời điểm hiện tại đã làm tròn phút
                            lastDate: oneHourFromNowTruncated,
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _selectedStartTime,
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light(),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              final DateTime tempStartTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              // Làm tròn tempStartTime đến phút để so sánh
                              final DateTime tempStartTimeTruncatedToMinute =
                                  DateTime(
                                    tempStartTime.year,
                                    tempStartTime.month,
                                    tempStartTime.day,
                                    tempStartTime.hour,
                                    tempStartTime.minute,
                                  );

                              // Kiểm tra thời gian bắt đầu không được ở quá khứ quá 1 phút (so với nowTruncatedToMinute)
                              if (tempStartTimeTruncatedToMinute.isBefore(
                                nowTruncatedToMinute.subtract(
                                  Duration(minutes: 1),
                                ),
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thời gian bắt đầu không thể ở trong quá khứ quá 1 phút so với hiện tại.',
                                    ),
                                  ),
                                );
                              }
                              // Kiểm tra thời gian bắt đầu không được quá 1 giờ kể từ hiện tại (so với nowTruncatedToMinute)
                              else if (tempStartTimeTruncatedToMinute.isAfter(
                                oneHourFromNowTruncated,
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thời gian bắt đầu không thể quá 1 giờ kể từ hiện tại.',
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedStartTime = tempStartTime;
                                  // Đặt lại thời gian kết thúc nếu thời gian bắt đầu thay đổi
                                  _selectedEndTime = null;
                                });
                              }
                            }
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      // Chọn thời gian kết thúc (tùy chọn)
                      ListTile(
                        title: Text(
                          'Thời gian kết thúc (Tùy chọn):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _selectedEndTime != null
                              ? '${_selectedEndTime!.day}/${_selectedEndTime!.month}/${_selectedEndTime!.year} ${_selectedEndTime!.hour}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
                              : '',
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedEndTime ?? _selectedStartTime,
                            // Thời gian kết thúc không thể trước thời gian bắt đầu
                            firstDate: _selectedStartTime,
                            // *** RẤT QUAN TRỌNG: lastDate bây giờ có thể là rất xa trong tương lai (ví dụ 10 năm tới) ***
                            // Vì thời gian kết thúc không giới hạn, chỉ cần sau thời điểm hiện tại.
                            lastDate: DateTime.now().add(
                              Duration(days: 365 * 10),
                            ), // 10 năm kể từ hiện tại
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _selectedEndTime ?? _selectedStartTime,
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light(),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              final DateTime tempEndTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              // Làm tròn tempEndTime và _selectedStartTime đến phút để so sánh
                              final DateTime tempEndTimeTruncatedToMinute =
                                  DateTime(
                                    tempEndTime.year,
                                    tempEndTime.month,
                                    tempEndTime.day,
                                    tempEndTime.hour,
                                    tempEndTime.minute,
                                  );
                              final DateTime
                              selectedStartTimeTruncatedToMinute = DateTime(
                                _selectedStartTime.year,
                                _selectedStartTime.month,
                                _selectedStartTime.day,
                                _selectedStartTime.hour,
                                _selectedStartTime.minute,
                              );

                              // Kiểm tra thời gian kết thúc không được trước thời gian bắt đầu
                              if (tempEndTimeTruncatedToMinute.isBefore(
                                selectedStartTimeTruncatedToMinute,
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thời gian kết thúc không thể trước thời gian bắt đầu.',
                                    ),
                                  ),
                                );
                              }
                              // Kiểm tra thời gian kết thúc phải sau hoặc bằng thời gian hiện tại
                              else if (tempEndTimeTruncatedToMinute.isBefore(
                                nowTruncatedToMinute,
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thời gian kết thúc không thể ở trong quá khứ so với hiện tại.',
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedEndTime = tempEndTime;
                                });
                              }
                            }
                          }
                        },
                      ),
                      // Nút để đặt lại thời gian kết thúc về null
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedEndTime = null;
                          });
                        },
                        child: Text(
                          'Không chọn thời gian kết thúc (mặc định là 1h sau giờ bắt đầu)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Hủy'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Xác nhận đặt chỗ'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // --- KIỂM TRA TRÊN UI ĐÃ SỬA ĐỔI ---
                      final DateTime finalNowTruncatedToMinute = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      );

                      // Làm tròn thời gian bắt đầu đã chọn để so sánh
                      final DateTime selectedStartTimeTruncatedToMinute =
                          DateTime(
                            _selectedStartTime.year,
                            _selectedStartTime.month,
                            _selectedStartTime.day,
                            _selectedStartTime.hour,
                            _selectedStartTime.minute,
                          );

                      // Đảm bảo startTime không quá 1 phút trong quá khứ (so với now đã làm tròn)
                      if (selectedStartTimeTruncatedToMinute.isBefore(
                        finalNowTruncatedToMinute.subtract(
                          Duration(minutes: 1),
                        ),
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thời gian bắt đầu không thể ở trong quá khứ quá 1 phút.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Đảm bảo startTime không quá 1 giờ trong tương lai (so với now đã làm tròn)
                      // (Logic này giữ nguyên vì startTime vẫn cần nằm trong cửa sổ 1 giờ)
                      if (selectedStartTimeTruncatedToMinute.isAfter(
                        finalNowTruncatedToMinute.add(Duration(hours: 1)),
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thời gian bắt đầu không thể quá 1 giờ kể từ hiện tại.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Nếu người dùng không chọn thời gian kết thúc, mặc định là 1 giờ sau thời gian bắt đầu
                      DateTime finalEndTime =
                          _selectedEndTime ??
                          _selectedStartTime.add(Duration(hours: 1));

                      // Làm tròn finalEndTime để so sánh
                      final DateTime finalEndTimeTruncatedToMinute = DateTime(
                        finalEndTime.year,
                        finalEndTime.month,
                        finalEndTime.day,
                        finalEndTime.hour,
                        finalEndTime.minute,
                      );

                      // Đảm bảo thời gian kết thúc không trước thời gian bắt đầu
                      if (finalEndTimeTruncatedToMinute.isBefore(
                        selectedStartTimeTruncatedToMinute,
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thời gian kết thúc không thể trước thời gian bắt đầu.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Đảm bảo thời gian kết thúc phải sau hoặc bằng thời điểm hiện tại (đã làm tròn)
                      if (finalEndTimeTruncatedToMinute.isBefore(
                        finalNowTruncatedToMinute,
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thời gian kết thúc không thể ở trong quá khứ so với hiện tại.',
                            ),
                          ),
                        );
                        return;
                      }

                      // *Đã loại bỏ kiểm tra thời lượng đặt chỗ không quá 1 giờ*
                      // *Và loại bỏ kiểm tra toàn bộ khoảng thời gian đặt chỗ không vượt quá 1 giờ từ hiện tại*
                      // Vì yêu cầu là thời gian kết thúc có thể bao lâu cũng được, miễn là sau hiện tại.

                      // --- KẾT THÚC KIỂM TRA TRÊN UI ĐÃ SỬA ĐỔI ---

                      Navigator.of(dialogContext).pop(); // Đóng dialog
                      _handleBooking(
                        context,
                        spotId,
                        firebaseAuthUserId,
                        _phoneNumber,
                        _selectedStartTime,
                        finalEndTime, // Truyền thời gian kết thúc đã được xử lý
                        _rfidTagExpected,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Xử lý logic đặt chỗ bằng cách gọi Cubit
  void _handleBooking(
    BuildContext context,
    String spotId,
    String firebaseAuthUserId,
    String phoneNumber,
    DateTime startTime,
    DateTime? endTime,
    String rfidTagExpected,
  ) async {
    context.read<ParkingLotCubit>().createBooking(
      userId: firebaseAuthUserId,
      phoneNumber: phoneNumber,
      spotId: spotId,
      startTime: startTime,
      endTime: endTime,
      rfidTagExpected: rfidTagExpected,
    );
  }

  // Xử lý logic hủy đặt chỗ bằng cách gọi Cubit
  void _handleCancelBooking(
    BuildContext context,
    String bookingId,
    String spotId,
  ) async {
    context.read<ParkingLotCubit>().cancelBooking(
      bookingId: bookingId,
      spotId: spotId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParkingLotCubit, ParkingLotState>(
      listener: (context, state) {
        // Lắng nghe các trạng thái lỗi để hiển thị Snackbar
        if (state is ParkingLotError) {
          // Chỉ hiển thị Snackbar cho các lỗi liên quan đến hành động (đặt/hủy)
          // hoặc nếu có thông báo lỗi cụ thể không liên quan đến việc tải ban đầu
          if (state.currentParkingLot != null ||
              state.message.contains('đặt chỗ') ||
              state.message.contains('hủy chỗ')) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
        // Thêm lắng nghe cho hành động thành công (tùy chọn)
        // Đây chỉ là một ví dụ, bạn có thể cần lưu trạng thái trước đó
        // để xác định chính xác khi nào một hành động (đặt/hủy) thành công.
        // if (state is ParkingLotLoaded && context.read<ParkingLotCubit>().state is! ParkingLotInitial) {
        //   // Logic để kiểm tra xem hành động trước đó có phải là booking/cancel không
        //   // và hiển thị thông báo thành công.
        // }
      },
      builder: (context, state) {
        // Xác định trạng thái tải và thông tin bãi đỗ xe
        final bool isLoading =
            state is ParkingLotLoading || state is ParkingLotActionInProgress;
        final String? errorMessage =
            state is ParkingLotError ? state.message : null;
        final ParkingLot? parkingLot =
            state is ParkingLotLoaded
                ? state.parkingLot
                : state is ParkingLotError
                ? state.currentParkingLot
                : state is ParkingLotActionInProgress
                ? state.currentParkingLot
                : null;

        // Hiển thị màn hình tải ban đầu nếu chưa có dữ liệu
        if (isLoading && parkingLot == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Quản lý bãi đỗ xe')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Hiển thị màn hình lỗi nếu không tải được dữ liệu ban đầu
        if (errorMessage != null && parkingLot == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Quản lý bãi đỗ xe')),
            body: Center(child: Text('Đã xảy ra lỗi: $errorMessage')),
          );
        }

        // Hiển thị giao diện chính khi có dữ liệu bãi đỗ xe
        if (parkingLot != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Quản lý bãi đỗ xe'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthCubit>().logout(); // Đăng xuất
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tiến trình khi có hành động đang diễn ra
                if (state is ParkingLotActionInProgress)
                  LinearProgressIndicator(),
                if (state is ParkingLotLoading) LinearProgressIndicator(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parkingLot.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        parkingLot.location,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tổng số chỗ: ${parkingLot.totalSpots}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Số chỗ trống: ${parkingLot.availableSpots}',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              parkingLot.availableSpots > 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      // Hiển thị lỗi ngay trên màn hình nếu có (ví dụ: lỗi stream)
                      if (state is ParkingLotError &&
                          state.currentParkingLot != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Lỗi: ${state.message}',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                // Hiển thị lưới các chỗ đỗ xe
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 cột
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: parkingLot.spots.length,
                    itemBuilder: (context, index) {
                      final spot = parkingLot.spots[index];
                      return SpotWidget(
                        spot: spot,
                        // Vô hiệu hóa onTap khi đang tải hoặc có hành động
                        onTap:
                            isLoading
                                ? null
                                : () => _showSpotDetailsDialog(context, spot),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // Màn hình mặc định trong trường hợp không xác định
        return Scaffold(
          appBar: AppBar(title: Text('Quản lý bãi đỗ xe')),
          body: Center(child: Text('Đang khởi tạo...')),
        );
      },
    );
  }
}
