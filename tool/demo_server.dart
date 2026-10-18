import 'dart:convert';
import 'dart:io';

/// REST API bài viết tiếng Việt và máy chủ Web cho bản demo.
/// Chạy tại thư mục dự án: dart run tool/demo_server.dart
Future<void> main(List<String> args) async {
  final portArgument = args.where((arg) => arg.startsWith('--port='));
  final port = portArgument.isEmpty
      ? 8788
      : int.parse(portArgument.single.substring('--port='.length));
  final root = File.fromUri(Platform.script).parent.parent;
  final web = Directory('${root.path}/build/web');
  final content = File('${root.path}/assets/content/posts_vi.json');
  final decoded = jsonDecode(await content.readAsString());
  if (decoded is! List<Object?>) {
    throw const FormatException('Nội dung bài viết phải là danh sách JSON.');
  }
  final posts = decoded
      .map((value) {
        if (value is! Map<String, Object?> || value['id'] is! int) {
          throw const FormatException('Bài viết không hợp lệ.');
        }
        return value;
      })
      .toList(growable: false);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Góc đọc: http://127.0.0.1:$port/');
  stdout.writeln('REST API tiếng Việt: http://127.0.0.1:$port/api/posts');
  await for (final request in server) {
    try {
      await _handle(request, posts, web);
    } catch (error) {
      stderr.writeln('Không phục vụ được yêu cầu: $error');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {
        // Trình duyệt có thể đã đóng kết nối.
      }
    }
  }
}

Future<void> _handle(
  HttpRequest request,
  List<Map<String, Object?>> posts,
  Directory web,
) async {
  final response = request.response;
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Accept, Content-Type');
  response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }
  if (!{'GET', 'HEAD'}.contains(request.method)) {
    response.statusCode = HttpStatus.methodNotAllowed;
    response.headers.set(HttpHeaders.allowHeader, 'GET, HEAD, OPTIONS');
    await response.close();
    return;
  }
  final segments = request.uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isNotEmpty && segments.first == 'api') {
    Object result = {'message': 'Không tìm thấy đường dẫn.'};
    response.statusCode = HttpStatus.notFound;
    if (segments.length == 2 && segments[1] == 'posts') {
      result = posts;
      response.statusCode = HttpStatus.ok;
    } else if (segments.length == 3 && segments[1] == 'posts') {
      final id = int.tryParse(segments[2]);
      for (final post in posts) {
        if (post['id'] == id) {
          result = post;
          response.statusCode = HttpStatus.ok;
          break;
        }
      }
    }
    response.headers.contentType = ContentType.json;
    if (request.method != 'HEAD') response.write(jsonEncode(result));
    await response.close();
    return;
  }
  if (segments.any(
    (s) => s == '..' || s == '.' || s.contains('\\') || s.contains('/'),
  )) {
    response.statusCode = HttpStatus.badRequest;
    await response.close();
    return;
  }
  final relative = segments.isEmpty ? 'index.html' : segments.join('/');
  final file = File('${web.path}/$relative');
  if (!await file.exists()) {
    response.statusCode = HttpStatus.notFound;
    await response.close();
    return;
  }
  final extension = relative.split('.').last;
  response.headers.set(HttpHeaders.contentTypeHeader, switch (extension) {
    'html' => 'text/html; charset=utf-8',
    'js' || 'mjs' => 'application/javascript; charset=utf-8',
    'json' => 'application/json; charset=utf-8',
    'css' => 'text/css; charset=utf-8',
    'wasm' => 'application/wasm',
    'png' => 'image/png',
    'svg' => 'image/svg+xml',
    'ico' => 'image/x-icon',
    'otf' => 'font/otf',
    'ttf' => 'font/ttf',
    'woff2' => 'font/woff2',
    _ => 'application/octet-stream',
  });
  if (request.method != 'HEAD') await response.addStream(file.openRead());
  await response.close();
}
