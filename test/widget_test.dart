import 'package:flutter_test/flutter_test.dart';
import 'package:immortal_cultivation/main.dart';

void main() {
  testWidgets('Travel updates the current place and clock', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Ngày 1 · 06:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Bến Hợp Lưu'));
    await tester.pump();
    await tester.tap(find.text('Di chuyển · 2 giờ'));
    await tester.pump();

    expect(find.text('Ngày 1 · 08:00'), findsOneWidget);
    expect(find.text('Đang ở Bến Hợp Lưu'), findsOneWidget);
    expect(find.text('Đã đến Bến Hợp Lưu sau 2 giờ.'), findsNothing);

    await tester.tap(find.text('Nhật ký'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đến Bến Hợp Lưu sau 2 giờ.'), findsOneWidget);
  });
}
