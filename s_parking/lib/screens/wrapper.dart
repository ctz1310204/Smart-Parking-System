import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import '../blocs/auth/auth_cubit.dart'; // Import AuthCubit
import 'auth_screen.dart';
import 'home_screen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BlocBuilder lắng nghe sự thay đổi States từ AuthCubit
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Dựa vào trạng thái hiện tại của AuthCubit để quyết định hiển thị màn hình nào

        if (state is Authenticated) {
          // Nếu trạng thái là Authenticated, hiển thị HomeScreen
          return HomeScreen();
        } else if (state is Unauthenticated || state is AuthError) {
          // Nếu trạng thái là Unauthenticated hoặc AuthError, hiển thị AuthScreen
          return AuthScreen();
        } else {
          // Các trạng thái khác (ví dụ: AuthInitial, AuthLoading) - có thể hiển thị Loading
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
