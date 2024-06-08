import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flessh_chat/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  Future<void> registr(
      {required String email, required String password}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final token = await credential.user?.getIdToken() ?? '';
        log(token.toString());
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.toString());
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    password: password,
                  )),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Register',
              style: TextStyle(
                color: Colors.black,
                fontSize: 42,
                fontWeight: FontWeight.w500,
                height: 60.51 / 50,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailCtl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordCtl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your passsword',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    if (emailCtl.text.isNotEmpty &&
                        passwordCtl.text.isNotEmpty) {
                      registr(
                        email: emailCtl.text,
                        password: passwordCtl.text,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Поля пустой болбоо кере!!!'),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff61B1EA)),
                    shadowColor: MaterialStateProperty.all<Color>(
                        const Color(0x40198DE1)),
                    elevation: MaterialStateProperty.all<double>(8.0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )),
            )
          ],
        ),
      )),
    );
  }
}
