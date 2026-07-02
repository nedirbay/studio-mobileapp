import 'package:flutter_test/flutter_test.dart';
import 'package:doganlarfoto/models/studio_media.dart';

void main() {
  group('StudioMedia.fromVideoJson', () {
    test('marks as video and resolves urls', () {
      final m = StudioMedia.fromVideoJson({
        'id': 1,
        'title': 'Clip',
        'description': 'd',
        'video_url': 'http://x/v.mp4',
        'thumbnail_image_url': 'http://x/t.jpg',
        'hls_url': 'http://x/i.m3u8',
      });
      expect(m.isVideo, true);
      expect(m.mediaUrl, 'http://x/v.mp4');
      expect(m.thumbnailUrl, 'http://x/t.jpg');
      expect(m.hlsUrl, 'http://x/i.m3u8');
      expect(m.previewUrl, 'http://x/t.jpg');
    });

    test('prefixes relative media paths with the media base url', () {
      final m = StudioMedia.fromVideoJson({'id': 1, 'title': 'C', 'video': '/media/v.mp4'});
      expect(m.mediaUrl!.startsWith('http'), true);
      expect(m.mediaUrl!.endsWith('/media/v.mp4'), true);
    });
  });

  group('StudioMedia.fromImageJson', () {
    test('marks as image and falls back to media url for preview', () {
      final m = StudioMedia.fromImageJson({'id': 2, 'title': 'Photo', 'image_url': 'http://x/i.jpg'});
      expect(m.isVideo, false);
      expect(m.mediaUrl, 'http://x/i.jpg');
      expect(m.previewUrl, 'http://x/i.jpg'); // no thumbnail -> uses image
    });

    test('handles missing fields safely', () {
      final m = StudioMedia.fromImageJson({'id': '3'});
      expect(m.id, 3);
      expect(m.title, '');
      expect(m.mediaUrl, isNull);
      expect(m.previewUrl, isNull);
    });
  });
}
