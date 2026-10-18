# Android SDK trên máy hiện tại

SDK đã được cài theo yêu cầu tại ổ D:

| Thành phần | Đường dẫn |
| --- | --- |
| Android SDK | `D:\App\Android\Sdk` |
| JDK 21 | `D:\App\Android\Jdk` |
| Cache Gradle | `D:\App\Android\Cache\gradle` |
| File tải và nhật ký cài đặt | `D:\App\Android\Cache` |

Đã cài Platform Android 36, Build Tools 36.0.0, Platform Tools/ADB và NDK 28.2.13676358. Flutter đã được cấu hình nhận SDK và JDK, các giấy phép SDK đã hoàn tất. Flutter Doctor xác nhận Android toolchain đạt.

Các biến môi trường tài khoản đã cập nhật: `ANDROID_HOME`, `JAVA_HOME`, `GRADLE_USER_HOME`; PATH có ADB, SDK Manager và Java. Mở lại terminal/ứng dụng biên tập nếu chúng đang dùng môi trường cũ.

SDK Manager 19.0 được dùng ở `cmdline-tools/latest` để tương thích Windows hiện tại. Bản CLI 23.0 đã tải được giữ riêng ở `cmdline-tools/23.0`. Không cần cài toàn bộ Android Studio để build từ dòng lệnh.

Java trên máy gặp lỗi tạo socket ở thư mục tạm mặc định. Cấu hình `jdk.net.unixdomain.tmpdir=D:/App/Android/Cache/tmp` đã được đặt trong **riêng JDK Android**, tại `Jdk/conf/net.properties`. Bản sao cấu hình trước khi chỉnh nằm trong Cache; biến TEMP/TMP toàn hệ thống không bị đổi.

## Build APK

Trong thư mục dự án:

```powershell
.\BUILD_APK.ps1
```

Hoặc nếu Flutter đã có trong PATH:

```sh
flutter build apk --release
```

APK ở `build/app/outputs/flutter-apk/app-release.apk`, dùng API thật và dùng khóa debug cho mục đích demo. SDK/JDK không được đưa vào ZIP mã nguồn; khi chuyển máy cần cài bộ công cụ tương ứng.

Bản release đã được build thành công trên máy hiện tại (khoảng 48,3 MB) và sao chép ra file bàn giao `GocDoc_ChuDe04.apk` cạnh ZIP mã nguồn. Chưa chạy APK trên thiết bị Android trong lượt này.

## Chạy trên điện thoại

Bật USB debugging, cắm cáp và chấp nhận kết nối trên điện thoại:

```sh
flutter devices
flutter run -d <DEVICE_ID>
```

Chưa cài Android Emulator hoặc system image trong lượt cài SDK này. Có thể dùng điện thoại Android để demo; việc build thành công không thay thế thử nghiệm ứng dụng trên thiết bị.
