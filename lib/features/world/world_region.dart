import 'package:flutter/painting.dart';

enum WorldPlace {
  cave(Offset(.21, .55)),
  landing(Offset(.47, .73)),
  pass(Offset(.77, .40));

  const WorldPlace(this.position);

  final Offset position;
}

class WorldTrail {
  const WorldTrail(this.from, this.to, this.hours, this.waypoints);

  final WorldPlace from;
  final WorldPlace to;
  final int hours;
  final List<Offset> waypoints;
}

const regionalTrails = [
  WorldTrail(WorldPlace.cave, WorldPlace.landing, 2, [
    Offset(.23, .60),
    Offset(.31, .61),
    Offset(.40, .68),
  ]),
  WorldTrail(WorldPlace.landing, WorldPlace.pass, 4, [
    Offset(.52, .73),
    Offset(.55, .69),
    Offset(.63, .62),
    Offset(.70, .51),
  ]),
];
