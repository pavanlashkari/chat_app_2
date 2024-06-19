import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/message_model.dart';

class ChatTile extends StatelessWidget {
  final Message message;
  ChatTile({super.key, required this.message});
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final senderId = message.senderID;
    final messageType = message.messageType;
    final timeStamp = message.sentAt;
    bool otherUser = senderId != currentUserId;
    DateTime time = timeStamp!.toDate();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: messageType == MessageType.Image
          ? Row(
              mainAxisAlignment:
                  otherUser ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Visibility(
                    visible: !otherUser,
                    child: Text(
                      "${time.hour}:${time.minute}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: otherUser
                          ? const Color.fromRGBO(217, 217, 217, 0.39)
                          : const Color.fromRGBO(49, 127, 237, 1),
                    ),
                    borderRadius: otherUser
                        ? const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                  ),
                  child: CachedNetworkImage(
                    alignment: Alignment.center,
                    imageUrl: message.content!,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Visibility(
                  visible: otherUser,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${time.hour}:${time.minute}",
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment:
                  otherUser ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Visibility(
                    visible: !otherUser,
                    child: Text(
                      "${time.hour}:${time.minute}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: width * 0.6),
                  decoration: BoxDecoration(
                    color: otherUser
                        ? const Color.fromRGBO(217, 217, 217, 0.39)
                        : const Color.fromRGBO(49, 127, 237, 1),
                    borderRadius: otherUser
                        ? const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Text(
                      message.content!,
                      softWrap: true,
                      textAlign: otherUser ? TextAlign.start : TextAlign.end,
                      style: GoogleFonts.poppins().copyWith(
                        color: otherUser
                            ? const Color.fromRGBO(184, 175, 175, 1)
                            : const Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: otherUser,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${time.hour}:${time.minute}",
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
