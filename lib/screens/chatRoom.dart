import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/models/message.dart';
import 'package:messenger/models/userProfile.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/database_service.dart';
import 'package:messenger/services/media_service.dart';
import 'package:messenger/services/storage_service.dart';
import 'package:messenger/utils.dart';
import '../models/chatMessage.dart';

class ChatRoom extends StatefulWidget {
  final UserProfile? chatUser;
  const ChatRoom({super.key, required this.chatUser});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ChatUser? currentUser, otherUser;

  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;
  late MediaService _mediaService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser?.uid ?? "",
        firstName: widget.chatUser?.name,
        profileImage: widget.chatUser?.pfpURL);
  }

  Future<void> sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias?.first.type == MediaType.file) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias?.first.fileName,
            messageType: MessageType.file,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));

        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }

      if (chatMessage.medias?.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias?.first.url,
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
          sentAt: Timestamp.fromDate(
            chatMessage.createdAt,
          ));

      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessage = messages.map((m) {
      if (m.messageType == MessageType.file) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          medias: [
            ChatMedia(
                url: m.content!,
                fileName: m.content!.split("/").last,
                type: MediaType.file)
          ],
          createdAt: m.sentAt!.toDate(),
        );
      }

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

    chatMessage.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    return chatMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.chatUser?.pfpURL ?? ""),
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.chatUser?.name ?? "",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.call,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Icon(
                    Icons.video_call,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot<Chat>>(
            stream:
                _databaseService.getChatData(currentUser!.id, otherUser!.id),
            builder: (context, snapshot) {
              Chat? chat = snapshot.data?.data();
              List<ChatMessage> messages = [];

              print("chat waly messages ${snapshot.data?.data()}");

              print("current user: ${currentUser!.id}");
              print("other user: ${otherUser!.id}");
              print("chat id: , ${chat?.id!}");

              if (chat != null && chat.messages != null) {
                messages = _generateChatMessageList(chat.messages!);
              }

              print(messages.length);

              return DashChat(
                  messageOptions: MessageOptions(
                    showOtherUsersAvatar: true,
                    showTime: true,
                  ),
                  inputOptions: InputOptions(
                    alwaysShowSend: true,
                    leading: [
                      IconButton(
                          onPressed: () async {
                            File? file =
                                await _mediaService.getImageFromGallery();

                            if (file != null) {
                              String chatID = generateChatId(
                                  uid1: currentUser!.id, uid2: otherUser!.id);

                              String? downloadURL = await _storageService
                                  .uploadChatFiles(file: file, chatID: chatID);
                              if (downloadURL != null) {
                                ChatMessage chatMessage = ChatMessage(
                                  user: currentUser!,
                                  medias: [
                                    ChatMedia(
                                      url: downloadURL,
                                      fileName: "",
                                      type: MediaType.image,
                                    )
                                  ],
                                  createdAt: DateTime.now(),
                                );

                                sendMessage(chatMessage);
                              }
                            }
                          },
                          icon: Icon(
                            Icons.image,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      IconButton(
                        onPressed: () async {
                          File? file = await _mediaService.getFileFromDevice();

                          if (file != null) {
                            String chatID = generateChatId(
                                uid1: currentUser!.id, uid2: otherUser!.id);

                            String fileExt =
                                file.path.split(Platform.pathSeparator).last;
                            // print(
                            //     "file path name: ${file.path.split('/').last}");

                            String? downloadURL = await _storageService
                                .uploadChatPdfFiles(file: file, chatID: chatID);

                            print("download url before if body: $downloadURL");
                            if (downloadURL != null) {
                              print(
                                  "File downloaded successfully: $downloadURL");
                              ChatMessage chatMessage = ChatMessage(
                                user: currentUser!,
                                medias: [
                                  ChatMedia(
                                    url: downloadURL,
                                    fileName: fileExt,
                                    type: MediaType.file,
                                  )
                                ],
                                createdAt: DateTime.now(),
                              );

                              sendMessage(chatMessage);
                            }
                          }
                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  currentUser: currentUser!,
                  onSend: sendMessage,
                  messages: messages);
            }));
  }
}
