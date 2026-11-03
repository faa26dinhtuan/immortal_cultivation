# Immortal cultivation

## Phạm vi
- Game tu tiên offline bằng Flutter, ưu tiên Android và dùng Chrome để chạy thử. Giao diện gọn, dễ chạm theo tinh thần iOS.
- Trao đổi bằng tiếng Việt. Làm từng phần theo yêu cầu. Kiểm tra cấu trúc và tính năng hiện có trước khi triển khai.
- Hướng chơi hiện tại: bế quan tăng tu vi, sự kiện và lựa chọn tạo Đạo Niệm, Đạo Niệm định hướng đột phá. Bản đồ thế giới rộng, chọn địa điểm để di chuyển và hành trình tiêu tốn thời gian.

## Thư mục và bàn giao
- Project thật: D:/Code/Antigravity/Projects/immortal_cultivation. Xác nhận thư mục làm việc trước khi tạo đầu ra. Nếu thiếu quyền ghi vào ổ D, xin quyền trước.
- Bắt buộc đọc toàn bộ readmeme.txt tại gốc project trước khi lập kế hoạch, sửa code hoặc kết luận về thư viện. Khi rà thư viện, đối chiếu mục 3 của workflow với pubspec.yaml và nhu cầu của tính năng. Nếu không đọc được readmeme.txt, báo rõ đường dẫn và lỗi gặp phải trước khi kết luận. Tham khảo FOLDER_STRUCTURE.md và create_structure.ps1 nếu có. Script là tài liệu tham chiếu cấu trúc, chỉ chạy khi được yêu cầu. Mọi tệp dưới sources/ trong bản mirror là tài liệu chỉ đọc.
- Mặc định không sửa trực tiếp tệp ứng dụng. Chuẩn bị tệp thay thế trong thư mục tạm trên ổ D, đóng ZIP với đường dẫn tương đối từ gốc project và đặt ZIP ngay tại gốc trên ổ D để người dùng tự giải nén.
- Lưu preview trong art_previews/ trên ổ D. Nếu công cụ bắt buộc tạo ảnh trên ổ C, chuyển đúng tệp đầu ra của tác vụ sang ổ D. Chỉ dọn tệp có tên cụ thể thuộc tác vụ và đã xác minh bản đích.
- Chỉ chạy test hoặc build khi người dùng yêu cầu. Khi bàn giao ZIP, nêu vị trí, cách áp dụng, thay đổi chính, kết quả kiểm tra nếu có và gợi ý Conventional Commit.

## Flutter
- Tổ chức theo tính năng. Dùng core/theme/ cho màu, kiểu chữ và token giao diện. Đưa toàn bộ chữ hiển thị, kể cả tooltip và nhãn trợ năng, vào lib/l10n/.
- UI đi qua controller hoặc repository để lấy dữ liệu. Tách widget phức tạp theo tính năng. Tránh comment thông thường trong code tạo hoặc sửa.

## Mỹ thuật
- Chuẩn tranh cảnh là bản Động phủ truyện tranh nét mực gốc. Chuẩn nhân vật là chân dung bên phải trong ảnh so sánh. Dùng màu lì, nét gạch có chọn lọc và giữ nhận diện nhân vật nhất quán. Giản lược nét phụ ở avatar nhỏ.
- Icon dùng mảng đặc rõ, góc lượn nhẹ và cùng bảng màu, độ đậm nét với tranh game. Bế quan thể hiện tu sĩ ngồi thiền trên bồ đoàn.
- Bản đồ nhìn từ trên cao, giữ tỷ lệ địa hình tự nhiên ở cấp vùng. Khi zoom gần, chi tiết bổ sung giúp người chơi đọc địa hình. Ưu tiên asset dùng lại như địa hình, icon và chân dung theo biểu cảm.