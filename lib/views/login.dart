import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final url = Uri.parse('http://165.227.117.48/login');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access_token'];
      await SessionManager.setSessionTokenAndUserName(
          'Bearer $accessToken', username);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => HomeScreen(username: username),
      ));
    } else {
      final errorMsg = json.decode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.toString())),
      );
    }
  }

  Future<void> register(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final url = Uri.parse('http://165.227.117.48/register');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access_token'];
      await SessionManager.setSessionTokenAndUserName(
          'Bearer $accessToken', username);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => HomeScreen(username: username),
      ));
    } else {
      final errorMsg = json.decode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
          automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => login(context),
                  child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () => register(context),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
