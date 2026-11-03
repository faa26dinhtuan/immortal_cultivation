class GameClock {
  GameClock({int elapsedHours = 6}) : _elapsedHours = elapsedHours;

  int _elapsedHours;

  int get elapsedHours => _elapsedHours;
  int get day => _elapsedHours ~/ 24 + 1;
  int get hour => _elapsedHours % 24;

  void advanceHours(int hours) {
    _elapsedHours += hours;
  }
}
