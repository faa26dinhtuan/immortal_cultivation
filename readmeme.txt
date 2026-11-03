Workflow & Quy tắc lập trình Flutter (iOS Focus)

1. Tiếp tục từ dự án hiện có:
   - Trước khi làm, kiểm tra cấu trúc và tính năng đã có để hiểu trạng thái app. Nếu app hoặc phần được yêu cầu đã có sẵn, bỏ qua bước tạo mới; chỉ làm phần còn thiếu hoặc cần sửa.
   - Làm từng tính năng trong phạm vi yêu cầu. Chọn cách triển khai phù hợp với app iOS và cách dùng thực tế. Chủ động xử lý chi tiết hợp lý giúp tính năng hoàn chỉnh, tránh code thừa.
   - Không sửa trực tiếp tệp dự án. Tạo các tệp thay thế trong thư mục tạm và đóng gói ZIP với đúng đường dẫn tương đối để giải nén trực tiếp vào thư mục gốc.

2. Tiêu chuẩn giao diện & Thẩm mỹ chuẩn iOS (Modern iOS Aesthetic & "Tẩy xám" UI):
   - Phong cách chủ đạo: Clean, Modern, Apple Human Interface Guidelines, kết hợp hiệu ứng kính mờ (Cupertino Glassmorphism / BackdropFilter) khi cần thiết.
   - Bề mặt Card & Container:
     + Bo góc lớn & mượt mà: BorderRadius.circular(16) đến 24 (dùng ClipRRect khi chứa hình ảnh).
     + Đổ bóng tinh tế (Soft BoxShadow): Tuyệt đối không dùng bóng đen mặc định thô ráp. Dùng color: Colors.black.withOpacity(0.04 - 0.06), blurRadius: 16 - 24, offset: const Offset(0, 8 - 10).
     + Viền siêu mảnh (Subtle Border): Border.all(color: Colors.black.withOpacity(0.05), width: 1) để tách bạch nền.
   - Màu sắc & Tránh Pure Colors:
     + Tuyệt đối không dùng màu nguyên bản (Colors.blue, Colors.red, Colors.green). Sử dụng bảng màu hiện đại, pastel hoặc hex tone hài hòa định nghĩa trong core/theme/app_colors.dart.
     + Mọi màu sắc và độ mờ phải gọi qua AppColors; không hardcode mã hex trực tiếp rải rác trong widget con.
   - Typography & Font chữ:
     + Không dùng font mặc định đơn điệu. Sử dụng font hiện đại (Inter, Poppins, SF Pro, Plus Jakarta Sans) thông qua core/theme/app_text_styles.dart hoặc google_fonts.
     + Phân cấp rõ ràng: Title (SemiBold/Bold w600/w700), Subtitle (Medium w500, màu trung tính), Body (Regular w400).
   - Khoảng cách (Spacing) & Bố cục:
     + Tuân thủ hệ số 8 (8, 16, 24, 32). Spacing nội bộ dùng 12 hoặc 16.
     + Sử dụng CustomScrollView kết hợp SliverAppBar (hiệu ứng co giãn/thu nhỏ khi cuộn chuẩn iOS) cho các màn hình dài hoặc màn hình chi tiết/profile.
   - Tương tác vi mô & Cảm giác chạm (Micro-interactions & Haptic Touch):
     + Phản hồi rung xúc giác (Haptic Feedback): Bắt buộc tích hợp rung nhẹ của iPhone khi người dùng chạm vào các nút quan trọng (CTA), chuyển tab, kéo thả refresh, hoặc toggle switch thông qua `HapticFeedback.lightImpact()` hoặc `HapticFeedback.selectionClick()`.
     + Hiệu ứng chuyển trang (Page Transitions): Khuyến khích dùng hiệu ứng Container Transform hoặc CupertinoPageRoute mượt mà của iOS thay vì chuyển trang giật cục.
     + Hiệu ứng xuất hiện: Thêm animation xuất hiện tinh tế bằng flutter_animate (ví dụ: .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0)).
     + Touch feedback: Ưu tiên hiệu ứng nảy/chạm nhẹ của iOS (Cupertino scale/opacity), tránh hiệu ứng gợn sóng (Ripple) quá đậm của Material trên iOS.

3. Danh mục thư viện chuẩn thường dùng (Standard Dependencies Stack):
   Ưu tiên sử dụng bộ thư viện chuẩn sau (tránh cài thư viện lạ/kém bảo trì):
   - Quản lý trạng thái (State Management): flutter_riverpod (hoặc flutter_bloc / provider tuỳ dự án).
   - Lưu trữ dữ liệu cục bộ (Local Storage): shared_preferences (lưu cài đặt đơn giản, flag), flutter_secure_storage (lưu token/mật khẩu an toàn Keychain iOS), hive / isar / sqflite (lưu database offline nếu cần).
   - Gọi mạng & API (Networking): dio (kèm Interceptor cho auth/token/refresh, timeout, log), http.
   - Typography & Icon: google_fonts (font chữ hiện đại), cupertino_icons (icon chuẩn Apple), flutter_svg (render vector icon SVG).
   - Hình ảnh (Images): cached_network_image (load ảnh mạng mượt có cache & shimmer/placeholder).
   - Animation, Micro-interactions & UX:
     + flutter_animate (animation mượt mà nhẹ nhàng).
     + shimmer (hiệu ứng quét sáng khung xám khi tải dữ liệu từ API).
     + animations (hiệu ứng Container Transform mở rộng card mượt mà từ Flutter team).
     + pull_to_refresh_flutter3 hoặc CupertinoSliverRefreshControl (kéo thả làm mới chuẩn iOS).
   - Đa ngôn ngữ & Format (i18n/l10n): flutter_localizations, intl (định dạng ngày tháng, tiền tệ, số).
   - Điều hướng (Navigation): go_router (declarative routing, deep linking).

4. Từ điển UI Elements chuẩn Mobbin & Tình huống sử dụng (UI Component Dictionary):
   Khi người dùng hỏi "Nên dùng UI gì ở đây?", hãy đối chiếu và đề xuất/triển khai component phù hợp nhất từ từ điển này:

   [Nhóm Control - Điều khiển & Nhập liệu]
   - Accordion (ExpansionTile): Khối nội dung bấm mở ra / gập lại (FAQ, chi tiết điều khoản).
   - Button (CupertinoButton / FilledButton): Nút bấm chính/phụ thực hiện hành động (kèm HapticFeedback.lightImpact).
   - Checkbox (CupertinoCheckbox): Chọn 1 hoặc nhiều lựa chọn độc lập (đồng ý điều khoản, chọn item giỏ hàng).
   - Color Picker: Bộ bảng chọn màu sắc (tùy chỉnh theme, chọn màu sản phẩm).
   - Date Picker (CupertinoDatePicker): Cuộn/chọn ngày tháng năm (chọn ngày sinh, ngày đặt vé).
   - Floating Action Button (FAB / Sticky CTA): Nút bấm nổi bật cố định góc dưới hoặc thanh dưới cùng (tạo mới bài viết, đặt đơn).
   - Radio Button (CupertinoRadio): Chọn duy nhất 1 lựa chọn trong danh sách loại trừ nhau (phương thức thanh toán).
   - Rating Control (Star rating): Thanh đánh giá số sao (đánh giá sao sản phẩm, tài xế).
   - Search Bar (CupertinoSearchTextField): Thanh tìm kiếm bo tròn chuẩn iOS kèm icon kính lúp và nút xóa nhanh.
   - Segmented Control (CupertinoSegmentedControl / SlidingSegmentedControl): Thanh tab viên thuốc trượt chọn 2-4 chế độ (ví dụ: Đang giao / Lịch sử, Ngày / Tuần / Tháng).
   - Slider (CupertinoSlider): Thanh kéo trượt chọn mức giá trị liên tục (âm lượng, khoảng giá).
   - Stepper (CupertinoStepper): Nút cộng/trừ tăng giảm số lượng (số lượng hàng trong giỏ, số phòng khách).
   - Switch (CupertinoSwitch): Cần gạt bật/tắt tức thì chuẩn iOS (bật thông báo, chế độ tối, FaceID) kèm HapticFeedback.selectionClick.
   - Tab / Tab Bar (TabBar): Chuyển đổi qua lại giữa các trang/luồng nội dung lớn.
   - Text Field (CupertinoTextField): Ô nhập văn bản/mật khẩu có bo góc và placeholder tinh tế.
   - Tile (CupertinoListTile): Dòng danh mục cài đặt gồm Icon bên trái, Tiêu đề ở giữa, Mũi tên chevron bên phải.
   - Time Picker (CupertinoTimerPicker): Bánh xe cuộn chọn giờ/phút.

   [Nhóm View - Trình bày & Bố cục dữ liệu]
   - Badge: Nhãn đếm số lượng nhỏ nổi ở góc icon chuông thông báo hoặc giỏ hàng.
   - Banner: Khối thông báo ngang nổi bật trên đầu màn hình (cảnh báo bảo trì, khuyến mãi gấp).
   - Card: Thẻ chứa thông tin bo góc mượt mà, đổ bóng mềm (card sản phẩm, card giao dịch).
   - Carousel (Carousel Slider / PageView): Khối trượt ngang các banner ảnh/sản phẩm có chấm chỉ số dot indicator.
   - Chip (Filter / Choice Chip): Nhãn hình viên thuốc nhỏ dùng để lọc nhanh danh mục (All, Áo thun, Quần jean,...).
   - Divider: Đường gạch kẻ mờ phân tách giữa các dòng/khối nội dung.
   - Gallery: Lưới hiển thị nhiều ảnh/video (Grid view album ảnh sản phẩm, bài đăng).
   - Loading Indicator (CupertinoActivityIndicator): Vòng xoay nan hoa quay tròn chuẩn Apple lúc tải dữ liệu.
   - Map Pin: Điểm ghim vị trí trên bản đồ (địa chỉ giao hàng, vị trí cửa hàng).
   - Progress Indicator: Thanh đo tiến độ phần trăm hoàn thành (tiến độ khóa học, % upload file).
   - Side Navigation (Drawer): Menu cạnh bên vuốt ra (ưu tiên dùng Bottom Bar hơn trên iOS, chỉ dùng Drawer khi app nhiều phân hệ).
   - Skeleton (Shimmer): Bộ khung xám phát sáng mô phỏng layout đang tải từ API (dùng package shimmer thay thế vòng xoay tròn).
   - Stacked List (ListView.separated): Danh sách các dòng được nhóm bo tròn thành khối (như trang Settings của iPhone).
   - Status Dot: Chấm tròn màu nhỏ báo trạng thái trực tuyến (Xanh lá: Online, Vàng: Chờ, Đỏ: Lỗi).
   - Table: Bảng chia cột/dòng để so sánh thông số kỹ thuật hoặc bảng giá chi tiết.
   - Toolbar: Thanh công cụ thao tác nhanh (thường nằm dưới cùng: sửa, xóa, chia sẻ).
   - Top Navigation Bar (CupertinoNavigationBar): Thanh tiêu đề trên cùng có nút Back, Title, và Action icons.

   [Nhóm Overlay - Lớp phủ & Thông báo tương tác]
   - Action Sheet (CupertinoActionSheet): Bảng hành động trượt từ đáy màn hình lên (Đổi avatar -> Chụp ảnh / Chọn thư viện / Hủy).
   - Bottom Sheet (DraggableScrollableSheet): Bảng trượt nửa dưới màn hình kéo lên xuống được (chọn voucher, chi tiết giỏ hàng).
   - Coach Marks: Vệt sáng highlight chỉ dẫn từng nút cho người dùng mới lần đầu mở app (Onboarding tour).
   - Dialog (CupertinoAlertDialog): Hộp thoại xác nhận giữa màn hình (Xác nhận xóa, Cảnh báo thoát).
   - Dropdown Menu: Menu nhỏ xổ xuống ngay tại vị trí bấm để chọn giá trị.
   - Full-Screen Overlay: Màn hình phủ toàn bộ đè lên (khi xem ảnh phóng to, màn hình khóa mã PIN).
   - Toast (SnackBar / Flash): Thông báo nhỏ tự biến mất sau 2-3s ở đáy hoặc đỉnh màn hình ("Đã lưu thành công").
   - Tooltip: Bong bóng nhỏ hiện giải thích khi ấn giữ hoặc chạm vào một nút lạ.

   [Nhóm Imagery - Hình ảnh & Nhận diện thương hiệu]
   - Avatar: Ảnh đại diện người dùng hình tròn bo góc, có viền hoặc badge online.
   - Icon: Biểu tượng đồ họa tối giản (CupertinoIcons hoặc SVG) bổ trợ thị giác cho chữ.
   - Illustration: Tranh vẽ minh họa sinh động (dùng cho Empty State, Onboarding, báo lỗi 404).
   - Photo: Ảnh chụp thực tế của sản phẩm, địa điểm, bài đăng (bắt buộc dùng kèm CachedNetworkImage).
   - Logo: Nhận diện thương hiệu ở màn hình Splash hoặc trên Top Navigation Bar.

5. Quy tắc code & kiến trúc:
   - Không viết comment trong code được tạo hoặc sửa (trừ khi có logic thuật toán đặc biệt phức tạp).
   - Mọi chữ hiển thị trên giao diện, kể cả nhãn, thông báo, tooltip và accessibility text, bắt buộc lấy từ lib/l10n/; tuyệt đối không hardcode text trực tiếp trong widget.
   - Giữ các thay đổi gọn, khớp cấu trúc hiện tại của app. Tách nhỏ các widget phức tạp thành các file riêng trong thư mục widgets/ của feature.
   - Clean Figma/Generated Code: Khi tích hợp code từ công cụ chuyển đổi (Figma-to-Code), bắt buộc chuẩn hóa lại cây widget: thay thế toàn bộ mã hex, khoảng cách, chuỗi text hardcode bằng token từ `core/theme/` và `lib/l10n/`.
   - Chỉ chạy kiểm tra hoặc build khi được yêu cầu, hoặc khi cần xác minh cụ thể một lỗi đang xử lý.

6. Khi hoàn tất, báo ngắn gọn bằng tiếng Việt:
   - Tệp ZIP và cách áp dụng.
   - Những thay đổi quan trọng cùng tác dụng.
   - Tính năng hoạt động thế nào: nêu ngắn gọn hàm, trạng thái hoặc luồng chính để dễ tiếp tục phát triển.
   - Kiểm tra nào đã chạy và kết quả; nói rõ nếu chưa kiểm tra.
   - Đưa một commit message ngắn theo chuẩn Conventional Commits, ví dụ: feat(profile): implement modern ios profile card.
Các phần workflow đã hoàn tất hoặc tính năng đã tồn tại trong dự án không cần làm lại; tập trung vào yêu cầu hiện tại.

==================================================
HƯỚNG DẪN PROMPT KÈM HÌNH ẢNH / FIGMA (DÀNH CHO USER KHI DÙNG VỚI AI):
1. Khi có ảnh chụp thiết kế (Dribbble / Pinterest / Mobbin / Figma):
   "Hãy phân tích layout và tone màu của bức ảnh này. Sau đó áp dụng đúng các tiêu chuẩn iOS và cấu trúc thư mục trong workflow của tôi để viết code Flutter dựng lại màn hình tương tự đạt 85-90% giao diện trong ảnh."

2. Khi copy code thô từ plugin Figma to Code:
   "Đây là code giao diện được export từ Figma. Hãy làm sạch (refactor) lại code này theo đúng workflow của tôi: đưa màu/spacing vào core/theme/, tách text sang lib/l10n/, và chia nhỏ widget theo đúng cấu trúc feature."
==================================================
