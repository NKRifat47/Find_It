import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_it/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

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
            title: const Text("Message"),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('users', arrayContains: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No chats found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final List users = chat['users'];
              final otherUserId = users.firstWhere((id) => id != userId);
              final chatId = chat.id;

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox();

                  final userData =
                      userSnap.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'User';

                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => ChatScreen(
                          receiverId: otherUserId,
                          receiverName: userName,
                        ),
                      );
                    },
                    onLongPress: () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text("Delete Chat"),
                          content: const Text(
                            "Do you want to delete this chat?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                final messages =
                                    await FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatId)
                                        .collection('messages')
                                        .get();

                                for (var msg in messages.docs) {
                                  await msg.reference.delete();
                                }
                                await FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(chatId)
                                    .delete();

                                Get.back();
                                Get.snackbar(
                                  "Deleted",
                                  "Chat with $userName has been deleted.",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
