import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../world_region.dart';

class RegionalRoads extends StatefulWidget {
  const RegionalRoads({super.key});

  @override
  State<RegionalRoads> createState() => _RegionalRoadsState();
}

class _RegionalRoadsState extends State<RegionalRoads> {
  static const _roadAsset = 'assets/images/map/roads/road_straight.png';
  static const _surfaceKey = 'roadSurface';
  late final Future<Map<String, ui.Image>> _loading = _loadImages();
  final _images = <String, ui.Image>{};

  Future<Map<String, ui.Image>> _loadImages() async {
    final images = <String, ui.Image>{};
    try {
      for (final asset in {
        _roadAsset,
        ...regionalBridges.map((bridge) => bridge.asset),
      }) {
        final data = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        try {
          images[asset] = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
      }
      final road = images[_roadAsset]!;
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        road,
        Rect.fromLTWH(road.width * .4, 48, road.width * .2, road.height - 96.0),
        const Rect.fromLTWH(0, 0, 24, 96),
        Paint()..filterQuality = FilterQuality.medium,
      );
      final picture = recorder.endRecording();
      try {
        images[_surfaceKey] = await picture.toImage(24, 96);
      } finally {
        picture.dispose();
      }
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
    if (mounted) {
      _images.addAll(images);
    } else {
      for (final image in images.values) {
        image.dispose();
      }
      return const {};
    }
    return images;
  }

  @override
  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, ui.Image>>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorWidget(snapshot.error!);
        final images = snapshot.data;
        if (images == null || images.isEmpty) return const SizedBox.shrink();
        return RepaintBoundary(
          child: CustomPaint(
            painter: RegionalRoadPainter(images, images[_surfaceKey]!),
          ),
        );
      },
    );
  }
}

class RegionalRoadPainter extends CustomPainter {
  const RegionalRoadPainter(this.images, this.surface);

  final Map<String, ui.Image> images;
  final ui.Image surface;

  @override
  void paint(Canvas canvas, Size size) {
    const reference = Size(1672, 941);
    final roads = Path();
    for (final trail in regionalTrails) {
      final points = [
        trail.from.position,
        ...trail.waypoints,
        trail.to.position,
      ];
      roads.moveTo(
        points.first.dx * reference.width,
        points.first.dy * reference.height,
      );
      for (final point in points.skip(1)) {
        roads.lineTo(point.dx * reference.width, point.dy * reference.height);
      }
    }
    var land = Path()..addRect(Offset.zero & reference);
    for (final bridge in regionalBridges) {
      final image = images[bridge.asset]!;
      final width = bridge.length * image.width / image.height;
      final cosine = math.cos(bridge.rotation);
      final sine = math.sin(bridge.rotation);
      final center = Offset(
        bridge.position.dx * reference.width,
        bridge.position.dy * reference.height,
      );
      final local = Rect.fromLTRB(
        -width / 2,
        bridge.length * (bridge.deckStart - .5),
        width / 2,
        bridge.length * (bridge.deckEnd - .5),
      );
      final deck = Path()
        ..addPolygon([
          for (final point in [
            local.topLeft,
            local.topRight,
            local.bottomRight,
            local.bottomLeft,
          ])
            center +
                Offset(
                  cosine * point.dx - sine * point.dy,
                  sine * point.dx + cosine * point.dy,
                ),
        ], true);
      land = Path.combine(PathOperation.difference, land, deck);
    }
    final roadPaint = Paint()
      ..shader = ui.ImageShader(
        surface,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList([
          .15,
          0,
          0,
          0,
          0,
          .15,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
        ]),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..filterQuality = FilterQuality.medium;
    canvas.save();
    canvas.scale(size.width / reference.width, size.height / reference.height);
    canvas.save();
    canvas.clipPath(land);
    canvas.drawPath(roads, roadPaint);
    canvas.restore();
    final brush = Paint()..filterQuality = FilterQuality.medium;
    for (final bridge in regionalBridges) {
      final image = images[bridge.asset]!;
      final width = bridge.length * image.width / image.height;
      canvas.save();
      canvas.translate(
        bridge.position.dx * reference.width,
        bridge.position.dy * reference.height,
      );
      canvas.rotate(bridge.rotation);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCenter(
          center: Offset.zero,
          width: width,
          height: bridge.length,
        ),
        brush,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RegionalRoadPainter oldDelegate) =>
      oldDelegate.images != images || oldDelegate.surface != surface;
}
