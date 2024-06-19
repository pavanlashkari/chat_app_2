import 'message_model.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
  });

  // Deserialize JSON data into a Chat object
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m))
          .toList(),
    );
  }

  // Serialize a Chat object into JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'messages': messages?.map((m) => m.toJson()).toList() ?? [],
    };
  }
}
