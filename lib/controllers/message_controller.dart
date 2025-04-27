import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  static MessageController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;

  String getChatId(String otherUserId) {
    final ids = [currentUser.uid, otherUserId];
    ids.sort(); // Ensure consistent order
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final chatId = getChatId(receiverId);

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'users': [currentUser.uid, receiverId],
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String receiverId) {
    final chatId = getChatId(receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
