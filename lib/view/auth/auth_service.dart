import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/allpage.dart';
import 'package:flutter_application_1/view/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>?> _login(
      String username, String password) async {
    try {
      final Uri url =
          Uri.parse('${APIService.loginUrl}?userid=$username&pass=$password');

      var response = await http.post(url);

      if (response.statusCode == 200) {
        final body = response.body.trim();

        final List<dynamic> data = jsonDecode(body);

        if (data.isNotEmpty) {
          final maLoi = data[0]['maloi'] ?? '0';

          if (maLoi == '1') {
            // Trả về data user (toàn bộ hoặc một phần)
            return data[0];
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi: $e');
      return null;
    }
  }

// Hàm chuyển password thành MD5
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static Future<void> handleLogin(
      BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    var userData = await _login(username, password);

    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('user', userData['user'] ?? '');
      await prefs.setString('userid', username);
      await prefs.setString('pass', generateMd5(password));
      final passw = prefs.getString('pass');
       

      print('Đăng nhập thành công: $username && mật khẩu đã mã hóa MD5: $passw');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PageAll(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thất bại')),
      );
    }
  }

  // Hàm logout
  static Future<void> handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('userid');
    await prefs.remove('pass');
    await prefs.remove('user');

    print('Đã đăng xuất. Các key hiện có: ${prefs.getKeys()}');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }

  // Kiểm tra đã login chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Lấy userid đã lưu
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userid') ?? '';
  }

  // Lấy password đã lưu
  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pass') ?? '';
  }
}
