// lib/blocs/auth/auth_cubit.dart

import 'package:bloc/bloc.dart'; // <-- Rất quan trọng: Định nghĩa lớp Cubit và hàm emit()
import 'package:equatable/equatable.dart'; // Cần cho State kế thừa Equatable
import 'package:firebase_auth/firebase_auth.dart'; // Cần cho tương tác với Firebase Auth

part 'auth_state.dart'; // Liên kết với file auth_state.dart

// Định nghĩa Cubit cho phần Xác thực
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth; // Instance của Firebase Auth

  // Constructor: Khởi tạo Cubit với trạng thái ban đầu là AuthInitial
  AuthCubit(this._firebaseAuth) : super(AuthInitial()) {
    // Lắng nghe sự thay đổi trạng thái xác thực của Firebase
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        // Nếu user là null, phát ra trạng thái Unauthenticated
        emit(Unauthenticated());
      } else {
        // Nếu user không null, phát ra trạng thái Authenticated
        emit(Authenticated(user));
      }
    });
  }

  // Phương thức xử lý đăng nhập
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading()); // Phát ra trạng thái Loading
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Trạng thái Authenticated sẽ được emit tự động bởi listener authStateChanges()
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng nhập thất bại.'));
      // Sau khi báo lỗi, quay lại trạng thái Unauthenticated (nếu user chưa đăng nhập)
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }

  // Phương thức xử lý đăng ký
  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading()); // Phát ra trạng thái Loading
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Trạng thái Authenticated sẽ được emit tự động bởi listener authStateChanges()
      // Bạn có thể emit một trạng thái thành công đặc biệt ở đây nếu muốn (ví dụ: AuthRegisteredSuccess)
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng ký thất bại.'));
      emit(Unauthenticated()); // Vẫn ở trạng thái chưa xác thực
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }

  // Phương thức xử lý đăng xuất
  Future<void> logout() async {
    try {
      emit(AuthLoading()); // Phát ra trạng thái Loading (tùy chọn)
      await _firebaseAuth.signOut();
      // Trạng thái Unauthenticated sẽ được emit tự động bởi listener authStateChanges()
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi khi đăng xuất: ${e.toString()}'));
      // Sau đó listener vẫn sẽ phát ra Unauthenticated
    }
  }

  // Có thể thêm các phương thức khác (ví dụ: resetPassword)
}
