import 'package:flutter/painting.dart';

enum WorldPlace {
  cave(Offset(.21, .55)),
  landing(Offset(.47, .73)),
  pass(Offset(.77, .40));

  const WorldPlace(this.position);

  final Offset position;
}

enum TrailTerrain { riverCrossing, mountainPath }

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
    TrailTerrain.riverCrossing,
    [
      Offset(.213, .566),
      Offset(.223, .587),
      Offset(.236, .607),
      Offset(.265, .625),
      Offset(.285, .652),
      Offset(.325, .690),
      Offset(.360, .713),
      Offset(.400, .740),
      Offset(.440, .751),
      Offset(.457, .742),
    ],
    crossingPosition: Offset(.223, .587),
  ),
  WorldTrail(
    WorldPlace.landing,
    WorldPlace.pass,
    4,
    TrailTerrain.mountainPath,
    [
      Offset(.495, .741),
      Offset(.520, .745),
      Offset(.520, .717),
      Offset(.520, .690),
      Offset(.548, .676),
      Offset(.565, .666),
      Offset(.582, .645),
      Offset(.595, .626),
      Offset(.602, .595),
      Offset(.620, .580),
      Offset(.650, .557),
      Offset(.677, .535),
      Offset(.681, .507),
      Offset(.675, .492),
      Offset(.692, .477),
      Offset(.719, .468),
      Offset(.737, .451),
      Offset(.744, .430),
      Offset(.760, .416),
    ],
  ),
];

class RoadBridge {
  const RoadBridge({
    required this.position,
    required this.asset,
    required this.rotation,
    required this.length,
  });

  final Offset position;
  final String asset;
  final double rotation;
  final double length;
}

const regionalBridges = [
  RoadBridge(
    position: Offset(.223, .587),
    asset: 'assets/images/map/roads/bridge_wood.png',
    rotation: -.8,
    length: 38,
  ),
  RoadBridge(
    position: Offset(.520, .717),
    asset: 'assets/images/map/roads/bridge_stone.png',
    rotation: 0,
    length: 44,
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
