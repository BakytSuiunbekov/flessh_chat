// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flessh_chat/components/message_widget.dart';
import 'package:flessh_chat/models/user_model.dart';
import 'package:flessh_chat/pages/welcome_page.dart';
import 'package:flessh_chat/service/auth_service.dart';
import 'package:flessh_chat/service/home_service.dart';

enum SampleItem {
  Delate,
  Logout,
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.password,
  }) : super(key: key);
  final String password;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  SampleItem? selectedItem;
  String splitText(String text) {
    final sms = text.trim();
    if (sms != '') {
      return sms;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 233, 230),
      appBar: AppBar(
        surfaceTintColor: const Color.fromARGB(255, 204, 233, 230),
        title: const Text('Chat'),
        backgroundColor: const Color.fromARGB(255, 204, 233, 230),
        actions: [
          PopupMenuButton<SampleItem>(
            initialValue: selectedItem,
            onSelected: (SampleItem item) async {
              setState(() {
                selectedItem = item;
              });
              if (item == SampleItem.Logout) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                  (route) => false,
                );
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('password');
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                  (route) => false,
                );
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('password');
                await AuthService().deleteUser(widget.password);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                value: SampleItem.Delate,
                child: Text(' Delete account'),
              ),
              const PopupMenuItem<SampleItem>(
                value: SampleItem.Logout,
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Expanded(
            child: SizedBox(
          child: StreamBuilder(
            stream: HomeService.streamMessage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final message = (snapshot.data!.docs.reversed).map(
                  (e) => UserModel.fromMap(
                    e.data(),
                  )..isMe = e.data()['user'] ==
                      FirebaseAuth.instance.currentUser!.email,
                );

                return ListView(
                  children: message
                      .map(
                        (e) => MessageWidget(userModel: e),
                      )
                      .toList(),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        )),
        Container(
          margin: const EdgeInsets.only(left: 10),
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Текст жазыныз ...',
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final text = controller.text;
                  controller.clear();
                  if (controller.text.isNotEmpty) {
                    await HomeService.sendMessege(splitText(text));

                    setState(() {});
                  }
                },
                icon: const Icon(Icons.near_me),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
