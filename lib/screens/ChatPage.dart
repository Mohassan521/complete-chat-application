import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/models/chatUsers.dart';
import 'package:messenger/models/userProfile.dart';
import 'package:messenger/screens/chatDetail.dart';
import 'package:messenger/services/alert_service.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/database_service.dart';
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
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    style:
                        TextStyle(fontSize: 30.5, fontWeight: FontWeight.bold),
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
          StreamBuilder(
            stream: _databaseService.getUserProfiles(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("No Data Available"),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          UserProfile user = snapshot.data!.docs[index].data();
                          //print(user.name);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ConversationList(
                                userProfile: user, onTap: () {}),
                          );
                        }));
              }
              return CircularProgressIndicator();
            },
          )
        ],
      ),
    );
  }
}
