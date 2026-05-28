import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:project_uaf/model/chat_message_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/chat_service.dart';
import 'package:project_uaf/view/chat_view/widgets/input_message_field.dart';
import 'package:project_uaf/view/chat_view/widgets/send_button.dart';

class ChatView extends StatefulWidget {
  final String nurseId;
  final String? nurseName;
  final String patientId;
  final String? patientName;
  final String? nurseProfilePic;
  final String? patientProfilePic;
  const ChatView({
    super.key,
    required this.nurseId,
     this.nurseName,
     this.nurseProfilePic,
     this.patientProfilePic,
    required this.patientId,
     this.patientName,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // Instance for chat service
  final ChatService _chatService = ChatService();
  // Text editing controller for message field
  final TextEditingController _messageController = TextEditingController();
  // Scroll controller for auto scrolling
  final ScrollController _scrollController = ScrollController();

  // Also initializing variables for current user's id, other user's name and id to late
  late final String _currentUserId;
  late final String _otherUserId;
  late final String _otherUserName;
  late final String _otherProfilePic;

  Timer? _timedOutTimer; // This will help track the timeout
  bool _timedOut = false; // controls which widget to show
  // Now we add a unique key that will force 'streamBuilder' to restart
  // When key changes, streamBuilder disposes old stream and creates a new one
  Key _streamKey = UniqueKey();
  void _startTimeOutTimer() {
    // cancel any existing timer before staring a new one,
    // also this helps prevents multiple timers running in the background
    _timedOutTimer?.cancel();
    _timedOutTimer = Timer(const Duration(seconds: 8), () {
      // Only executes or fires if stream has not delivered anything yet
      if (mounted) {
        setState(() {
          _timedOut = true;
        });
      }
    });
  }
  // Now we create a method to stop the timer,
  // This will execute when stream successfully delivers some data
  void _cancelTimeOutTimer() {
    _timedOutTimer?.cancel();
  }

  // This retry method will be used for both stream and time out errors
  void _retryMessage() {
    setState(() {
      _timedOut = false;
      _streamKey =
          UniqueKey(); // Forces 'streamBuilder' to restart with fresh stream
    });
    _startTimeOutTimer(); // restart the timer count down
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Now, we decide who is the other user
    final bool isNurse = _currentUserId == widget.nurseId;
    _otherUserId = isNurse ? widget.patientId : widget.nurseId;
    _otherUserName = isNurse ? widget.patientName! : widget.nurseName!;
    _otherProfilePic = isNurse
        ? widget.patientProfilePic!
        : widget.nurseProfilePic!;

    // Also, we make current user as online
    _chatService.setOnline(_currentUserId);
    _startTimeOutTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Also disposing message and scroll controllers
    _timedOutTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Method for sending messages
  void _sendMessage() async {
    // Having text from the controller in the variable
    final text = _messageController.text.trim();
    // If there is no text then return,
    if (text.isEmpty) return;
    // Also clearing the controller
    _messageController.clear();
    try {
      // Calling 'sendMessage' method from chat-Service class and passing current user's and other user's id
      // as well as text from message text field
      await _chatService.sendMessage(
        senderUid: _currentUserId,
        receiverUid: _otherUserId,
        message: text,
      );
      // Also, calling 'scrollToBottom' method
      _scrollToBottom();
    } on AppException catch (e) {
      // Catching and displaying error message
      Utils.showErrorMessage(e.message);
    }
  }

  // Method for auto-scrolling, whenever new messages come,
  // messages can scroll to the bottom of the screen automatically
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if there are messages then we design the scroll position and also set its animation
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildChatScreenAppbar(),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Appbar with avatar, name and online status, displayed by using 'StreamBuilders & ChatService class'
  AppBar _buildChatScreenAppbar() {
    return AppBar(
      title: StreamBuilder<bool>(
        stream: _chatService.getUserOnlineStatus(_otherUserId),
        builder: (context, onlineSnapShot) {
          final bool isOnline = onlineSnapShot.data ?? false;
          return Row(
            children: [
              // First Avatar with status dot
              Stack(
                children: [
                  // --- The avatar with image if it is available,
                  // if not then username's first letter will be displayed
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _otherProfilePic.isNotEmpty
                        ? NetworkImage(_otherProfilePic)
                        : null,
                    child: _otherProfilePic.isEmpty
                        ? Text(
                            _otherUserName[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  // --- The status dot located at the bottom right of the avatar
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.greenAccentColor
                            : AppColors.greyColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.whiteColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              // Name & lastSeen text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _otherUserName,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isOnline)
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.greenAccentColor,
                      ),
                    )
                  else
                    StreamBuilder<DateTime?>(
                      stream: _chatService.getUserLastSeen(_otherUserId),
                      builder: (context, lastSeenSnapshot) {
                        final lastSeen = lastSeenSnapshot.data;
                        final label = lastSeen != null
                            ? 'Last seen ${DateFormat('hh:mm a').format(lastSeen)}'
                            : 'Offline';
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            color: AppColors.greyColor,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Message list
  Widget _buildMessageList() {
    if(_timedOut){
      return GeneralExceptionWidget(onPress: _retryMessage, message: 'Connection timed out. Please check your network.');
    }
    return StreamBuilder<List<ChatMessageModel>>(
      key: _streamKey,
      stream: _chatService.getMessage(_currentUserId, _otherUserId),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          _cancelTimeOutTimer();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitFadingCircle(color: AppColors.blueColor));
        }
        if (snapshot.hasError) {
          final message= snapshot.error is AppException?(snapshot.error as AppException).message: 'Something went wrong. Could not load chats';
          return GeneralExceptionWidget(onPress: _retryMessage, message: message);
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(child: Text('No messages yet. Say hi!'));
        }

        // Auto-scroll when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        // Now build messages UI with the help of Listview.builder
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(messages[index]);
          },
        );
      },
    );
  }

  // Single message bubble
  Widget _buildMessageBubble(ChatMessageModel message) {
    final bool isMe = message.senderUid == _currentUserId;
    final String timeLabel = DateFormat('hh:mm a').format(message.timeStamp);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.blueColor : AppColors.newColor3,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomRight: isMe ? const Radius.circular(12) : Radius.zero,
            bottomLeft: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isMe? AppColors.whiteColor: AppColors.blackColor),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: TextStyle(fontSize: 10, fontFamily: 'Poppins', color: isMe? AppColors.whiteColor: AppColors.blackColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InputMessageField(
              controller: _messageController,
              keyboardType: TextInputType.multiline,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SendButton(onPress: _sendMessage),
        ],
      ),
    );
  }
}
