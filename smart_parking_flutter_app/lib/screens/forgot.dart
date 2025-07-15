import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'forgot.dart'; // Import màn hình quên mật khẩu

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _message = '';
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
        setState(() {
          _message = 'Link đặt lại mật khẩu đã được gửi đến email của bạn.';
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _message =
              'Lỗi: ${e.message ?? 'Không thể gửi link đặt lại mật khẩu.'}';
        });
      } catch (e) {
        setState(() {
          _message = 'Đã xảy ra lỗi: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quên mật khẩu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Nhập email của bạn để nhận link đặt lại mật khẩu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
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
                ),
                SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            _message.contains('Lỗi')
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                  ),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text('Đặt lại mật khẩu'),
                    ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Quay lại màn hình trước (AuthScreen)
                  },
                  child: Text('Quay lại đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
