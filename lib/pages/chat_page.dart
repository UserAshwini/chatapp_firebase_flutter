import 'package:chatapp_firebase_flutter/pages/group_info.dart';
import 'package:chatapp_firebase_flutter/service/database_service.dart';
import 'package:chatapp_firebase_flutter/widgets/message_tile.dart';
import 'package:chatapp_firebase_flutter/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  
  bool isLoading = false;

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: const Color.fromARGB(209, 3, 120, 81),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Color.fromARGB(255, 151, 151, 151),
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  // chatMessages() {
  //   return StreamBuilder(
  //     stream: chats,
  //     builder: (context, AsyncSnapshot snapshot) {
  //       return snapshot.hasData
  //           ? ListView.builder(
  //               itemCount: snapshot.data.docs.length,
  //               itemBuilder: (context, index) {
  //                 return MessageTile(
  //                     message: snapshot.data.docs[index]['message'],
  //                     sender: snapshot.data.docs[index]['sender'],
  //                     sentByMe: widget.userName ==
  //                         snapshot.data.docs[index]['sender']);
  //               },
  //             )
  //           : Container();
  //     },
  //   );
  // }
  chatMessages() {
  return StreamBuilder(
    stream: chats,
    builder: (context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return  Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                );
      } else if (snapshot.hasError) {
        // If there's an error with the stream, display an error message.
        return Center(
          child: Text("Error: ${snapshot.error}"),
        );
      } else if (snapshot.hasData) {
        // If data is available, display the chat messages.
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: snapshot.data.docs[index]['message'],
              sender: snapshot.data.docs[index]['sender'],
              sentByMe: widget.userName == snapshot.data.docs[index]['sender'],
            );
          },
        );
      } else {
        // If there's no data and no error, display a message indicating no messages.
        return const Center(
          child: Text("No messages available."),
        );
      }
    },
  );
}


  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
