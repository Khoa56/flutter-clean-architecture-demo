# Kịch bản demo 5 phút

## Chuẩn bị

- Dùng Android Emulator/điện thoại để đáp ứng đề; kiểm tra Internet trước buổi báo cáo.
- Chạy chế độ API mặc định, mở thử danh sách và chi tiết.
- Mở sẵn repository interface, UseCase, repository implementation, file DI và test Domain.
- Đọc `KIEN_TRUC.md`; giải thích bằng lời của mình, đối chiếu với slide của bạn cùng nhóm.

## 00:00-01:00 - Chức năng

Tải bài từ API, tìm một từ trong bài đang có, lọc tác giả, đổi thứ tự ID, đặt lại bộ lọc, mở chi tiết và quay lại. Nói rõ UI phát lệnh cho Cubit, Cubit gọi UseCase.

## 01:00-02:10 - Kiến trúc và DIP

Mở `domain/repositories/post_repository.dart`: interface thuộc Domain. Mở `get_posts.dart`: nhận interface qua constructor. Mở `data/repositories/post_repository_impl.dart`: Data implements interface, map Model/Entity và lỗi. Mở `posts_cubit.dart`: không có import DataSource hoặc HTTP.

Giải thích Data và Presentation cùng phụ thuộc Domain. Phân biệt chiều import với chiều gọi runtime.

## 02:10-03:00 - DI

Mở `lib/core/di/reader_module.dart` và `injection.config.dart`: chỉ ra Client -> DataSource -> Repository -> UseCase -> Cubit. Giải thích injectable sinh mã đăng ký GetIt, lazy singleton của dịch vụ và factory của Cubit; provider sở hữu và close Cubit. Mở `main.dart` để chỉ binding và MultiBlocProvider.

Có thể chuẩn bị lần chạy riêng với `--dart-define=USE_FIXTURE=true` để minh họa đổi nguồn dữ liệu qua DI. UI phải hiện nhãn dữ liệu mẫu; không nói đó là API thật. Đổi cờ cần chạy lại, không phải hot reload cấu hình. Nếu khởi động lại quá lâu, chỉ giải thích đoạn chọn DataSource.

## 03:00-04:20 - Test Domain với mock

```sh
flutter test test/domain test/architecture --reporter expanded
```

Chỉ ra `MockPostRepository implements PostRepository`; success, failure, ID sai không gọi repository và quy tắc tìm/lọc. Test không gọi Internet. Cho xem architecture test chặn import sai chiều. Nếu đủ thời gian chạy thêm `flutter test test/di`.

## 04:20-05:00 - Lỗi và thử lại

Ở chế độ API, tắt Internet trên thiết bị, bấm tải lại và chờ lỗi (timeout tối đa khoảng 12 giây). Bật mạng rồi bấm “Thử lại”. Fixture không phù hợp để biểu diễn mất mạng vì fixture không dùng mạng.

Tóm tắt luồng bằng chính mã: Widget -> Cubit -> UseCase -> Repository interface -> RepositoryImpl -> DataSource -> API, chiều về là Entity hoặc lỗi Domain.

## Nếu được yêu cầu sửa trực tiếp

- Thay quy tắc sort: sửa `FilterPosts` và chạy test Domain.
- Thay tên trường JSON: sửa `PostModel.fromJson`, giữ Entity nếu nghiệp vụ giữ nguyên.
- Thay nguồn: đổi đăng ký DI, không thêm if theo nguồn trong widget.
- Thêm xử lý lỗi: map ở repository, không bắt HTTP exception trong UI.
