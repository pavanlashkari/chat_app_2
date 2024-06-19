import 'dart:io';

import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_model.dart';
import 'chat_messge_tile.dart';

class ChatDetailsScreen extends StatefulWidget {
  final UserProfile userProfile;
  const ChatDetailsScreen({super.key, required this.userProfile});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  var otherUser, currentUser;
  final txtController = TextEditingController();
  var _pickedFile;
  DatabaseService databaseService = DatabaseService();
  NotificationServices notificationServices = NotificationServices();
  Stream? _chatService;
  UserProfile? userProfile;
  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    otherUser = widget.userProfile.uid;
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    _chatService = databaseService.getChatData(currentUser, otherUser);
    getCurrentUserData();
  }

  Future<void> getCurrentUserData() async {
    userProfile = await databaseService.getUser();
  }

  Future<void> _onSendMessages(ChatMessage chatMessage) async {
    Message message = Message(
      senderID: currentUser,
      content: chatMessage.text,
      messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(chatMessage.createdAt),
    );
    await databaseService.sendChatMessage(currentUser, otherUser, message);
    txtController.clear();
    notificationServices.sendChatNotification(
        userProfile!.name!, message.content!, widget.userProfile.deviceToken!);
    print("notification sent successfully");

  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      print(pickedFile.path);
      final downloadUrl = await databaseService.uploadImageToTheChat(
        uploadFile: File(pickedFile.path),
        chatId: databaseService.generateChatIds(
          uid1: currentUser,
          uid2: otherUser,
        ),
      );
      print("image uploaded successfully");
      if (downloadUrl != null) {
        final Message message = Message(
          senderID: currentUser,
          content: downloadUrl,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(
            DateTime.now(),
          ),
        );
        databaseService.sendChatMessage(currentUser, otherUser, message);
      }
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white70,
      context: context,
      builder: (BuildContext context) => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * .15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.camera);
              },
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: const Icon(
                      Icons.camera,
                      size: 60,
                    ),
                  ),
                  const Text("Camera")
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.gallery);
              },
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: const Icon(
                      Icons.photo,
                      size: 60,
                    ),
                  ),
                  const Text("Gallery")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 20),
        child: Column(
          children: [
            AppBarUI(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _chatService,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    Chat? chat = snapshot.data?.data();
                    List<Message>? messages = chat?.messages?.reversed.toList();
                    return GestureDetector(
                      onTap: () =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      child: ListView.builder(
                        reverse: true,
                        itemCount: messages?.length ?? 0,
                        itemBuilder: (context, index) {
                          Message message = messages![index];
                          print(message.content);
                          print(message.senderID);
                          return SizedBox(
                            width: message.messageType == MessageType.Image
                                ? width * 0.5
                                : width * 0.8,
                            height: message.messageType == MessageType.Image
                                ? width * 0.5
                                : null,
                            child: ChatTile(
                              message: message,
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 16,
                  bottom: 16,
                  right: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color.fromRGBO(217, 217, 217, 0.2),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => showBottomSheet(context),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                        color: Color.fromRGBO(217, 217, 217, 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 2,
                        height: 40,
                        color: const Color.fromRGBO(217, 217, 217, 1),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: txtController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Something...",
                          hintStyle: GoogleFonts.poppins().copyWith(
                            color: const Color.fromRGBO(184, 175, 175, 1),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (txtController.text.trim().isEmpty) {
                          return;
                        } else {
                          await _onSendMessages(
                            ChatMessage(
                              text: txtController.text,
                              user: ChatUser(id: currentUser),
                              createdAt: DateTime.now(),
                            ),
                          );
                        }
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color.fromRGBO(231, 111, 81, 1),
                        child: Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget AppBarUI() {
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            height: 32,
            width: 32,
            color: const Color.fromRGBO(229, 229, 229, 0.21),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 24,
              color: Color.fromRGBO(206, 198, 198, 1),
            ),
          ),
        ),
        CircleAvatar(
          radius: 18,
          child: Image.network(
            widget.userProfile.pfpURL!,
            fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userProfile.name!,
                style: GoogleFonts.poppins().copyWith(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "online now",
                style: GoogleFonts.poppins().copyWith(
                  color: const Color.fromRGBO(48, 203, 129, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color.fromRGBO(184, 175, 175, 1),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.video_call,
                  size: 15,
                  color: Color.fromRGBO(184, 175, 175, 1),
                ),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            InkWell(
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color.fromRGBO(184, 175, 175, 1),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.call,
                  size: 15,
                  color: Color.fromRGBO(184, 175, 175, 1),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
