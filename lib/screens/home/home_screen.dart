import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_it/message/message_list_screen.dart';
import 'package:find_it/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it/models/post_model.dart';
import 'package:find_it/screens/account/account_screen.dart';
import 'package:find_it/screens/create/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<PostModel> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => isLoading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .get();

      posts =
          snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load posts",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _refresh() async {
    await _loadPosts();
  }

  Future<void> _openCreatePost() async {
    final result = await Get.to(() => const CreatePostScreen());
    if (result == true) {
      await _loadPosts();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            title: Text(
              "Home",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .where(
                        'users',
                        arrayContains: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                if (snapshot.hasData && currentUserId != null) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final lastMessageRaw = data['lastMessage'];
                    if (lastMessageRaw is Map<String, dynamic>) {
                      final lastMessage = lastMessageRaw;

                      if (lastMessage['receiverId'] == currentUserId &&
                          !(lastMessage['isRead'] ?? false)) {
                        unreadCount++;
                      }
                    }
                  }
                }

                return Stack(
                  children: [
                    const Icon(Icons.message_outlined),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "Message",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Account",
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              _openCreatePost();
              break;
            case 2:
              Get.to(() => const MessageListScreen());
              break;

            case 3:
              Get.to(() => const AccountScreen());
              break;
          }
        },
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: _refresh,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Find your item",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          posts.isEmpty
                              ? const Center(child: Text("No posts yet"))
                              : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return _PostCard(post: post);
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({super.key, required this.post});

  Future<String> fetchUserName(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data()?['name'] ?? 'Unknown User';
      }
    } catch (_) {}
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<String>(
      future: fetchUserName(post.userId),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? 'Loading...';

        final isMyPost = currentUser.uid == post.userId;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  post.title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Posted by: $userName",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  "Description: ${post.description}",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed:
                          isMyPost
                              ? () {
                                Get.snackbar(
                                  "Not allowed",
                                  "You can't message your own post.",
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                              : () {
                                Get.to(
                                  () => ChatScreen(
                                    receiverId: post.userId,
                                    receiverName: userName,
                                  ),
                                );
                              },
                      icon: Icon(Icons.message, color: AppTheme.primaryColor),
                      label: Text(
                        isMyPost ? "My Post" : "Message",
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: AppTheme.primaryColor),
                      label: Text(
                        "Share",
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
