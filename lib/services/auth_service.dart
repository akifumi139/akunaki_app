import 'dart:convert';
import 'package:akunaki_app/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.10.19/api';

  Future<void> saveLoginStatus(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', token);
  }

  Future<bool> verifyToken(String token) async {
    final url = Uri.parse('${AppConstants.apiUrl}/authorization');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['status'] == 'OK';
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error verifying token: $e');
    }
  }
}
