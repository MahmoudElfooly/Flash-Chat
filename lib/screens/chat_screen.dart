import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static String id = 'Chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  
  String message;
  final textEditingController=TextEditingController();
  void getCurrentUserName() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserName();
  }

  // void getmessageStream() async {
  //   await for (var snapShot in _fireStore.collection('messages').snapshots()) {
  //     for (var message in snapShot.documents) {
  //       print(message.data);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // getmessageStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           StreamMessage(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textEditingController.clear();
                      _fireStore.collection('messages').add({
                        'text': message,
                        'sender': loggedInUser.email,
                      });
                      
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender, text;
  final bool isME;
  MessageBubble({this.sender, this.text,this.isME});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isME? CrossAxisAlignment.end :CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(30),
            
            color:isME? Colors.lightBlueAccent : Colors.grey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: Text(
                '$text ',
                style: TextStyle(
                  fontSize: 20,
                  color: isME ? Colors.white:Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 class StreamMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection('messages').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  }
                  final messages = snapshot.data.documents.reversed;
                  List<MessageBubble> messageWidgets = [];
                  for (var message in messages) {
                    final messageText = message.data['text'];
                    final messageSender = message.data['sender'];
                    final currentUser=loggedInUser.email;
                    final messageWidget = MessageBubble(
                      sender: messageSender,
                      text: messageText,
                      isME: currentUser==messageSender,
                    );
                    messageWidgets.add(messageWidget);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageWidgets,
                    ),
                  );
                });
  }
}