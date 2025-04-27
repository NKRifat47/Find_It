import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';
import '../widgets/custom_snackbar.dart';

class PostController extends GetxController {
  static PostController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isUploading = false.obs;

  Future<bool> createPost({
    required String title,
    required String description,
    required List<File> images,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in.");
        return false;
      }

      final originalBytes = await images.first.readAsBytes();
      final decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) {
        showError("Image decoding failed.");
        return false;
      }

      final resized = img.copyResize(decodedImage, width: 600);
      final compressedBytes = img.encodeJpg(resized, quality: 70);
      final base64Image = base64Encode(compressedBytes);

      List<String> base64Images = [base64Image];

      final postId = const Uuid().v4();
      final post = PostModel(
        id: postId,
        userId: user.uid,
        title: title,
        description: description,
        base64Images: base64Images,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('posts').doc(postId).set(post.toMap());

      return true;
    } catch (e) {
      final error = e.toString();

      if (error.contains("1048487 bytes")) {
        showError(
          "⚠️ Storage limit reached.\nPlease delete your old post to add new.",
        );
      } else {
        showError("Failed to create post. Try again.");
      }

      return false;
    }
  }
}
