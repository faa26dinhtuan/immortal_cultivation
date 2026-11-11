import 'package:flutter/foundation.dart' show kIsWeb;
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
    this.interruptedTrail,
    super.key,
  });

  final WorldPlace current;
  final WorldTrail? interruptedTrail;
  final WorldPlace selected;
  final List<WorldTrail> route;
  final ValueChanged<WorldPlace> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        return _MapViewport(
          key: ValueKey(viewport),
          viewport: viewport,
          map: this,
        );
      },
    );
  }
}

class _MapViewport extends StatefulWidget {
  const _MapViewport({required this.viewport, required this.map, super.key});

  final Size viewport;
  final RegionalMap map;

  @override
  State<_MapViewport> createState() => _MapViewportState();
}

class _MapViewportState extends State<_MapViewport> {
  static const _aspectRatio = 2400 / 1400;
  static const _maxScale = 3.0;
  static const _zoomStep = 1.35;

  late final Size _scene;
  late final TransformationController _transform;

  @override
  void initState() {
    super.initState();
    final viewport = widget.viewport;
    _scene = viewport.width / viewport.height > _aspectRatio
        ? Size(viewport.width, viewport.width / _aspectRatio)
        : Size(viewport.height * _aspectRatio, viewport.height);
    final interrupted = widget.map.interruptedTrail;
    final position = interrupted == null
        ? widget.map.current.position
        : interrupted.eventPosition;
    _transform = TransformationController(
      _matrix(
        1,
        Offset(position.dx * _scene.width, position.dy * _scene.height),
      ),
    );
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Matrix4 _matrix(double scale, Offset focalPoint) {
    final viewport = widget.viewport;
    final x = (viewport.width / 2 - focalPoint.dx * scale)
        .clamp(
          (viewport.width - _scene.width * scale).clamp(
            double.negativeInfinity,
            0.0,
          ),
          0.0,
        )
        .toDouble();
    final y = (viewport.height / 2 - focalPoint.dy * scale)
        .clamp(
          (viewport.height - _scene.height * scale).clamp(
            double.negativeInfinity,
            0.0,
          ),
          0.0,
        )
        .toDouble();
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setEntry(0, 3, x)
      ..setEntry(1, 3, y);
  }

  void _zoom(double multiplier) {
    final currentScale = _transform.value.getMaxScaleOnAxis();
    final scale = (currentScale * multiplier).clamp(1.0, _maxScale).toDouble();
    final center = widget.viewport.center(Offset.zero);
    _transform.value = _matrix(scale, _transform.toScene(center));
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.map;
    final showZoomControls = switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => false,
      _ => true,
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          alignment: Alignment.topLeft,
          minScale: 1,
          maxScale: _maxScale,
          child: SizedBox(
            width: _scene.width,
            height: _scene.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/map/regional_map.png',
                  fit: BoxFit.cover,
                  semanticLabel: GameStrings.mapDescription,
                ),
                IgnorePointer(
                  child: CustomPaint(painter: _RoutePainter(map.route)),
                ),
                if (map.interruptedTrail case final trail?)
                  Positioned(
                    left: trail.eventPosition.dx * _scene.width - 24,
                    top: trail.eventPosition.dy * _scene.height - 24,
                    child: ValueListenableBuilder<Matrix4>(
                      valueListenable: _transform,
                      builder: (context, matrix, child) => Transform.scale(
                        scale: 1 / matrix.getMaxScaleOnAxis(),
                        child: child,
                      ),
                      child: Tooltip(
                        message: GameStrings.journeyInterrupted,
                        child: SizedBox.square(
                          dimension: 48,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/character/character.png',
                              width: 32,
                              height: 32,
                              semanticLabel: GameStrings.journeyInterrupted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                for (final place in WorldPlace.values)
                  Positioned(
                    left:
                        place.position.dx * _scene.width -
                        GameTheme.pinSize / 2,
                    top:
                        place.position.dy * _scene.height -
                        GameTheme.pinSize / 2,
                    child: ValueListenableBuilder<Matrix4>(
                      valueListenable: _transform,
                      builder: (context, matrix, child) => Transform.scale(
                        scale: 1 / matrix.getMaxScaleOnAxis(),
                        child: child,
                      ),
                      child: _PlacePin(
                        place: place,
                        current:
                            map.interruptedTrail == null &&
                            map.current == place,
                        selected: map.selected == place,
                        onPressed: () => map.onSelect(place),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!kIsWeb && showZoomControls)
          Align(
            alignment: Alignment.centerRight,
            child: SafeArea(
              minimum: const EdgeInsets.all(12),
              child: Material(
                color: GameTheme.paper,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _transform,
                  builder: (context, matrix, child) {
                    final scale = matrix.getMaxScaleOnAxis();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: GameStrings.zoomIn,
                          onPressed: scale < _maxScale - .001
                              ? () => _zoom(_zoomStep)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          tooltip: GameStrings.zoomOut,
                          onPressed: scale > 1.001
                              ? () => _zoom(1 / _zoomStep)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
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
                    WorldPlace.landing =>
                      'assets/icons/map_pins/river_landing.png',
                    WorldPlace.pass =>
                      'assets/icons/map_pins/mountain_pass.png',
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
      final path = Path()
        ..moveTo(
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
