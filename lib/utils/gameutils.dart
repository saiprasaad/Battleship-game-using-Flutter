class GameUtils {
  static String indexToShipPosition(int index) {
    int count = -1;
    while(index >= 6){
      count++;
      index = index-6;
    }
    return count==-1 ? "" : String.fromCharCode(count+65) + index.toString();
  }

  static int shipToPosition(String shipPosition) {
    return (shipPosition[0].codeUnitAt(0) - 64) * 6 + int.parse(shipPosition[1]);
  }
}