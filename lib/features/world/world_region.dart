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
    this.waypoints,
  );

  final WorldPlace from;
  final WorldPlace to;
  final int hours;
  final TrailTerrain terrain;
  final List<Offset> waypoints;

  WorldTrail reversed() => WorldTrail(
    to,
    from,
    hours,
    terrain,
    waypoints.reversed.toList(growable: false),
  );
}

const regionalTrails = [
  WorldTrail(
    WorldPlace.cave,
    WorldPlace.landing,
    2,
    TrailTerrain.riverCrossing,
    [Offset(.23, .60), Offset(.31, .61), Offset(.40, .68)],
  ),
  WorldTrail(
    WorldPlace.landing,
    WorldPlace.pass,
    4,
    TrailTerrain.mountainPath,
    [Offset(.52, .73), Offset(.55, .69), Offset(.63, .62), Offset(.70, .51)],
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
