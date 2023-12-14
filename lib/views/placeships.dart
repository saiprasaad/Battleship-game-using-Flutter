import 'package:battleships/models/games.dart';
import 'package:battleships/utils/gameutils.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceShips extends StatefulWidget {
  final bool isBot;
  final String? botMode;
  final String baseUrl = 'http://165.227.117.48/games';
  const PlaceShips({this.botMode, super.key, required this.isBot});

  @override
  State<PlaceShips> createState() => _PlaceShipsState();
}

class _PlaceShipsState extends State<PlaceShips> {
  Map<int, bool> selectedPositions = {};
  int selectedCount = 0;
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
    for (int i = 0; i < 36; i++) {
      selectedPositions[i] = false;
    }
  }

  Future<Games?> _loadGameById(int id) async {
    final response = await http.get(
      Uri.parse("${widget.baseUrl}/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': await SessionManager.getSessionToken(),
      },
    );
    if (!context.mounted) return null;
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return Games.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    }
    return null;
  }

  Future<void> _addNewGame() async {
    if (selectedCount != 5) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Start New Game failed. Select 5 ships to start.')));
      return;
    }
    List<String> selectedPositionsList = [];
    selectedPositions.forEach((k, v) => v == true
        ? selectedPositionsList.add(GameUtils.indexToShipPosition(k))
        : null);
    var body1 = {'ships': selectedPositionsList};
    var body2 = {'ships': selectedPositionsList, 'ai': widget.botMode};
    var response = await http.post(Uri.parse(widget.baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await SessionManager.getSessionToken(),
        },
        body: jsonEncode(widget.isBot ? body2 : body1));
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      Games game = Games.fromJson(responseBody);
      _loadGameById(game.id)
          .then((value) => {Navigator.of(context).pop(value)});
    } else if (response.statusCode == 401) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start New Game failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.of(context).size.width;
    double availableHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(title: const Text('Place Ships')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(children: [
              Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio:
                            (availableWidth / (availableHeight * 0.7)),
                      ),
                      itemCount: 36,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            color:
                                ((index > 0 && index < 6) || (index % 6 == 0))
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.white,
                            child: Center(
                                child: ((index > 0 && index < 6) ||
                                        (index % 6 == 0))
                                    ? Text(map[index].toString())
                                    : Card(
                                        color: selectedPositions[index] ?? false
                                            ? const Color.fromARGB(
                                                255, 137, 210, 54)
                                            : Colors.white,
                                        elevation: 0,
                                        child: InkWell(
                                            hoverColor: (selectedCount < 5)
                                                ? const Color.fromARGB(
                                                    255, 182, 234, 123)
                                                : const Color.fromARGB(
                                                    255, 148, 110, 107),
                                            onTap: () {
                                              setState(() {
                                                if (selectedPositions[index] ==
                                                        false &&
                                                    selectedCount < 5) {
                                                  selectedPositions[index] =
                                                      !selectedPositions[
                                                          index]!;
                                                  selectedCount++;
                                                } else if (selectedPositions[
                                                        index] ==
                                                    true) {
                                                  selectedPositions[index] =
                                                      !selectedPositions[
                                                          index]!;
                                                  selectedCount--;
                                                }
                                              });
                                            }),
                                      )));
                      }))
            ]),
            ElevatedButton(
                onPressed: () {
                  _addNewGame();
                },
                child: const Text("Submit"))
          ],
        ));
  }
}
