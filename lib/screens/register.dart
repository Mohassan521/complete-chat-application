import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/models/userProfile.dart';
import 'package:messenger/services/alert_service.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/database_service.dart';
import 'package:messenger/services/media_service.dart';
import 'package:messenger/services/navigation_service.dart';
import 'package:messenger/services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt getIt = GetIt.instance;
  late MediaService _mediaService;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  String? email, password, name;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _mediaService = getIt.get<MediaService>();
    _storageService = getIt.get<StorageService>();
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading)
              const Center(
                  child: Text(
                "Register",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              )),
            const SizedBox(
              height: 40,
            ),
            if (!isLoading)
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        File? file = await _mediaService.getImageFromGallery();
                        if (file != null) {
                          setState(() {
                            selectedImage = file;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.15,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : NetworkImage(PLACEHOLDER_PFP),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    TextFormField(
                      onSaved: (newValue) {
                        setState(() {
                          name = newValue;
                        });
                      },
                      validator: (value) {
                        if (value != null &&
                            NAME_VALIDATION_REGEX.hasMatch(value)) {
                          return null;
                        }
                        return "Enter a valid username";
                      },
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Username",
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
                        hintText: "Email",
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
                        return "1 uppercase, 1 lowercase, 1 number & 1 symbol is must";
                      },
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Password",
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
                    const SizedBox(
                      height: 10,
                    ),
                    //
                    MaterialButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        // King123!
                        try {
                          if ((_loginFormKey.currentState?.validate() ??
                                  false) &&
                              selectedImage != null) {
                            _loginFormKey.currentState?.save();
                            bool result =
                                await _authService.register(email!, password!);
                            if (result) {
                              String? pfpUrl =
                                  await _storageService.uploadUserProfile(
                                file: selectedImage!,
                                uid: _authService.user!.uid,
                              );

                              if (pfpUrl != null) {
                                await _databaseService.createUserProfile(
                                  userProfile: UserProfile(
                                    uid: _authService.user!.uid,
                                    name: name,
                                    pfpURL: pfpUrl,
                                  ),
                                );

                                _alertService.showToast(
                                    text: "User successfully registered",
                                    icon: Icons.check);

                                _navigationService.pushNamed("/login");
                              } else {
                                throw Exception(
                                    "Unable to upload profile picture");
                              }
                            } else {
                              throw Exception("Unable to register");
                            }
                          } else {
                            _alertService.showToast(
                                text: "Failed to register, Please try again",
                                icon: Icons.error);
                          }
                        } catch (e) {
                          print(e);
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text("Register"),
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.primary,
                      minWidth: double.infinity,
                    ),
                  ],
                ),
              ),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  InkWell(
                    onTap: () {
                      _navigationService.goBack();
                    },
                    child: Text(
                      "Login ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ));
  }
}
