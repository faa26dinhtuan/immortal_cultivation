import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../world_region.dart';

class RegionalMap extends StatelessWidget {
  const RegionalMap({
    required this.current,
    required this.selected,
    required this.route,
    required this.onSelect,
    super.key,
  });

  final WorldPlace current;
  final WorldPlace selected;
  final List<WorldTrail> route;
  final ValueChanged<WorldPlace> onSelect;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1672 / 941,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/map/regional_map.png',
              fit: BoxFit.contain,
              semanticLabel: GameStrings.mapDescription,
            ),
            IgnorePointer(child: CustomPaint(painter: _RoutePainter(route))),
            for (final place in WorldPlace.values)
              Positioned(
                left: place.position.dx * constraints.maxWidth - GameTheme.pinSize / 2,
                top: place.position.dy * constraints.maxHeight - GameTheme.pinSize / 2,
                child: _PlacePin(
                  place: place,
                  current: current == place,
                  selected: selected == place,
                  onPressed: () => onSelect(place),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlacePin extends StatelessWidget {
  const _PlacePin({
    required this.place,
    required this.current,
    required this.selected,
    required this.onPressed,
  });

  final WorldPlace place;
  final bool current;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = current
        ? GameStrings.currentPlace(place)
        : GameStrings.placeName(place);
    return Semantics(
      selected: selected,
      child: SizedBox.square(
        dimension: GameTheme.pinSize,
        child: IconButton(
          tooltip: label,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          iconSize: GameTheme.pinIconSize,
          color: GameTheme.cream,
          icon: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? GameTheme.clay : GameTheme.pine,
              border: Border.all(
                color: GameTheme.cream,
                width: current ? 2 : 1,
              ),
            ),
            child: SizedBox.square(
              dimension: GameTheme.pinBadgeSize,
              child: Center(
                child: Image.asset(
                  switch (place) {
                    WorldPlace.cave => 'assets/icons/map_pins/cave.png',
                    WorldPlace.landing => 'assets/icons/map_pins/river_landing.png',
                    WorldPlace.pass => 'assets/icons/map_pins/mountain_pass.png',
                  },
                  width: GameTheme.pinIconSize,
                  height: GameTheme.pinIconSize,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter(this.trails);

  final List<WorldTrail> trails;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = Paint()
      ..color = GameTheme.cream
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final trail in trails) {
      final path = Path()..moveTo(
        trail.from.position.dx * size.width,
        trail.from.position.dy * size.height,
      );
      for (final point in [...trail.waypoints, trail.to.position]) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      for (final segment in path.computeMetrics()) {
        for (var offset = 0.0; offset < segment.length; offset += 10) {
          canvas.drawPath(segment.extractPath(offset, offset + 5), brush);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => oldDelegate.trails != trails;
}
