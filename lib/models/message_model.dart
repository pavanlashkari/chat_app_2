import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
  });

  // Deserialize JSON data into a Message object
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderID: json['senderID'],
      content: json['content'],
      sentAt: json['sentAt'],
      messageType: MessageType.values
          .firstWhere((type) => type.toString() == 'MessageType.${json['messageType']}'),
    );
  }

  // Serialize a Message object into JSON data
  Map<String, dynamic> toJson() {
    return {
      'senderID': senderID,
      'content': content,
      'sentAt': sentAt,
      'messageType': messageType.toString().split('.').last,
    };
  }
}
