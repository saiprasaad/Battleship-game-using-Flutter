import 'package:battleships/models/games.dart';
import 'package:battleships/models/playshotresponse.dart';
import 'package:battleships/utils/gameutils.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GamePage extends StatefulWidget {
  final String baseUrl = 'http://165.227.117.48/games';
  final int id;
  const GamePage({required this.id, super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool isBot = false;
  late Future<Games?> futureGame;
  int selectedIndex = -1;
  Map<int, String> map = {
    0: "",
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "A",
    12: "B",
    18: "C",
    24: "D",
    30: "E"
  };

  @override
  void initState() {
    super.initState();
    futureGame = _loadGameDetailsById();
  }

  Future<Games?> _loadGameDetailsById() async {
    final response = await http.get(
      Uri.parse("${widget.baseUrl}/${widget.id}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': await SessionManager.getSessionToken(),
      },
    );

    if (!context.mounted) return null;
    if (response.statusCode == 401) {
     Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const Login(),
      ));
    }

    final responseBody = json.decode(response.body);
    Games game = Games.fromJsonToGame(responseBody);
    if (game.player2.contains("AI")) {
      isBot = true;
    }
    return game;
  }

  Future<void> _playShot(Games game, String shot) async {
    if (shot == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No position selected to attack')));
      setState(() {
        selectedIndex = -1;
      });
      return;
    } else if (game.shots!.contains(shot)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Shot already played')));
      setState(() {
        selectedIndex = -1;
      });
      return;
    }
    var response = await http.put(Uri.parse("${widget.baseUrl}/${widget.id}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await SessionManager.getSessionToken(),
        },
        body: jsonEncode({'shot': shot}));
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      PlayShotResponse playShotResponse =
          PlayShotResponse.fromJson(responseBody);
      if (playShotResponse.won == true) {
        showDialogBox("Game Won !");
      }
      bool isLost = false;
      setState(() {
        if (isBot == true) {
          futureGame = _loadGameDetailsById();
          futureGame.then((value) => {
                if ((value !=null && (value.status == 1 || value.status == 2)))
                  {
                    if (value.status != value.position)
                      {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                        isLost = true, showDialogBox("Game Lost !")}
                  }
               
              });
        }
        if (isBot == false) {
          (game.turn == 1) ? game.turn = 2 : game.turn = 1;
        }
        selectedIndex = -1;
         if (!playShotResponse.won == true && !isLost)
                  {
                    if (playShotResponse.sunkShip == true)
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ship Sunk !')));
                        game.sunk!.add(shot);
                      }
                    else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No enemy ship hit')));
                        game.shots!.add(shot);
                      }
                  }
      });
    } else if (response.statusCode == 401) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Play failed ${response.body}')),
      );
    }
  }

  Future<String?> showDialogBox(String result) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(result),
        actions: <Widget>[
          TextButton(
            onPressed: () => {
              Navigator.pop(context, 'OK'),
              ScaffoldMessenger.of(context).hideCurrentSnackBar()
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Games?>(
        future: futureGame,
        builder: (context, snapshot) {
          if(snapshot.hasData) {

            double availableWidth = MediaQuery.of(context).size.width;
            double availableHeight = MediaQuery.of(context).size.height;
            final gameDetails = snapshot.data as Games;
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Play Game'),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(children: [
                      Expanded(
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio:
                                    (availableWidth / (availableHeight * 0.6)),
                                crossAxisCount: 6,
                              ),
                              itemCount: 36,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  color: ((index > 0 && index < 6) ||
                                          (index % 6 == 0))
                                      ? Theme.of(context)
                                          .scaffoldBackgroundColor
                                      : (selectedIndex == index)
                                          ? const Color.fromARGB(
                                              255, 195, 141, 137)
                                          : Colors.white,
                                  child: InkWell(
                                      hoverColor:
                                          ((!(index > 0 && index < 6)) &&
                                                  (index % 6 != 0))
                                              ? const Color.fromARGB(
                                                  255, 182, 234, 123)
                                              : null,
                                      onTap: () {
                                        if ((index > 0 && index < 6) ||
                                            (index % 6 == 0)) {
                                          return;
                                        }
                                        setState(() {
                                          if (selectedIndex == index) {
                                            selectedIndex = -1;
                                          } else {
                                            selectedIndex = index;
                                          }
                                        });
                                      },
                                      child: Center(
                                          child: ((index > 0 && index < 6) ||
                                                  (index % 6 == 0))
                                              ? Text(map[index].toString())
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                      if (gameDetails.ships!
                                                          .contains(GameUtils
                                                              .indexToShipPosition(
                                                                  index)))
                                                        Text("🚢",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    availableHeight *
                                                                        0.025)),
                                                      if (gameDetails.wreks!
                                                              .isNotEmpty &&
                                                          gameDetails.wreks!
                                                              .contains(GameUtils
                                                                  .indexToShipPosition(
                                                                      index)))
                                                        Text("☠️",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    availableHeight *
                                                                        0.025)),
                                                      if (gameDetails.shots!
                                                              .isNotEmpty &&
                                                          gameDetails.shots!
                                                              .contains(GameUtils
                                                                  .indexToShipPosition(
                                                                      index)) &&
                                                          !gameDetails.sunk!
                                                              .contains(GameUtils
                                                                  .indexToShipPosition(
                                                                      index)))
                                                        Text("💣",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    availableHeight *
                                                                        0.025)),
                                                      if (gameDetails.sunk!
                                                              .isNotEmpty &&
                                                          gameDetails.sunk!
                                                              .contains(GameUtils
                                                                  .indexToShipPosition(
                                                                      index)))
                                                        Text("💥",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    availableHeight *
                                                                        0.025)),
                                                    ]))),
                                );
                              }))
                    ]),
                    ElevatedButton(
                        onPressed: (gameDetails.status != 3 ||
                                (gameDetails.status == 3 &&
                                    (gameDetails.turn != gameDetails.position)))
                            ? null
                            : () => {
                                  _playShot(
                                      gameDetails,
                                      GameUtils.indexToShipPosition(
                                          selectedIndex))
                                },
                        child: const Text("Submit"))
                  ],
                ));
          } return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        });
  }
}
