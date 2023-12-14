import 'dart:convert';

import 'package:battleships/models/games.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/gamepage.dart';
import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GamesList extends StatefulWidget {
  final String baseUrl = 'http://165.227.117.48/games';
  final List<Games> games;
  final bool isActiveGames;
  const GamesList({required this.games, required this.isActiveGames, super.key});

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
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
    else if (response.statusCode == 401) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    }
  }

  Future<void> _loadGameDetailsById(int index, int id) async {
    final response = await http.get(
      Uri.parse("${widget.baseUrl}/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': await SessionManager.getSessionToken(),
      },
    );
    if(response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    setState(() {
      Games game = Games.fromJsonToGame(responseBody);
      if((game.status == 1 || game.status == 2) && widget.isActiveGames) {
        widget.games.removeAt(index);
      } 
      else {
          widget.games[index] = game;
      }
    });
    }
    if (response.statusCode == 401) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    var games = widget.games;
    return ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Dismissible(
              key: UniqueKey(),
              direction: (games[index].status == 1 || games[index].status == 2)
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (direction) {
                deleteGame(games, games[index].id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Game ${games[index].id} forfeited')));
              },
              background: Container(color: Colors.red),
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute<Games>(builder: (context) {
                        return GamePage(id: games[index].id);
                      }),
                    ).then((_) => {setState(() {
                      _loadGameDetailsById(index, games[index].id);
                    })});
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                games[index].status != 0
                                    ? Row(children: [
                                        Text("# ${games[index].id.toString()}"),
                                        const SizedBox(width: 5),
                                        Text(games[index].player1),
                                        const SizedBox(width: 5),
                                        const Text("Vs"),
                                        const SizedBox(width: 5),
                                        Text(games[index].player2)
                                      ])
                                    : Row(children: [
                                        Text("# ${games[index].id.toString()}"),
                                        const SizedBox(width: 5),
                                        const Text("Waiting for opponent"),
                                      ])
                              ],
                            ),
                            if ((games[index].status == 0 ||
                                    games[index].status == 3) &&
                                games[index].turn == games[index].position &&
                                games[index].status == 3)
                              const Text("myTurn")
                            else if ((games[index].status == 0 ||
                                    games[index].status == 3) &&
                                games[index].turn != games[index].position &&
                                games[index].status == 3)
                              const Text("opponentTurn")
                            else if ((games[index].status == 0 ||
                                    games[index].status == 3) &&
                                (games[index].status == 0))
                              const Text("matchmaking")
                            else if ((games[index].status == 1 ||
                                    games[index].status == 2) &&
                                games[index].status == games[index].position)
                              const Text("gameWon")
                            else if ((games[index].status == 1 ||
                                    games[index].status == 2) &&
                                games[index].status != games[index].position)
                              const Text("gameLost")
                          ]))));
        });
  }
}
