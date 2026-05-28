import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import '../../model/chat_list_item_model.dart';
import '../../resources/colors/colors.dart';
import '../../resources/components/general_exception_widget.dart';
import '../../services/chat_list_service.dart';
import '../chat_view/chat_view.dart';

class NurseChatListView extends StatefulWidget {
  const NurseChatListView({super.key});

  @override
  State<NurseChatListView> createState() => _NurseChatListViewState();
}

class _NurseChatListViewState extends State<NurseChatListView> {
  // Creating an instance to use 'ChatList' service class
  final ChatListService _chatListService = ChatListService();
  // Declaring a separate future variable to late
  late Stream<List<ChatListItemModel>> _stream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // We are calling 'fetchChatList' here in init-State
    // because whenever user opens chatList screen the fetching of chats will start immediately
    _stream = _chatListService.fetchChatList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: StreamBuilder<List<ChatListItemModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          // Showing a loading indicator,
          // Because it will be a good practice to make UI display something while data is being fetched from databse
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitFadingCircle(color: AppColors.blueColor);
          }
          // If there is an error then we show error widget
          if (snapshot.hasError) {
            // print('ChatList Error: ${snapshot.error}');
            // print('ChatList StackTrace: ${snapshot.stackTrace}');
            final message= snapshot.error is AppException?(snapshot.error as AppException).message: 'Something went wrong. Could not load chats';
            return GeneralExceptionWidget(
              onPress: ()=> setState(() {
                _stream= _chatListService.fetchChatList();
              }),
              message: message,
            );
          }
          // If there is no data or if the list is empty then show text
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return Center(
              child: Text(
                'No chats yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),
              ),
            );
          }
          // Now we show the data
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (_, index) => _buildTile(chats[index]),
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
            itemCount: chats.length,
          );
        },
      ),
    );
  }
  Widget _buildTile(ChatListItemModel item) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: ()=> _openChatScreen(item),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: item.profileImageUrl.isNotEmpty
            ? NetworkImage(item.profileImageUrl)
            : null,
        child: item.profileImageUrl.isEmpty
            ? Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?')
            : null,
      ),
      // Name
      title: Text(
        item.name,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      ),
      // Last Seen message
      subtitle: Text(
        item.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.greyColorShade600,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
      ),
      trailing: Text(
        _formatTime(item.lastMessageTime),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.greyColor,
        ),
      ),
    );
  }

  // Now we do time formatting by comparing day,month and year
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final isToday =
        time.year == now.year && time.month == now.month && time.day == now.day;
    return isToday
        ? DateFormat('hh:mm a').format(
      time,
    ) // This format is for displaying  message arrived at '3:45 PM' -- message today
        : DateFormat(
      'EEE',
    ).format(time); // This format is for 'Mon'-- Message older than today
  }

  // Navigation to chat-screen, works for both nurses and patients
  void _openChatScreen(ChatListItemModel item) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    //  works for both nurses & patients
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          nurseId: myUid,
          patientId: item.userId,
          patientProfilePic: item.profileImageUrl,
          patientName: item.name,
        ),
      ),
    );
  }
}
