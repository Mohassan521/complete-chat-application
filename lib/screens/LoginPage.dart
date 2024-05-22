import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/services/alert_service.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  String? email, password;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }
  //

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Login",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )),
          SizedBox(
            height: 25,
          ),
          Form(
            key: _loginFormKey,
            child: Column(
              children: [
                TextFormField(
                  onSaved: (newValue) {
                    setState(() {
                      email = newValue;
                    });
                  },
                  validator: (value) {
                    if (value != null &&
                        EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                      return null;
                    }
                    return "Enter a valid email";
                  },
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter your Email",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
                    labelStyle:
                        TextStyle(color: Color(0xff941420), fontSize: 13),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                //
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onSaved: (newValue) {
                    setState(() {
                      password = newValue;
                    });
                  },
                  validator: (value) {
                    if (value != null &&
                        PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
                      return null;
                    }
                    return "Enter a valid password";
                  },
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter your Password",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
                    labelStyle:
                        TextStyle(color: Color(0xff941420), fontSize: 13),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //
          MaterialButton(
            onPressed: () async {
              _loginFormKey.currentState?.save();
              bool result = await _authService.login(email!, password!);
              print(result);
              if (result) {
                _navigationService.pushReplacement("/home");
              } else {
                _alertService.showToast(
                    icon: Icons.error,
                    text: "Failed to login, Please try again");
              }
            },
            child: Text("Login"),
            textColor: Colors.white,
            color: Theme.of(context).colorScheme.primary,
            minWidth: double.infinity,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Dont have an account? "),
              InkWell(
                  onTap: () {
                    _navigationService.pushNamed("/register");
                  },
                  child: Text(
                    "Register ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ],
          )
        ],
      ),
    ));
  }
}
