import 'dart:io';
import 'dart:convert';
import 'package:akunaki_app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  Future<void> submitPost(
    String comment,
    File? image,
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token is missing. Please log in.');
    }

    final url = Uri.parse('${AppConstants.apiUrl}/posts/create');

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['comment'] = comment;

      if (image != null) {
        final fileSize = await image.length();
        const int maxSize = 20 * 1024 * 1024;
        if (fileSize > maxSize) {
          throw Exception('Image file size exceeds the 20MB limit.');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: basename(image.path),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            'Failed to post. Status code: ${response.statusCode}, Response body: $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to submit post: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final url = Uri.parse('${AppConstants.apiUrl}/posts/home');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(responseBody);
        final List<dynamic> posts = data['data'];

        return posts.map((post) {
          final comment = post['comment'] ?? '';
          final image = post['images'] != null && post['images'].isNotEmpty
              ? 'http://192.168.10.19/storage/${post['images'][0]['path']}'
              : null;

          // URLが正しい形式でない場合に備えたチェック
          final imageUrl =
              image != null && Uri.tryParse(image)?.isAbsolute == true
                  ? image
                  : null;

          return {
            'content': comment,
            'image': imageUrl,
          };
        }).toList();
      } else {
        // HTTPリクエストが失敗した場合
        throw Exception(
            'Failed to load posts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
}
