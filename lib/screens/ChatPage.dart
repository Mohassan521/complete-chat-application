import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/models/chatUsers.dart';
import 'package:messenger/screens/chatDetail.dart';
import 'package:messenger/services/alert_service.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/navigation_service.dart';
import 'package:messenger/widgets/conversationList.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  List<ChatUsers> chatUsers = [
    ChatUsers(
        name: "Virat Kohli",
        messageText: "Kohli goes down the ground",
        imageURL:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWq0epok62sIx9Wnoybw3PxXcHZH7hlCUVS7s1K6lCjA&s",
        time: "Now"),
    ChatUsers(
        name: "AB De Villiers",
        messageText: "I am the real king here",
        imageURL:
            "https://media.crictracker.com/media/featureimage/2019/09/CT_350909.jpg",
        time: "Yesterday"),
    ChatUsers(
        name: "Pat Cummins",
        messageText: "Silencing the 100k crowd",
        imageURL:
            "https://www.japantimes.co.jp/japantimes/uploads/images/2023/11/20/264436.JPG",
        time: "31 April"),
    ChatUsers(
        name: "M Amir",
        messageText: "one minute down, next minute up",
        imageURL:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjUm2jXnUaPQg4UG_OAiO23N4LU5Gj3MXxR-aaR-L60A&s",
        time: "28 April"),
    ChatUsers(
        name: "Michael Jordan",
        messageText: "There is no 'i' in team but there is in win",
        imageURL:
            "https://upload.wikimedia.org/wikipedia/commons/a/ae/Michael_Jordan_in_2014.jpg",
        time: "23 April"),
    ChatUsers(
        name: "Ricky Ponting",
        messageText: "I've told the guys to keep their heads up",
        imageURL:
            "https://bsmedia.business-standard.com/_media/bs/img/article/2019-02/17/full/1550403842-375.jpg?im=FeatureCrop,size=(826,465)",
        time: "20 April"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20.5, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Conversations",
                      style: TextStyle(
                          fontSize: 30.5, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () async {
                        bool result = await _authService.logout();
                        _alertService.showToast(
                            icon: Icons.check, text: "Successfully logged out");
                        if (result) {
                          _navigationService.pushReplacement("/login");
                        }
                      },
                      child: Icon(
                        Icons.logout,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ConversationList(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatDetail(
                                  image: chatUsers[index].imageURL,
                                  name: chatUsers[index].name,
                                  status:
                                      (index == 0 || index == 3) ? true : false,
                                )));
                  },
                  name: chatUsers[index].name,
                  messageText: chatUsers[index].messageText,
                  imageUrl: chatUsers[index].imageURL,
                  time: chatUsers[index].time,
                  isMessageRead: (index == 0 || index == 3) ? true : false,
                );
              },
            ),
          ],
          //
        ),
      ),
    );
  }
}
