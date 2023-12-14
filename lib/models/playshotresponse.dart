class PlayShotResponse {
  final String message;
  final bool sunkShip;
  final bool won;

  PlayShotResponse({required this.message, required this.sunkShip, required this.won});

  factory PlayShotResponse.fromJson(model) {
    return PlayShotResponse(message: model['message'] as String, sunkShip: model['sunk_ship'] as bool , won: model['won'] as bool);
  }

}