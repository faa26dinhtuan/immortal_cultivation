import 'package:flutter/painting.dart';

enum WorldPlace {
  cave(Offset(400 / 2400, 600 / 1400)),
  landing(Offset(1295 / 2400, 885 / 1400)),
  pass(Offset(2200 / 2400, 200 / 1400));

  const WorldPlace(this.position);

  final Offset position;
}

enum TrailTerrain { riverCrossing, mountainPath, lowlandPath }

class WorldTrail {
  const WorldTrail(
    this.from,
    this.to,
    this.hours,
    this.terrain,
    this.waypoints, {
    this.crossingPosition,
  });

  final WorldPlace from;
  final WorldPlace to;
  final int hours;
  final TrailTerrain terrain;
  final List<Offset> waypoints;
  final Offset? crossingPosition;

  Offset get eventPosition =>
      crossingPosition ?? waypoints[waypoints.length ~/ 2];

  WorldTrail reversed() => WorldTrail(
    to,
    from,
    hours,
    terrain,
    waypoints.reversed.toList(growable: false),
    crossingPosition: crossingPosition,
  );
}

const regionalTrails = [
  WorldTrail(
    WorldPlace.cave,
    WorldPlace.landing,
    2,
    TrailTerrain.lowlandPath,
    [
      Offset(358.56 / 2400, 619.68 / 1400),
      Offset(338 / 2400, 646 / 1400),
      Offset(350 / 2400, 696 / 1400),
      Offset(440 / 2400, 830 / 1400),
      Offset(600 / 2400, 1050 / 1400),
      Offset(700 / 2400, 1200 / 1400),
      Offset(1000 / 2400, 1100 / 1400),
      Offset(1200 / 2400, 1150 / 1400),
      Offset(1250 / 2400, 1000 / 1400),
      Offset(1265.96 / 2400, 901.66 / 1400),
    ],
  ),
  WorldTrail(
    WorldPlace.landing,
    WorldPlace.pass,
    4,
    TrailTerrain.riverCrossing,
    [
      Offset(1265.96 / 2400, 901.66 / 1400),
      Offset(1250 / 2400, 1000 / 1400),
      Offset(1200 / 2400, 1150 / 1400),
      Offset(1390 / 2400, 1050 / 1400),
      Offset(1418 / 2400, 1050 / 1400),
      Offset(1492 / 2400, 1050 / 1400),
      Offset(1520 / 2400, 1050 / 1400),
      Offset(1650 / 2400, 1000 / 1400),
      Offset(1750 / 2400, 850 / 1400),
      Offset(1900 / 2400, 700 / 1400),
      Offset(2000 / 2400, 500 / 1400),
      Offset(2096.575 / 2400, 350.15 / 1400),
    ],
    crossingPosition: Offset(1455 / 2400, 1050 / 1400),
  ),
];

class RoadBridge {
  const RoadBridge({
    required this.position,
    required this.asset,
    required this.rotation,
    required this.length,
    required this.deckStart,
    required this.deckEnd,
  });

  final Offset position;
  final String asset;
  final double rotation;
  final double length;
  final double deckStart;
  final double deckEnd;
}

const regionalBridges = [
  RoadBridge(
    position: Offset(.223, .587),
    asset: 'assets/images/map/roads/bridge_wood.png',
    rotation: -.8,
    length: 38,
    deckStart: 91 / 347,
    deckEnd: 259 / 347,
  ),
  RoadBridge(
    position: Offset(.520, .717),
    asset: 'assets/images/map/roads/bridge_stone.png',
    rotation: 0,
    length: 44,
    deckStart: 94 / 350,
    deckEnd: 260 / 350,
  ),
];

List<WorldTrail> regionalRoute(WorldPlace from, WorldPlace to) {
  final routes = <WorldPlace, List<WorldTrail>>{from: []};
  final pending = <WorldPlace>[from];
  for (var index = 0; index < pending.length; index++) {
    final place = pending[index];
    if (place == to) return List.unmodifiable(routes[place]!);
    for (final trail in regionalTrails) {
      final WorldTrail step;
      if (trail.from == place) {
        step = trail;
      } else if (trail.to == place) {
        step = trail.reversed();
      } else {
        continue;
      }
      if (routes.containsKey(step.to)) continue;
      routes[step.to] = [...routes[place]!, step];
      pending.add(step.to);
    }
  }
  return const [];
}

class InterruptedJourney {
  const InterruptedJourney({
    required this.origin,
    required this.destination,
    required this.elapsedHours,
  });

  final WorldPlace origin;
  final WorldPlace destination;
  final int elapsedHours;

  List<WorldTrail> get route => regionalRoute(origin, destination);
  int get totalHours => route.fold(0, (sum, trail) => sum + trail.hours);

  Map<String, Object> toJson() => {
    'origin': origin.name,
    'destination': destination.name,
    'elapsedHours': elapsedHours,
  };

  static InterruptedJourney? fromJson(dynamic value) {
    if (value == null) return null;
    final data = value as Map<String, dynamic>;
    return InterruptedJourney(
      origin: WorldPlace.values.byName(data['origin'] as String),
      destination: WorldPlace.values.byName(data['destination'] as String),
      elapsedHours: data['elapsedHours'] as int,
    );
  }
}
