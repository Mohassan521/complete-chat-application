import 'package:flutter/material.dart';
import 'package:messenger/models/userProfile.dart';

class ConversationList extends StatefulWidget {
  final UserProfile userProfile;
  final Function()? onTap;
  ConversationList({required this.userProfile, required this.onTap});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userProfile.pfpURL!),
              maxRadius: 29,
            ),
            SizedBox(
              width: 16,
            ),
            Container(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.userProfile.name!,
                    style: TextStyle(fontSize: 17.5),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  // Text(
                  //   widget.messageText ?? "",
                  //   style: TextStyle(
                  //     fontSize: 13,
                  //     color: Colors.grey.shade900,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
