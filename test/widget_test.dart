import 'package:flutter_test/flutter_test.dart';
import 'package:immortal_cultivation/main.dart';

void main() {
  testWidgets('Flood choice changes travel time and is recorded in the journal', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Ngày 1 · 06:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Bến Hợp Lưu'));
    await tester.pump();
    await tester.tap(find.text('Di chuyển · 2 giờ'));
    await tester.pumpAndSettle();

    expect(find.text('Nước dâng ven đường'), findsOneWidget);
    expect(find.text('Ngày 1 · 06:00'), findsOneWidget);
    await tester.tap(find.textContaining('Chờ nước rút'));
    await tester.pumpAndSettle();

    expect(find.text('Ngày 1 · 10:00'), findsOneWidget);
    expect(find.text('Đang ở Bến Hợp Lưu'), findsOneWidget);
    expect(find.text('Đã đến Bến Hợp Lưu sau 4 giờ.'), findsNothing);

    await tester.tap(find.text('Nhật ký'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đến Bến Hợp Lưu sau 4 giờ.'), findsOneWidget);
    expect(find.textContaining('Nhận Đạo Niệm Nhẫn Nại'), findsOneWidget);
  });
}
