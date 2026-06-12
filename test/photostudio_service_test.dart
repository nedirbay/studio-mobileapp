import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studioapp/services/photostudio_service.dart';

void main() {
  tearDown(() => PhotoStudioService.client = http.Client());

  test('videos hits /photostudio/videos/ and maps to StudioMedia', () async {
    late Uri captured;
    PhotoStudioService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode({
        'count': 1,
        'results': [
          {
            'id': 1,
            'title': 'Clip',
            'video_url': 'http://x/v.mp4',
            'thumbnail_image_url': 'http://x/t.jpg',
            'hls_url': 'http://x/index.m3u8',
          }
        ],
      }), 200);
    });

    final result = await PhotoStudioService.videos();
    expect(captured.path, endsWith('/photostudio/videos/'));
    expect(result.single.isVideo, true);
    expect(result.single.title, 'Clip');
    expect(result.single.mediaUrl, 'http://x/v.mp4');
    expect(result.single.hlsUrl, 'http://x/index.m3u8');
  });

  test('images hits /photostudio/images/ and maps to StudioMedia', () async {
    late Uri captured;
    PhotoStudioService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode({
        'results': [
          {'id': 2, 'title': 'Photo', 'image_url': 'http://x/i.jpg'}
        ],
      }), 200);
    });

    final result = await PhotoStudioService.images();
    expect(captured.path, endsWith('/photostudio/images/'));
    expect(result.single.isVideo, false);
    expect(result.single.mediaUrl, 'http://x/i.jpg');
  });

  test('search forwards the search query param', () async {
    late Uri captured;
    PhotoStudioService.client = MockClient((req) async {
      captured = req.url;
      return http.Response('{"results":[]}', 200);
    });
    await PhotoStudioService.videos(search: 'wedding');
    expect(captured.queryParameters['search'], 'wedding');
  });

  test('gallery combines videos and images', () async {
    PhotoStudioService.client = MockClient((req) async {
      if (req.url.path.contains('videos')) {
        return http.Response(json.encode({'results': [{'id': 1, 'title': 'v'}]}), 200);
      }
      return http.Response(json.encode({'results': [{'id': 2, 'title': 'i'}]}), 200);
    });
    final all = await PhotoStudioService.gallery();
    expect(all.length, 2);
    expect(all.first.isVideo, true);
    expect(all.last.isVideo, false);
  });

  test('throws on non-200', () async {
    PhotoStudioService.client = MockClient((req) async => http.Response('err', 500));
    expect(PhotoStudioService.videos(), throwsA(isA<Exception>()));
  });
}
