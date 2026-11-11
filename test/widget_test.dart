import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immortal_cultivation/features/world/controllers/world_controller.dart';
import 'package:immortal_cultivation/features/world/screens/world_screen.dart';

void main() {
  testWidgets('Flood choice changes travel time and is recorded in the journal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = WorldController(random: _FloodRandom());
    await tester.pumpWidget(MaterialApp(home: WorldScreen(controller: controller)));
    addTearDown(controller.dispose);

    expect(find.text('Ngày 1 · 06:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Đèo Vân Nham'));
    await tester.pump();
    await tester.tap(find.text('Di chuyển · 6 giờ'));
    await tester.pumpAndSettle();

    expect(find.text('Nước dâng ven đường'), findsOneWidget);
    expect(find.text('Ngày 1 · 10:00'), findsOneWidget);
    await tester.tap(find.textContaining('Chờ nước rút'));
    await tester.pumpAndSettle();

    expect(find.text('Ngày 1 · 14:00'), findsOneWidget);
    expect(find.text('Đang ở Đèo Vân Nham'), findsOneWidget);
    expect(find.text('Đã đến Đèo Vân Nham sau 8 giờ.'), findsNothing);

    await tester.tap(find.text('Nhật ký'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đến Đèo Vân Nham sau 8 giờ.'), findsOneWidget);
    expect(find.textContaining('Nhận Đạo Niệm Nhẫn Nại'), findsOneWidget);
  });
}

class _FloodRandom implements Random {
  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => throw UnsupportedError('nextBool');

  @override
  int nextInt(int max) => throw UnsupportedError('nextInt');
}
