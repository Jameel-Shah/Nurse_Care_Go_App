import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/model/chat_message_model.dart';
import '../resources/utils/error_handler.dart';

class ChatService {
  // Creating instance for 'Chats' database
  final DatabaseReference _chatDB = FirebaseDatabase.instance.ref('Chats');
  // Creating instance for 'ChatList' database
  final DatabaseReference _chatListDB = FirebaseDatabase.instance.ref(
    'ChatList',
  );
  // Creating instance for 'Status' database
  final DatabaseReference _statusDB = FirebaseDatabase.instance.ref('Status');

  // Method for sending message between users
  Future<void> sendMessage({
    required String senderUid,
    required String receiverUid,
    required String message,
  }) async {
    try {
      // We will create a 'room-key' in which messages will be grouped for specific users
      // For example: if senderUid= 'patient1' and receiverUid='nurse1', then roomKey will be [nurse1_patient1]
      // Also sort the ids. If ids are not sorted like if nurse send message back to patient after receiving
      // then another roomKey will be created like 'roomKey=[patient1_nurse1]' which will cause chats to be split across multiple rooms,
      // So patient and nurse will never see their messages. That's why sorting is important
      // Regardless of who the sender/receiver is
      final List<String> ids = [senderUid, receiverUid]..sort();
      final String roomKey = '${ids[0]}_${ids[1]}';
      // Now we will generate a unique chat id by using "push" method inside the room-key not at the top level of 'Chats' database
      final String chatId = _chatDB.child(roomKey).push().key!;
      // Now, we wrap all data into our clean model
      final ChatMessageModel chatMessage = ChatMessageModel(
        id: chatId,
        message: message,
        senderUid: senderUid,
        receiverUid: receiverUid,
        timeStamp: DateTime.now(),
      );
      // Save the message inside database and inside chat room-key
      await _chatDB
          .child(roomKey)
          .child(chatId)
          .set(chatMessage.toMap())
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw AppException(
              'Message could not sent. Please check your connection.',
            ),
          );
      // Now, we update both users(patient & nurse can see their conversations) chatList by storing latest message
      // Why? because when nurse opens their chat list, they see the patient,
      // Similarly when patient opens their chat list, they see the nurse.
      final lastMessageUpdateForSender = {
        'lastMessage': message,
        'lastMessageTime': ServerValue.timestamp,
        'contactId': receiverUid,
      };
      final lastMessageUpdateForReceiver = {
        'lastMessage': message,
        'lastMessageTime': ServerValue.timestamp,
        'contactId': senderUid,
      };
      // Future.wait will run both chatList updates at the same time much faster
      // This will cause the chatList streams to be rebuild faster
      await Future.wait([
        _chatListDB
            .child(senderUid)
            .child(receiverUid)
            .update(lastMessageUpdateForSender),
        _chatListDB
            .child(receiverUid)
            .child(senderUid)
            .update(lastMessageUpdateForReceiver),
      ]);
    } catch (e) {
      // 'ErrorHandler.parse' converts Firebase/socket/unknown error
      // into clean user-facing messages, then we wrap in AppException
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // Stream of messages between two users, sorted by time
  // '.onValue' gives us live stream of messages
  // which means every time any message is added into the 'Chats' node or database,
  // 'onValue' runs and gives the stream of messages
  // .map transforms each event into a map
  Stream<List<ChatMessageModel>> getMessage(
    String currentUid,
    String otherUid,
  ) {
    // We build the same room-key here for specific chats between two users
    // And sort and store them inside the room
    final List<String> ids = [currentUid, otherUid]..sort();
    final String roomKey = '${ids[0]}_${ids[1]}';
    // No we listen only to one specific chat/room between two users not all of the chats
    return _chatDB.child(roomKey).onValue.map((event) {
      // If there is no event snapshot(id, message),
      // Then return an empty list
      if (event.snapshot.value == null) return [];
      // Firebase returns data as raw map,
      // SO, we cast it it so Dart knows what type it is
      final Map<dynamic, dynamic> rawMap =
          event.snapshot.value as Map<dynamic, dynamic>;
      // Previously we were using 'forEach' to fetch messages and add tem into an empty list,
      // Now we use 'rawMap.entries' which also gives us key-value pairs,
      // .map transforms each entry(key,value) into map and '.toList()' collects the results
      // That is why we no longer need an empty list
      final List<ChatMessageModel> messages = rawMap.entries
          .map((entry) => ChatMessageModel.fromMap(entry.key, entry.value))
          .toList();
      // Also, we sort the messages list from from oldest to newest
      messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      // Also, we return the messages list
      return messages;
    });
  }

  // --- Online & Offline methods
  // This method will be called once when the user logs-in/app opens
  Future<void> setOnline(String uid) async {
    // First, we get current user id
    final reference = _statusDB.child(uid);
    // Then we set the user to 'online' and keep track of his/her time in Firebase using Firebase's server clock
    await reference.set({'online': true, 'lastSeen': ServerValue.timestamp});
    // Now, we call 'onDisconnect' method which will automatically fires when the connection drops or app closes
    // Which will set user to 'offline'
    await reference.onDisconnect().update({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Now, we create a method that will be called on logout
  // Which will set user to 'offline' and keep track of his/her time in Firebase using Firebase's server clock
  Future<void> setOffline(String uid) async {
    await _statusDB.child(uid).update({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Stream the online status of the specific user
  Stream<bool> getUserOnlineStatus(String uid) {
    // It listens to Status/{uid}/online ,
    // The moment it changes to true/false,
    // Appbar will rebuild itself automatically via stream-builder
    return _statusDB
        .child(uid)
        .child('online')
        .onValue
        .map((event) {
          return event.snapshot.value == true;
        })
        .handleError((e) {
          throw AppException(ErrorHandler.parse(e));
        });
  }

  // Stream the lastSeen timeStamp of the user
  Stream<DateTime?> getUserLastSeen(String uid) {
    // lastSeen time from Firebase comes as milliseconds and in big int form
    // So, we convert it to proper DateTime format
    return _statusDB
        .child(uid)
        .child('lastSeen')
        .onValue
        .map((event) {
          // If event snapShot value is null then
          if (event.snapshot.value == null) return null;
          final millis = event.snapshot.value as int;
          return DateTime.fromMillisecondsSinceEpoch(millis);
        })
        .handleError((e) {
          throw AppException(ErrorHandler.parse(e));
        });
  }
}
