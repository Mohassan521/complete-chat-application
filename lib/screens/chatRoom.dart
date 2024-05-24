import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/models/chatMessage.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/models/userProfile.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/database_service.dart';
import 'package:messenger/services/media_service.dart';
import 'package:messenger/services/storage_service.dart';
import 'package:messenger/utils.dart';

class ChatRoom extends StatefulWidget {
  final UserProfile chatUser;
  const ChatRoom({super.key, required this.chatUser});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ],
            createdAt: m.sentAt!.toDate());
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();

    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    return chatMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.chatUser.name!),
        ),
        body: StreamBuilder(
            stream:
                _databaseService.getChatData(currentUser!.id, otherUser!.id),
            builder: (context, snapshot) {
              Chat? chat = snapshot.data?.data();

              List<ChatMessage> messages = [];
              if (chat != null && chat.messages != null) {
                messages = _generateChatMessageList(chat.messages!);
              }
              return DashChat(
                messageOptions: MessageOptions(
                  showOtherUsersAvatar: true,
                  showTime: true,
                ),
                inputOptions: InputOptions(alwaysShowSend: true, leading: [
                  IconButton(
                      onPressed: () async {
                        File? _file = await _mediaService.getImageFromGallery();
                        if (_file != null) {
                          String chatID = generateChatId(
                              uid1: currentUser!.id, uid2: otherUser!.id);
                          String? downloadURL = await _storageService
                              .uploadChatFiles(file: _file, chatID: chatID);

                          if (downloadURL != null) {
                            ChatMessage message = ChatMessage(
                              user: currentUser!,
                              createdAt: DateTime.now(),
                              medias: [
                                ChatMedia(
                                    url: downloadURL,
                                    fileName: "",
                                    type: MediaType.image)
                              ],
                            );

                            _sendMessage(message);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(
                  //       Icons.attach_file,
                  //       color: Theme.of(context).colorScheme.primary,
                  //     )),
                ]),
                currentUser: currentUser!,
                onSend: _sendMessage,
                messages: messages,
              );
            }));
  }
}
