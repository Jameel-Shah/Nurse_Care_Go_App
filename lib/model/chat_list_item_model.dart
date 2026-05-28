class ChatListItemModel {
  final String userId;
  final String name;
  final String profileImageUrl; // Can be null
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatListItemModel({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.profileImageUrl
});
}