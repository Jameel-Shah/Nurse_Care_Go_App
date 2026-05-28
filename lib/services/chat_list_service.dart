import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/model/chat_list_item_model.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';

class ChatListService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instance for chat list node/folder/database
  final DatabaseReference _chatListDB = FirebaseDatabase.instance.ref(
    'ChatList',
  );
  // Instance for chats node/folder/database
  // final DatabaseReference _chatDB = FirebaseDatabase.instance.ref('Chats');
  // Instance for nurses node/folder/database
  final DatabaseReference _nursesDB = FirebaseDatabase.instance.ref('Nurses');
  // Instance for patients node/folder/database
  final DatabaseReference _patientsDB = FirebaseDatabase.instance.ref(
    'Patients',
  );
  // Getting current user's id
  String get _currentUid => _auth.currentUser!.uid;

  // Stream Method for fetching the whole chat list
  Stream<List<ChatListItemModel>> fetchChatList(){
    // StreamController lets us manually push data or errors into the stream
    // without the stream terminating on error
    // '.onValue' fires immediately with current data, also on every change
    final controller= StreamController<List<ChatListItemModel>>();
    bool hasEmitted= false; // tracks if any data or error is pushed
    // This timer fires if onValue never emits within 8 seconds
    // Also this covers the case where Firebase hangs offline without firing at all,
    // which happens consistently on web(no cache) and sometimes happens on physical devices with no cached data
    final timedOutTimer= Timer(const Duration(seconds: 8), (){
      if(!hasEmitted && !controller.isClosed){
        hasEmitted=true;
        controller.addError(AppException('No internet connection. Please check your network.'));
      }
    });
    // Now listen to chatList changes
    final subscription= _chatListDB.child(_currentUid).onValue.listen((event)async{
      try{
        // "event.snapshot.value" has actual data if it is null then return an empty list
        if (event.snapshot.value == null) {
          hasEmitted=true;
          timedOutTimer.cancel(); // data arrived cancelling the timeout
          controller.add([]); // empty list
          return;
        }
        // The entire data comes in json format from Firebase
        // So, we convert it into a map(keys,values) and stores it into contacts variable
        final Map<dynamic, dynamic> contacts =
        event.snapshot.value as Map<dynamic, dynamic>;

        // Now we run all chat fetches in parallel instead of one by one
        // contacts.entries gives map-entries key & value pairs (contactId, data map)
        final futures= contacts.entries.map((entry)async{
          // We also store id's as strings
          // entry.key gives us nurse or patientId
          final contactId = entry.key.toString();
          // The last message is now in chat list thanks to 'chatService' class
          // entry.value gives us data map containing (lastMessage, lastMessageTime, contactId(nurse/patient)
          final Map<dynamic, dynamic> contactData= entry.value as Map<dynamic, dynamic>;
          // Last Message already available in chat list database
          final String lastMessage= contactData['lastMessage']?? 'No messages yet';
          // 'lastMessageTime' comes in form of milli seconds from Firebase. So we convert it into proper 'DateTime' object
          final int? lastMessageMillis= contactData['lastMessageTime'] as int?;
          final DateTime lastMessageTime= lastMessageMillis!=null? DateTime.fromMillisecondsSinceEpoch(lastMessageMillis): DateTime.now();
          // Now, we fetch user's name + picture (cheks nurses and then patients) using "_fetchUserInfo" by id
          final userInfo = await _fetchUserInfo(contactId);
          // If user's info (name & picture) is null then continue
          // Which means if user deletes their account then skips and move to the next
          if (userInfo == null) return null; // For deleted accounts
          // Now return the user-info and last seen messages to the list and also parse it to the chat list model
          return ChatListItemModel(
            userId: contactId,
            name: userInfo['name'] ?? 'Unknown',
            lastMessage: lastMessage, // Comes directly from chatList
            lastMessageTime: lastMessageTime, // Comes directly from chatList
            profileImageUrl: userInfo['profileImageUrl']?? '',
          );
        });
        // Now we wait for them all
        final rawResults= await Future.wait(futures);
        // Now sort chat List based on most recent message
        final results= rawResults.whereType<ChatListItemModel>().toList();
        results.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        hasEmitted=true;
        timedOutTimer.cancel();
        // Now push data into the stream with the help of controller
        if(!controller.isClosed) controller.add(results);
        // Also return the sorted list
        // return results;
      }on AppException catch(e){
        // Now we push error into the stream - StreamBuilder catches it as snapShot.Error
        hasEmitted=true;
        timedOutTimer.cancel();
        if(!controller.isClosed) controller.addError(e);
      }catch(e){
        hasEmitted=true;
        timedOutTimer.cancel();
        if(!controller.isClosed) controller.addError(AppException(ErrorHandler.parse(e)));
      }
    },
      onError: (e){
      hasEmitted=true;
      timedOutTimer.cancel();
      if(!controller.isClosed) controller.addError(AppException(ErrorHandler.parse(e)));
      }
    );
    // Now we clean up the controller when the stream is no longer listened to
    controller.onCancel=(){
      timedOutTimer.cancel();
      subscription.cancel();
      controller.close();
    };
    return controller.stream;

  }

  // Method for getting user info based of id,
  // First we check nurses then the patients
  Future<Map<String, dynamic>?> _fetchUserInfo(String uid) async {
    // First, we read the nurses data based on id
    // .once() reads data inside database one time and stops
    // It returns a DatabaseEvent object
    final nurseSnap = await _nursesDB.child(uid).once().timeout(const Duration(seconds: 8), onTimeout: ()=> throw AppException('No internet connection. Please check your network.'));
    // If snapshot has data then convert it into map
    if (nurseSnap.snapshot.value != null) {
      final data = nurseSnap.snapshot.value as Map<dynamic, dynamic>;
      return {
        'name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'profileImageUrl': data['profileImageUrl'],
      };
    }
    // Similarly for patients
    final patientSnap = await _patientsDB.child(uid).once().timeout(const Duration(seconds: 8), onTimeout: ()=> throw AppException('No internet connection. Please check your network.'));
    if (patientSnap.snapshot.value != null) {
      final data = patientSnap.snapshot.value as Map<dynamic, dynamic>;
      return {
        'name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'profileImageUrl': data['profileImageUrl'],
      };
    }
    return null; // Returns null if no data found
  }

}
