import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studioapp/services/blog_service.dart';

void main() {
  tearDown(() => BlogService.client = http.Client());

  test('list hits /blogs (not the old /blog/posts/) with pagination params', () async {
    late Uri captured;
    BlogService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode({
        'count': 1,
        'results': [{'id': 1, 'title': 'Hello'}],
      }), 200);
    });

    final posts = await BlogService.list(page: 2, pageSize: 5);
    expect(captured.path, endsWith('/blogs'));
    expect(captured.path.contains('/blog/posts'), false);
    expect(captured.queryParameters['page'], '2');
    expect(captured.queryParameters['page_size'], '5');
    expect(posts.single['title'], 'Hello');
  });

  test('list also accepts a plain list response', () async {
    BlogService.client = MockClient((req) async => http.Response(json.encode([{'id': 3}]), 200));
    final posts = await BlogService.list();
    expect(posts.single['id'], 3);
  });

  test('detail hits /blogs/{id}', () async {
    late Uri captured;
    BlogService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode({'id': 42, 'title': 'Post'}), 200);
    });
    final post = await BlogService.detail(42);
    expect(captured.path, endsWith('/blogs/42'));
    expect(post['title'], 'Post');
  });

  test('throws on non-200', () async {
    BlogService.client = MockClient((req) async => http.Response('nope', 404));
    expect(BlogService.detail(1), throwsA(isA<Exception>()));
  });
}
