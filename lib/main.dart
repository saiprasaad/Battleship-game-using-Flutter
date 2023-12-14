import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/homescreen.dart';
import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Battleships',
    home: BattleShipState()
  ));
}

class BattleShipState extends StatefulWidget {
  const BattleShipState({super.key});

  @override
  State<BattleShipState> createState() => _BattleShipStateState();
}

class _BattleShipStateState extends State<BattleShipState> {

  bool isLoggedIn = false;
  String userName = "";

  @override
  void initState() {
    super.initState();
    checkIfUserLoggedIn();
  }

  Future<void> checkIfUserLoggedIn() async {
    final loggedIn = await SessionManager.isLoggedIn();
    final username = await SessionManager.getUserNameOfLoggedInUser();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
        userName = username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleship',
      home: isLoggedIn ? HomeScreen(username: userName): const  Login()
    );
  }
}

