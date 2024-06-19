import 'dart:io';

import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/message_model.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<UserProfile>? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _usersCollection =
        _firebaseFirestore.collection("users").withConverter<UserProfile>(
              fromFirestore: (snapshot, options) =>
                  UserProfile.fromJson(snapshot.data()!),
              toFirestore: (UserProfile, _) => UserProfile.toJson(),
            );
    _chatsCollection =
        _firebaseFirestore.collection("chats").withConverter<Chat>(
              fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
              toFirestore: (Chat, _) => Chat.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<UserProfile?> getUser() async {
    try {
      final querySnapshot = await _usersCollection
          ?.doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot!.exists) {
        return querySnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Stream<QuerySnapshot<UserProfile>>? getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatIds(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatId).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatIds(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
    print("chat sended successfully");
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatIds(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatIds(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson()]),
    });
  }

  String generateChatIds({required String uid1, required String uid2}) {
    List uids = [uid1, uid2];
    uids.sort();
    String chatId = uids.fold("",  (id, uid) => "$id$uid");
    return chatId;
  }

  Future<String?> uploadImageToTheChat(
      {required File uploadFile, required String chatId}) async {
    final file = uploadFile;
    final storageRef = FirebaseStorage.instance.ref('chatImage/$chatId/').child('${DateTime.now()}.png');
    await storageRef.putFile(file);
    print("successfully uploaded");
    final downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  }
}