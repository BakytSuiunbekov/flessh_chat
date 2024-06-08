import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flessh_chat/models/user_model.dart';

class HomeService {
  static Future<void> sendMessege(String sms) async {
    try {
      final sender = FirebaseAuth.instance.currentUser;
      if (sender != null) {
        final db = FirebaseFirestore.instance;

        final userModel = UserModel(
          user: sender.email!,
          sms: sms,
          dateTime: DateTime.now(),
        );
        await db.collection('messages').add(userModel.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamMessage() {
    try {
      final db = FirebaseFirestore.instance;
      return db
          .collection('messages')
          .orderBy('dataTime', descending: true)
          .snapshots();
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to get message stream');
    }
  }
}
