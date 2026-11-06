import 'dart:math' as math;
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
            painter: _RoadPainter(images, images[_roadAsset]!),
          ),
        );
      },
    );
  }
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter(this.images, this.road);

  final Map<String, ui.Image> images;
  final ui.Image road;

  @override
  void paint(Canvas canvas, Size size) {
    const reference = Size(1672, 941);
    final brush = Paint()..filterQuality = FilterQuality.medium;
    canvas.save();
    canvas.scale(size.width / reference.width, size.height / reference.height);
    for (final trail in regionalTrails) {
      final points = [
        trail.from.position,
        ...trail.waypoints,
        trail.to.position,
      ];
      final path = Path()
        ..moveTo(
          points.first.dx * reference.width,
          points.first.dy * reference.height,
        );
      for (final point in points.skip(1)) {
        path.lineTo(point.dx * reference.width, point.dy * reference.height);
      }
      for (final metric in path.computeMetrics()) {
        for (var distance = 0.0; distance < metric.length; distance += 3) {
          final tangent = metric.getTangentForOffset(distance)!;
          final sourceY = 24 + (distance * 2) % (road.height - 72);
          canvas.save();
          canvas.translate(tangent.position.dx, tangent.position.dy);
          canvas.rotate(tangent.angle - math.pi / 2);
          canvas.drawImageRect(
            road,
            Rect.fromLTWH(0, sourceY, road.width.toDouble(), 24),
            const Rect.fromLTWH(-3.75, -3, 7.5, 6),
            brush,
          );
          canvas.restore();
        }
      }
    }
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
  bool shouldRepaint(_RoadPainter oldDelegate) => oldDelegate.images != images;
}
