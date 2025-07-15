import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import '../blocs/auth/auth_cubit.dart'; // Import AuthCubit
import 'forgot.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true; // true cho Login, false cho Register
  // Không cần biến _error và _isLoading cục bộ nữa, vì trạng thái sẽ do Cubit quản lý

  void _submit(BuildContext context) {
    // Nhận context
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Gọi phương thức login/register của AuthCubit
      if (_isLogin) {
        context.read<AuthCubit>().login(_email, _password);
      } else {
        context.read<AuthCubit>().register(_email, _password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocConsumer kết hợp lắng nghe State và thực hiện hành động (listener)
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Listener được gọi MỘT LẦN duy nhất khi State thay đổi
        // Sử dụng để hiển thị SnackBar, Dialog, điều hướng,... (các hành động chỉ làm 1 lần)
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        // Wrapper đã xử lý điều hướng khi Authenticated, nên không cần pushReplacement ở đây nữa
      },
      builder: (context, state) {
        // Builder được gọi mỗi khi State thay đổi để xây dựng lại UI
        // Sử dụng để hiển thị các phần của UI dựa trên State (loading, error text, form)

        final bool isLoading =
            state is AuthLoading; // Kiểm tra trạng thái loading
        final String? errorMessage =
            state is AuthError ? state.message : null; // Lấy thông báo lỗi

        return Scaffold(
          appBar: AppBar(title: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Vui lòng nhập email hợp lệ.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                      enabled: !isLoading, // Vô hiệu hóa input khi loading
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Mật khẩu'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      enabled: !isLoading, // Vô hiệu hóa input khi loading
                    ),
                    SizedBox(height: 20),
                    if (errorMessage != null) // Hiển thị lỗi nếu có
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    isLoading // Hiển thị loading spinner khi loading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => _submit(
                                    context,
                                  ), // Disable nút khi loading
                          child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                        ),
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                // Disable nút khi loading
                                setState(() {
                                  _isLogin = !_isLogin;
                                  // Không cần xóa _error cục bộ nữa, nó do Cubit quản lý
                                });
                              },
                      child: Text(
                        _isLogin
                            ? 'Chưa có tài khoản? Đăng ký'
                            : 'Đã có tài khoản? Đăng nhập',
                      ),
                    ),
                    // Nút "Quên mật khẩu" - chỉ hiển thị khi ở chế độ Đăng nhập và không loading
                    if (_isLogin && !isLoading)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text('Quên mật khẩu?'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
