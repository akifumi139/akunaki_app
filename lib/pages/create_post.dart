import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../services/post_service.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> {
  final TextEditingController _commentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      if (image != null) {
        final img.Image resizedImage = img.copyResize(image, width: 800);
        final compressedImage = File(pickedFile.path)
          ..writeAsBytesSync(
            img.encodeJpg(resizedImage, quality: 80),
          );

        setState(() {
          _image = compressedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿画面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              await PostService()
                  .submitPost(_commentController.text, _image, context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '今、どんな?',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(right: 50, top: 8, bottom: 8),
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_image == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            if (_image != null)
              Stack(
                children: [
                  // 画像
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _image!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
