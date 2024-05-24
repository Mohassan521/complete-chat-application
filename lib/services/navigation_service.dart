import 'package:flutter/material.dart';
import 'package:messenger/screens/LoginPage.dart';
import 'package:messenger/screens/home.dart';
import 'package:messenger/screens/register.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/home": (context) => const HomeScreen(),
    "/register": (context) => const RegisterPage(),
  };

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Map<String, Widget Function(BuildContext)> get routes => _routes;

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacement(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
