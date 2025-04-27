import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/post_model.dart';
import '../../theme/theme.dart';
import '../../widgets/custom_snackbar.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  bool isLoading = true;
  List<PostModel> myPosts = [];

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .get();

      myPosts =
          snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();
    } catch (e) {
      showError("Failed to load your posts.");
    }
    setState(() => isLoading = false);
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      showSuccess("Post deleted successfully!");
      _loadMyPosts();
    } catch (_) {
      showError("Something went wrong while deleting.");
    }
  }

  void _confirmDelete(String postId) {
    Get.defaultDialog(
      title: "Delete Post",
      middleText: "Are you sure you want to delete this post?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        _deletePost(postId);
      },
      onCancel: () {},
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          Get.back();
          _deletePost(postId);
        },
        child: const Text("Delete", style: TextStyle(color: Colors.white)),
      ),
      cancel: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("My Posts"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : myPosts.isEmpty
              ? const Center(child: Text("No posts found."))
              : RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: _loadMyPosts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: myPosts.length,
                  itemBuilder: (context, index) {
                    final post = myPosts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(
                              post.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Posted on: ${post.createdAt.toLocal()}",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(post.id),
                            ),
                          ),
                          if (post.base64Images.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(post.base64Images.first),
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              post.description,
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
