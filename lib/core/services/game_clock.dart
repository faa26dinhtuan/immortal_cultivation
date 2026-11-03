class GameClock {
  int _elapsedHours = 6;

  int get day => _elapsedHours ~/ 24 + 1;
  int get hour => _elapsedHours % 24;

  void advanceHours(int hours) {
    _elapsedHours += hours;
  }
}
