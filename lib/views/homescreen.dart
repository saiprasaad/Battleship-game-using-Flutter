import 'package:battleships/models/games.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/gameslist.dart';
import 'package:battleships/views/login.dart';
import 'package:battleships/views/placeships.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String baseUrl = 'http://165.227.117.48/games';
  final String username;
  const HomeScreen({required this.username, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Games>>? futureGames;
  bool isActiveGames = true;

  @override
  void initState() {
    super.initState();
    futureGames = _loadGames();
  }

  Future<List<Games>> _loadGames() async {
    final response = await http.get(
      Uri.parse(widget.baseUrl),
      headers: {
        'Authorization': await SessionManager.getSessionToken(),
      },
    );
    if (response.statusCode == 401) {
      if (!mounted) return List.empty();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
      return List.empty();
    }
    Map<String, dynamic> map = json.decode(response.body);
    if (isActiveGames == true) {
      List<Games> games =
          List<Games>.from(map['games'].map((x) => Games.fromJson(x)))
              .where((element) => element.status == 0 || element.status == 3)
              .toList();
      return games;
    } else {
      List<Games> games =
          List<Games>.from(map['games'].map((x) => Games.fromJson(x)))
              .where((element) => element.status == 1 || element.status == 2)
              .toList();
      return games;
    }
  }

  Future<void> deleteGame(List<Games> games, int id) async {
    final response = await http.delete(
      Uri.parse("${widget.baseUrl}/$id"),
      headers: {
        'Authorization': await SessionManager.getSessionToken(),
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        games.removeWhere((game) => game.id == id);
      });
    }
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const Login(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureGames,
        builder: (context, snapshot) {
                    if(snapshot.hasData) {
            final games = snapshot.data as List<Games>;
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Battleship'),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() { 
                          futureGames = _loadGames();
                        });
                      },
                    )
                  ],
                ),
                body: GamesList(games: games, isActiveGames: isActiveGames),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    "Battleships",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text("Logged In as ${widget.username}",
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.white))
                                ])),
                      ),
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 10),
                            Text('New Game'),
                          ],
                        ),
                        onTap: () async {
                          var result = await Navigator.of(context).push(
                              MaterialPageRoute<Games>(builder: (context) {
                            return const PlaceShips(isBot: false);
                          }));
                          if (!mounted) return;
                          if (result != null) {
                            setState(() {
                              if(isActiveGames) {
                                games.add(result);
                              }
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.android),
                            SizedBox(width: 10),
                            Text('New Game (AI)'),
                          ],
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showAIModeDialog(context, games);
                        },
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            const Icon(Icons.list),
                            const SizedBox(width: 10),
                            isActiveGames
                                ? const Text('Show Completed Games')
                                : const Text('Show Active Games'),
                          ],
                        ),
                        onTap: () async {
                          setState(() {
                            isActiveGames = !isActiveGames;
                            futureGames = _loadGames();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 10),
                            Text('Logout'),
                          ],
                        ),
                        onTap: () async {
                          await logout();
                        },
                      ),
                    ],
                  ),
                ));
          }
          return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              )
          );
        });
  }

  void showAIModeDialog(BuildContext context, List<Games> games) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Which AI you want to play against ?",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  var result = await Navigator.of(context)
                      .push(MaterialPageRoute<Games>(builder: (context) {
                    return const PlaceShips(isBot: true, botMode: 'random');
                  }));
                  if (!mounted) return;
                  if (result != null) {
                    setState(() {
                      if (isActiveGames) {
                        games.add(result);
                      }
                    });
                  }
                },
                child: const Text(
                  'Random',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  var result = await Navigator.of(context)
                      .push(MaterialPageRoute<Games>(builder: (context) {
                    return const PlaceShips(
                      isBot: true,
                      botMode: "perfect",
                    );
                  }));
                  if (!mounted) return;
                  if (result != null) {
                    setState(() {
                      if (isActiveGames) {
                        games.add(result);
                      }
                    });
                  }
                },
                child: const Text(
                  'Perfect',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  var result = await Navigator.of(context)
                      .push(MaterialPageRoute<Games>(builder: (context) {
                    return const PlaceShips(isBot: true, botMode: "oneship");
                  }));
                  if (!mounted) return;
                  if (result != null) {
                    setState(() {
                      if (isActiveGames) {
                        games.add(result);
                      }
                    });
                  }
                },
                child: const Text(
                  'One ship (A1)',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
