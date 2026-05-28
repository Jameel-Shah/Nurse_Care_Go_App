class ChatMessageModel {
  final String id;
  final String message;
  final String senderUid;
  final String receiverUid;
  final DateTime timeStamp;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.senderUid,
    required this.receiverUid,
    required this.timeStamp,
  });


  factory ChatMessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatMessageModel(
      id: id,
      message: map['message'] ?? '',
      senderUid: map['senderUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      timeStamp: DateTime.tryParse(map['timeStamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'message': message,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'timeStamp': timeStamp.toIso8601String()
    };
  }

}
