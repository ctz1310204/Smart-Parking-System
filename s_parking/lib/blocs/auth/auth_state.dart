part of 'auth_cubit.dart'; // Liên kết với file auth_cubit.dart

// Định nghĩa các trạng thái có thể có của quá trình xác thực

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu (ngay khi khởi động app)
class AuthInitial extends AuthState {}

// Trạng thái đang tải (đang kiểm tra user đã đăng nhập chưa, đang đăng nhập/đăng ký)
class AuthLoading extends AuthState {}

// Trạng thái đã xác thực (user đã đăng nhập)
class Authenticated extends AuthState {
  final User user; // Thông tin user đã đăng nhập

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Trạng thái chưa xác thực (user chưa đăng nhập)
class Unauthenticated extends AuthState {}

// Trạng thái lỗi xảy ra trong quá trình xác thực
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Có thể thêm các trạng thái khác tùy nhu cầu (ví dụ: AuthRegisteredSuccess)
