import 'package:flutter/foundation.dart';

import '../../../core/services/game_clock.dart';
import '../world_region.dart';

class WorldController extends ChangeNotifier {
  final _clock = GameClock();
  WorldPlace _current = WorldPlace.cave;
  WorldPlace _selected = WorldPlace.cave;
  final _journal = <TravelEntry>[];

  WorldPlace get current => _current;
  WorldPlace get selected => _selected;
  int get day => _clock.day;
  int get hour => _clock.hour;
  Iterable<TravelEntry> get journal => _journal.reversed;

  List<WorldTrail> get route {
    final start = _current.index;
    final end = _selected.index;
    final first = start < end ? start : end;
    final last = start < end ? end : start;
    return regionalTrails.sublist(first, last);
  }

  int get travelHours => route.fold(0, (sum, trail) => sum + trail.hours);

  void select(WorldPlace place) {
    _selected = place;
    notifyListeners();
  }

  void travel() {
    final hours = travelHours;
    if (hours == 0) return;

    _clock.advanceHours(hours);
    _current = _selected;
    _journal.add((place: _current, hours: hours, day: day, hour: hour));
    notifyListeners();
  }
}

typedef TravelEntry = ({WorldPlace place, int hours, int day, int hour});
