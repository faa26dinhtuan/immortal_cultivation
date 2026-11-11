import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/services/game_clock.dart';
import '../../../data/local/game_save_repository.dart';
import '../../cultivation/cultivation_state.dart';
import '../world_region.dart';

enum FloodChoice {
  wait(2, DaoNiem.patience),
  detour(1, DaoNiem.adaptability);

  const FloodChoice(this.extraHours, this.daoNiem);

  final int extraHours;
  final DaoNiem daoNiem;
}

enum JournalKind { travel, harvest, manual }

class WorldController extends ChangeNotifier {
  static const harvestHours = 1;
  static const surveyHours = 3;
  static const harvestYield = 1;

  WorldController({
    Map<String, dynamic>? snapshot,
    GameSaveRepository? repository,
    Random? random,
  }) : _repository = repository,
       _random = random ?? Random(),
       _journey = InterruptedJourney.fromJson(snapshot?['journey']),
       _clock = GameClock(
         elapsedHours: snapshot == null ? 6 : snapshot['elapsedHours'] as int,
       ),
       cultivation = snapshot == null
           ? CultivationState()
           : CultivationState(
               realm: CultivationRealm.values.byName(
                 snapshot['realm'] as String,
               ),
               progress: snapshot['progress'] as int,
               knowsManual: (snapshot['knowsManual'] as bool?) ?? false,
               insights: (snapshot['insights'] as List<dynamic>).map(
                 (name) => DaoNiem.values.byName(name as String),
               ),
             ),
       _herbs = (snapshot?['herbs'] as int?) ?? 0,
       _current = _savedPlace(snapshot),
       _selected =
           InterruptedJourney.fromJson(snapshot?['journey'])?.destination ??
           _savedPlace(snapshot),
       _journal = snapshot == null
           ? []
           : (snapshot['journal'] as List<dynamic>).map(_readEntry).toList(),
       _floodResolved = snapshot == null
           ? false
           : snapshot['floodResolved'] as bool;

  final GameSaveRepository? _repository;
  final Random _random;
  InterruptedJourney? _journey;
  final GameClock _clock;
  final CultivationState cultivation;
  WorldPlace _current;
  WorldPlace _selected;
  final List<JournalEntry> _journal;
  int _herbs;
  bool get floodPending => _journey != null;
  bool _floodResolved;
  bool _disposed = false;
  bool _saveFailed = false;
  Future<void> _writes = Future<void>.value();

  bool get saveFailed => _saveFailed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static WorldPlace _savedPlace(Map<String, dynamic>? snapshot) =>
      snapshot == null
      ? WorldPlace.cave
      : WorldPlace.values.byName(snapshot['current'] as String);

  static JournalEntry _readEntry(dynamic value) {
    final entry = value as Map<String, dynamic>;
    final choice = entry['floodChoice'] as String?;
    final kind = entry['kind'] as String?;
    return (
      kind: kind == null ? JournalKind.travel : JournalKind.values.byName(kind),
      place: WorldPlace.values.byName(entry['place'] as String),
      hours: entry['hours'] as int,
      day: entry['day'] as int,
      hour: entry['hour'] as int,
      floodChoice: choice == null ? null : FloodChoice.values.byName(choice),
    );
  }

  void _commit() {
    retrySave();
    notifyListeners();
  }

  void retrySave() {
    final repository = _repository;
    if (repository == null) return;

    final snapshot = <String, Object?>{
      'version': 1,
      'current': _current.name,
      'elapsedHours': _clock.elapsedHours,
      'realm': cultivation.realm.name,
      'progress': cultivation.progress,
      'knowsManual': cultivation.knowsManual,
      'herbs': _herbs,
      'insights': cultivation.insights.map((insight) => insight.name).toList(),
      'floodResolved': _floodResolved,
      'journey': _journey?.toJson(),
      'journal': [
        for (final entry in _journal)
          {
            'kind': entry.kind.name,
            'place': entry.place.name,
            'hours': entry.hours,
            'day': entry.day,
            'hour': entry.hour,
            'floodChoice': entry.floodChoice?.name,
          },
      ],
    };
    _writes = _writes.then((_) async {
      var failed = false;
      try {
        await repository.save(snapshot);
      } catch (_) {
        failed = true;
      }
      if (_disposed || failed == _saveFailed) return;
      _saveFailed = failed;
      notifyListeners();
    });
  }

  WorldPlace get current => _current;
  WorldPlace get selected => _selected;
  int get day => _clock.day;
  int get hour => _clock.hour;
  Iterable<JournalEntry> get journal => _journal.reversed;

  List<WorldTrail> get route =>
      _journey?.route ?? regionalRoute(_current, _selected);

  double get eventRisk =>
      !_floodResolved &&
          cultivation.realm == CultivationRealm.mortal &&
          route.any((trail) => trail.terrain == TrailTerrain.riverCrossing)
      ? 0.1
      : 0;

  WorldTrail? get interruptedTrail => floodPending
      ? route.firstWhere(
          (trail) => trail.terrain == TrailTerrain.riverCrossing,
          orElse: () => route.first,
        )
      : null;

  int get journeyElapsedHours => _journey?.elapsedHours ?? 0;
  int get remainingHours => travelHours - journeyElapsedHours;

  int get travelHours => route.fold(0, (sum, trail) => sum + trail.hours);

  bool get canCultivate => _current == WorldPlace.cave && !floodPending;

  int get herbs => _herbs;

  bool get canHarvest => _current == WorldPlace.landing && !floodPending;

  void harvest() {
    if (!canHarvest) return;
    _herbs += harvestYield;
    _clock.advanceHours(harvestHours);
    _journal.add((
      kind: JournalKind.harvest,
      place: _current,
      hours: harvestHours,
      day: day,
      hour: hour,
      floodChoice: null,
    ));
    _commit();
  }

  bool get canSurveyPass =>
      _current == WorldPlace.pass && !floodPending && !cultivation.knowsManual;

  void surveyPass() {
    if (!canSurveyPass) return;
    cultivation.learnManual();
    _clock.advanceHours(surveyHours);
    _journal.add((
      kind: JournalKind.manual,
      place: _current,
      hours: surveyHours,
      day: day,
      hour: hour,
      floodChoice: null,
    ));
    _commit();
  }

  void retreat({bool useHerb = false}) {
    if (!canCultivate) return;
    if (useHerb && _herbs == 0) return;
    if (useHerb) _herbs--;
    cultivation.retreat(useHerb: useHerb);
    _clock.advanceHours(CultivationState.retreatHours);
    _commit();
  }

  void breakThrough(DaoNiem? insight) {
    if (!canCultivate || !cultivation.breakThrough(insight)) return;
    _commit();
  }

  void select(WorldPlace place) {
    if (floodPending) return;
    _selected = place;
    notifyListeners();
  }

  bool beginTravel() {
    if (floodPending || _current == _selected) return false;
    final steps = route;
    if (steps.isEmpty) return false;
    final origin = _current;
    final hasFlood = eventRisk > 0 && _random.nextDouble() < eventRisk;
    var elapsed = 0;
    for (final step in steps) {
      if (hasFlood && step.terrain == TrailTerrain.riverCrossing) {
        final approachHours = step.hours ~/ 2;
        elapsed += approachHours;
        _clock.advanceHours(approachHours);
        _journey = InterruptedJourney(
          origin: origin,
          destination: _selected,
          elapsedHours: elapsed,
        );
        _commit();
        return true;
      }
      _clock.advanceHours(step.hours);
      elapsed += step.hours;
      _current = step.to;
    }
    _recordArrival(elapsed);
    return false;
  }

  void resolveFlood(FloodChoice? choice) {
    final journey = _journey;
    if (journey == null || choice == null) return;
    _clock.advanceHours(
      journey.totalHours - journey.elapsedHours + choice.extraHours,
    );
    _current = journey.destination;
    _selected = _current;
    _journey = null;
    _floodResolved = true;
    cultivation.gainInsight(choice.daoNiem);
    _recordArrival(journey.totalHours + choice.extraHours, choice);
  }

  void _recordArrival(int hours, [FloodChoice? choice]) {
    _journal.add((
      kind: JournalKind.travel,
      place: _current,
      hours: hours,
      day: day,
      hour: hour,
      floodChoice: choice,
    ));
    _commit();
  }
}

typedef JournalEntry = ({
  JournalKind kind,
  WorldPlace place,
  int hours,
  int day,
  int hour,
  FloodChoice? floodChoice,
});
