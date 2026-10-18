# Góc đọc - Demo chủ đề 04

Ứng dụng **Flutter viết bằng Dart**, minh họa Clean Architecture và Dependency Injection: tải bài viết từ REST API, tìm trong tiêu đề/nội dung, lọc tác giả, sắp xếp theo ID, xem chi tiết, tải lại và xử lý lỗi.

## Chạy nhanh

**Bản Web tiếng Việt:** có 18 bài viết do API mẫu viết bằng Dart cung cấp. Trên Windows chạy `CHAY_WEB.ps1`, rồi mở `http://127.0.0.1:8788/`. Script build Web và chạy cả REST API cùng một máy chủ. Dừng máy chủ bằng Ctrl+C. Dữ liệu tại `assets/content/posts_vi.json`; đây là nội dung mẫu tiếng Việt tự biên soạn, không phải bản dịch dữ liệu JSONPlaceholder.

Các lệnh tương đương:

```sh
flutter pub get
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE_URL=/api/
dart run tool/demo_server.dart
```

Web gọi `GET /api/posts` và `GET /api/posts/{id}` qua HTTP thật, vẫn sử dụng `PostRemoteDataSource`, Repository, UseCase và Cubit. `/api/` được giải quyết theo địa chỉ Web hiện tại nên có thể dùng cổng khác với `--port=8789`. API chỉ lắng nghe máy cục bộ. Phần dưới hướng dẫn chạy với API công khai hoặc trên Android.

Cài Flutter stable >=3.41, Dart >=3.11 (đi kèm Flutter). Mã được kiểm tra bằng Flutter 3.47.7 / Dart 3.13.5. Giữ `pubspec.lock` để dùng đúng các phiên bản đã kiểm tra.

Mở terminal tại thư mục chứa `pubspec.yaml`:

```sh
flutter pub get
flutter devices
flutter run -d edge
```

Nếu có Chrome, thay `edge` bằng `chrome`. Web dùng để xem trước. **Khi báo cáo theo đề, chạy trên điện thoại Android hoặc Android Emulator.**

### Android

Trên máy hiện tại SDK/JDK đã được cài tại `D:\App\Android` và Flutter Doctor xác nhận Android toolchain đạt. Xem `docs/ANDROID_SDK.md`; có thể dùng `BUILD_APK.ps1` để build bản demo. Các bước dưới đây vẫn áp dụng khi chuyển sang máy khác.

1. Cài Android Studio, Android SDK và JDK mà Flutter hiện tại hỗ trợ; kiểm tra `flutter doctor -v`.
2. Chạy `flutter doctor --android-licenses`, đọc và chấp nhận các điều khoản bạn đồng ý.
3. Mở emulator hoặc cắm điện thoại đã bật USB debugging và chấp nhận kết nối.
4. Chạy `flutter devices`, lấy ID rồi chạy:

```sh
flutter run -d <DEVICE_ID>
```

Manifest chính đã có quyền INTERNET, dùng được cả bản release. Dự án hiện có cấu hình Android, Web và Windows; Windows desktop cần bộ Visual Studio C++ phù hợp theo `flutter doctor`.

### API và cấu hình

Mặc định gọi API thật, không cần tài khoản, API key, Firebase, `.env` hoặc `google-services.json`:

```text
GET https://jsonplaceholder.typicode.com/posts
GET https://jsonplaceholder.typicode.com/posts/{id}
```

API công khai cung cấp nội dung mẫu tiếng Anh/Latin; bản Web tiếng Việt phía trên dùng API Dart đi kèm. Vì dữ liệu không có ngày đăng, ứng dụng ghi “ID tăng/giảm dần”, không coi ID là thời gian đăng. APK đã bàn giao trước đó vẫn dùng API công khai; cập nhật này áp dụng cho bản Web.

Đổi API (URL phải kết thúc bằng `/`):

```sh
flutter run -d edge --dart-define=API_BASE_URL=https://jsonplaceholder.typicode.com/
```

API thay thế phải có `/posts`, `/posts/{id}` và các trường `id`, `userId` (int >0), `title` (string không rỗng), `body` (string). Chạy Web cần server hỗ trợ CORS. Các cờ `--dart-define` là cấu hình biên dịch, đổi cờ cần chạy lại app.

### Dữ liệu mẫu để minh họa DI

```sh
flutter run -d edge --dart-define=USE_FIXTURE=true
```

Thay `edge` bằng ID Android nếu cần. DI chọn `PostFixtureDataSource`, UI hiện nhãn “Đang dùng dữ liệu mẫu”. **Đây không phải lời gọi REST API**, không phải cache và không tự động che lỗi mạng. Khi báo cáo cần demo chế độ API mặc định trước, rồi dùng fixture để chứng minh thay nguồn dữ liệu không sửa UI/Domain.

## Đối chiếu yêu cầu chủ đề 04

| Yêu cầu | Mã nguồn/bằng chứng |
| --- | --- |
| Presentation / Domain / Data | `lib/features/posts/` chia đúng ba tầng |
| Repository Pattern và DIP | Interface `PostRepository` ở Domain; `PostRepositoryImpl` ở Data implements interface |
| UseCase / Interactor | `GetPosts`, `GetPostDetail`, `FilterPosts` |
| REST API | `data/datasources/post_remote_data_source.dart` |
| Dependency Injection | `lib/core/di/`: GetIt + injectable và constructor injection |
| Khởi tạo và liên kết | `main.dart`: binding, cấu hình DI, MultiBlocProvider |
| Unit test Domain với mock | `test/domain/usecases_test.dart`: Mocktail mock abstract repository |
| UI không phụ thuộc DataSource | Presentation không import Data/HTTP/GetIt; `test/architecture` kiểm tra tự động |
| Ngoại lệ và trạng thái | Loading/error/empty/retry, map lỗi hạ tầng thành lỗi Domain |

Demo dùng **GetIt + injectable**. `reader_module.dart` khai báo các factory/lazy singleton; `injection.config.dart` do generator sinh và đã được bàn giao kèm mã nguồn. Domain không gắn annotation và không import injectable. GetIt quản lý object; constructor injection cung cấp dependency; Cubit quản lý trạng thái.

Sau khi sửa khai báo DI, sinh lại file cấu hình (không sửa file generated bằng tay):

```sh
dart run build_runner build
```

## Cấu trúc

```text
lib/
  main.dart                     # Composition root, binding, provider
  app.dart                      # MaterialApp và theme
  core/config/                  # Cấu hình build
  core/di/                      # Object graph, lifetime
  features/posts/
    domain/
      entities/                 # Entity thuần Dart
      failures/                 # Result và lỗi nghiệp vụ
      repositories/             # Abstract interface
      usecases/                 # Tác vụ và quy tắc tìm/lọc
    data/
      models/                   # JSON -> DTO -> Entity
      datasources/              # HTTP và fixture
      repositories/             # Implementation và map lỗi
    presentation/
      cubit/                    # Trạng thái màn hình
      pages/                    # Danh sách / chi tiết
      widgets/                  # Thành phần giao diện
test/                           # Domain, Data, DI, Cubit, UI, architecture
docs/                           # Giải thích, kịch bản demo, WBS, kết quả kiểm thử
```

## Kiểm tra và đóng gói

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter test test/domain test/architecture --reporter expanded
dart run tool/check_api.dart
flutter build web --release --no-web-resources-cdn
flutter build apk --release
```

Coverage ở `coverage/lcov.info`. Yêu cầu >=70% trong tài liệu thuộc chủ đề 25, không phải tiêu chí riêng của chủ đề 04. Test runner dùng `flutter_test`; chính source Domain không import Flutter.

Trên Windows, `CHAY_DEMO.ps1 -Device edge` mở demo, thêm `-Sample` để dùng fixture. `KIEM_TRA.ps1` chạy analyze và test. Cả hai nhận `-FlutterSdk <đường-dẫn-sdk>` nếu chưa thêm Flutter vào PATH. Nếu PowerShell chặn script, dùng các lệnh Flutter trực tiếp ở trên.

Ở thư mục bàn giao trên máy hiện tại, script cũng tự nhận SDK đã chuẩn bị tại `../../work/flutter-sdk` nếu Flutter chưa có trong PATH. ZIP mã nguồn không chứa SDK; khi chuyển sang máy khác cần cài Flutter.

APK được tạo tại `build/app/outputs/flutter-apk/app-release.apk` sau khi build trên máy có Android SDK/JDK. Cấu hình signing hiện tại dùng khóa debug cho demo, chưa phải cấu hình phát hành cửa hàng. Web ở `build/web`, cần phục vụ bằng HTTP, không mở trực tiếp qua `file://`.

## Nộp bài

- Điền WBS theo công việc thực tế trong `docs/PHAN_CONG.md`.
- Đẩy mã lên GitHub/GitLab công khai bằng tài khoản nhóm. Mỗi người commit bằng danh tính thật cho phần thực sự đã làm.
- Không đưa `build`, `.dart_tool`, đường dẫn máy, `.env` hoặc khóa ký vào Git. Giữ `pubspec.lock`.
- Chạy trên đúng thiết bị/máy ảo sẽ dùng khi báo cáo.
- Đọc `docs/KIEN_TRUC.md`, tập với `docs/KICH_BAN_DEMO.md` và đối chiếu nội dung với người làm slide.

Bản giao chưa xuất bản repository hoặc tạo lịch sử commit theo tên thành viên. Slide do người khác thực hiện theo phân công của bạn.

## Tham khảo

- https://docs.flutter.dev/app-architecture
- https://docs.flutter.dev/app-architecture/case-study/dependency-injection
- https://pub.dev/packages/get_it
- https://pub.dev/packages/flutter_bloc
- https://pub.dev/packages/http
- https://pub.dev/packages/mocktail
- https://jsonplaceholder.typicode.com/
