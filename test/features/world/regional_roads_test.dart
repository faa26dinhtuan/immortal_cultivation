import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/world/widgets/regional_roads.dart';
import '../../../lib/features/world/world_region.dart';

Future<ui.Image> image(int width, int height, Color color) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(color, BlendMode.src);
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(width, height);
  } finally {
    picture.dispose();
  }
}

int alphaAt(ByteData pixels, int width, Offset point) =>
    pixels.getUint8((point.dy.round() * width + point.dx.round()) * 4 + 3);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'roads stop under both bridge decks, including rotated and scaled',
    () async {
      final surface = await image(24, 96, const Color(0x80956a38));
      final wood = await image(119, 347, const Color(0x00000000));
      final stone = await image(120, 350, const Color(0x00000000));
      addTearDown(surface.dispose);
      addTearDown(wood.dispose);
      addTearDown(stone.dispose);
      final painter = RegionalRoadPainter({
        regionalBridges[0].asset: wood,
        regionalBridges[1].asset: stone,
      }, surface);
      for (final scale in [1.0, .5]) {
        final width = (1672 * scale).round();
        final height = (941 * scale).round();
        final recorder = ui.PictureRecorder();
        painter.paint(
          Canvas(recorder),
          Size(width.toDouble(), height.toDouble()),
        );
        final picture = recorder.endRecording();
        final rendered = await picture.toImage(width, height);
        picture.dispose();
        final pixels = (await rendered.toByteData())!;
        for (final bridge in regionalBridges) {
          final center = Offset(
            bridge.position.dx * width,
            bridge.position.dy * height,
          );
          expect(alphaAt(pixels, width, center), 0);
        }
        final approach = Offset(.213 * width, .566 * height);
        expect(alphaAt(pixels, width, approach), greaterThan(0));
        final joint = Offset(
          WorldPlace.landing.position.dx * width,
          WorldPlace.landing.position.dy * height,
        );
        expect(alphaAt(pixels, width, joint), lessThanOrEqualTo(130));
        expect(alphaAt(pixels, width, joint), greaterThan(0));
        rendered.dispose();
      }
    },
  );
}
