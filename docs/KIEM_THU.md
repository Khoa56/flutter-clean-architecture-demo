# Kết quả xác minh

Ngày kiểm tra: 18/10/2026. Môi trường: Windows, Flutter 3.47.7, Dart 3.13.5. Kết quả sau khi tích hợp GetIt + injectable:

| Kiểm tra | Kết quả |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test --coverage` | 41/41 test đạt |
| Unit test Domain với Mocktail | Đạt success/failure, ID không hợp lệ, tìm/lọc/sort |
| Quy tắc phụ thuộc | Domain thuần Dart; Presentation không import Data/HTTP/GetIt |
| Data/HTTP | URL, UTF-8, HTTP 404/401/500, mất mạng, timeout, JSON sai |
| Cubit | Thứ tự trạng thái, retry, filter không gọi thêm API, request cũ, đóng khi đang tải |
| DI | Lazy singleton, Cubit factory, thay DataSource |
| Widget | Tải/tìm/xóa bộ lọc ở 390x844 và 1280x900; mở chi tiết/quay lại |
| REST API thật qua Dart | `/posts`: 100 bài; `/posts/1`: thành công |
| `flutter build web --release --no-web-resources-cdn` | Thành công |
| Thao tác trình duyệt bản build | Hiện 100 bài; tìm `laboriosam` còn 7 bài; mở chi tiết bài 98; nạp lại bản build cuối thành công |
| Android SDK/JDK | Đã cài tại D:\App\Android; Flutter Doctor xác nhận Android toolchain đạt |
| `flutter build apk --release` | Thành công, tạo APK khoảng 48,3 MB |
| Bản Web tiếng Việt | 18 bài qua API Dart; danh sách, chi tiết, UTF-8, HTTP 404 và HEAD đã kiểm tra |
| Giao diện tiếng Việt | Tìm “Kiểm thử để tự tin” ra 1 bài; mở chi tiết bài 11; nút quay lại cũng được Việt hóa |

Line coverage trong các file được test runner thu thập: **345/400 dòng (86,25%)**; riêng các file Domain trong báo cáo **28/28 dòng (100%)**. Đây không phải khẳng định mọi dòng của toàn bộ dự án đã được cover: `main.dart` không chạy trong widget test và file generated được đánh dấu bỏ qua coverage. Coverage không thay thế kiểm tra chất lượng test hoặc thử nghiệm thiết bị.

Ảnh đã chụp từ ứng dụng thực tế:

- `images/danh-sach.png`: danh sách 18 bài tiếng Việt lấy qua REST API Dart đi kèm.
- `images/chi-tiet.png`: chi tiết bài 11 bằng tiếng Việt.

Bản Web tiếng Việt đã chạy lại analyze, cả 41 test và build thành công. Số liệu coverage ở trên thuộc lần đo có `--coverage` trước lượt Việt hóa. APK trước đó vẫn dùng JSONPlaceholder; lượt cập nhật nội dung này dành cho Web. Chạy bản Web tiếng Việt bằng `CHAY_WEB.ps1`; REST API và file nội dung đều có trong mã nguồn.

## Phần chưa xác minh được trên máy hiện tại

- **Đã build APK**, nhưng chưa chạy ứng dụng trên điện thoại/Android Emulator vì chưa có thiết bị Android kết nối. Cần thử trên thiết bị trước buổi báo cáo để đáp ứng yêu cầu demo thực tế của đề. Xem `ANDROID_SDK.md` để biết bộ công cụ đã cài và cách chạy.
- Không có Visual Studio C++ workload nên chưa build Windows desktop. Web đã build và chạy thực tế.
- Chưa tạo repository công khai, chưa điền danh tính/WBS thực tế, chưa có commit riêng của từng thành viên. Các việc này cần tài khoản và thông tin thật của nhóm.

Video không phải yêu cầu được nêu riêng cho chủ đề 04. Có kịch bản demo để nhóm thực hiện trực tiếp. Slide do người khác phụ trách theo phân công của bạn.

## Chạy lại

```sh
flutter pub get
dart run build_runner build
flutter analyze
flutter test --coverage
dart run tool/check_api.dart
flutter build web --release --no-web-resources-cdn
```

Generator dùng phiên bản analyzer hỗ trợ ngôn ngữ 3.12 nên có thể cảnh báo khi chạy bằng Dart 3.13; việc sinh mã đã thành công và mã sinh ra đã được analyzer, test và build kiểm tra. Quá trình Web build cũng có thể hiện thông báo tree-shaking font Cupertino từ SDK; ứng dụng chỉ dùng Material Icons và đã kiểm tra hiển thị bình thường.
