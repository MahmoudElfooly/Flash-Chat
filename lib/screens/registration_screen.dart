import 'chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/Components/Round_Button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
class RegistrationScreen extends StatefulWidget {
  static String id = 'Register_Screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  final _auth = FirebaseAuth.instance;
  bool spinnerShow=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
            inAsyncCall: spinnerShow,
              child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: kTextFiledStyleColor,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter Your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                style: kTextFiledStyleColor,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.blueAccent,
                title: 'Register',
                onpressed: () async {
                  setState(() {
                    spinnerShow=true;
                  });
                  try {
                    final userName = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                        if(userName != null){
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                  } catch (e) {
                    print(e);
                  }
                  setState(() {
                    spinnerShow=false;
                  });

                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
