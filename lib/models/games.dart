class Games {
  int id;
  String player1;
  String player2;
  int position;
  int status;
  int turn;
  List<String>? ships;
  List<String>? shots;
  List<String>? sunk;
  List<String>? wreks;

  Games({required this.id, required this.player1, required this.player2,  required this.position, required this.status, required this.turn,  this.ships, this.shots, this.sunk, this.wreks});

  factory Games.fromJson(model) {
    return Games(id: model['id'], player1: model['player1'] ?? "", player2: model['player2'] ?? "", position: model['position'] ?? 0, 
    status: model['status'] ?? 0, turn: model['turn'] ?? 0);
  }

  factory Games.fromJsonToGame(model) {
    return Games(id: model['id'], player1: model['player1'] ?? "", player2: model['player2'] ?? "", position: model['position'] ?? 0, 
    status: model['status'] ?? 0, turn: model['turn'] ?? 0, ships:List<String>.from(model['ships'] as List), 
    shots:List<String>.from((model['shots'] ?? []) as List), sunk:List<String>.from((model['sunk'] ?? []) as List), 
    wreks:List<String>.from((model['wrecks'] ?? [])as List));
  }
}