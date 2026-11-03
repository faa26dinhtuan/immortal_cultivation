import 'package:flutter/foundation.dart';

import '../../../core/services/game_clock.dart';
import '../../cultivation/cultivation_state.dart';
import '../world_region.dart';

enum FloodChoice {
  wait(2, DaoNiem.patience),
  detour(1, DaoNiem.adaptability);

  const FloodChoice(this.extraHours, this.daoNiem);

  final int extraHours;
  final DaoNiem daoNiem;
}

class WorldController extends ChangeNotifier {
  final _clock = GameClock();
  final cultivation = CultivationState();
  WorldPlace _current = WorldPlace.cave;
  WorldPlace _selected = WorldPlace.cave;
  final _journal = <TravelEntry>[];
  bool _floodPending = false;
  bool _floodResolved = false;

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

  bool get canCultivate => _current == WorldPlace.cave && !_floodPending;

  void retreat() {
    if (!canCultivate) return;
    cultivation.retreat();
    _clock.advanceHours(CultivationState.retreatHours);
    notifyListeners();
  }

  void breakThrough(DaoNiem? insight) {
    if (!canCultivate || !cultivation.breakThrough(insight)) return;
    notifyListeners();
  }

  void select(WorldPlace place) {
    if (_floodPending) return;
    _selected = place;
    notifyListeners();
  }

  bool beginTravel() {
    if (_floodPending || _current == _selected) return false;

    if (!_floodResolved &&
        _current == WorldPlace.cave &&
        _selected == WorldPlace.landing) {
      _floodPending = true;
      return true;
    }

    _finishTravel();
    return false;
  }

  void resolveFlood(FloodChoice? choice) {
    if (!_floodPending) return;
    _floodPending = false;
    if (choice == null) return;

    _floodResolved = true;
    cultivation.gainInsight(choice.daoNiem);
    _finishTravel(choice);
  }

  void _finishTravel([FloodChoice? choice]) {
    final hours = travelHours + (choice?.extraHours ?? 0);
    _clock.advanceHours(hours);
    _current = _selected;
    _journal.add((
      place: _current,
      hours: hours,
      day: day,
      hour: hour,
      floodChoice: choice,
    ));
    notifyListeners();
  }
}

typedef TravelEntry = ({
  WorldPlace place,
  int hours,
  int day,
  int hour,
  FloodChoice? floodChoice,
});
