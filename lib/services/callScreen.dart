import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final String userId;
  final String username;
  const CallScreen(
      {super.key,
      required this.callID,
      required this.userId,
      required this.username});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID:
          1249034424, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign:
          "352ec9560989c25b49dc63ea9107777add4c58b8e8b41614d6dc993b1d33d3a5", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userId,
      userName: username,
      callID: callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
