import '../config.dart';

/// A photo-studio gallery item — either a video or an image.
/// Mirrors the backend PhotoStudioVideo / PhotoStudioImage serializers.
class StudioMedia {
  final int id;
  final String title;
  final String? description;
  final bool isVideo;
  final String? thumbnailUrl;

  /// For images: the full-size image url. For videos: the playable video url.
  final String? mediaUrl;

  /// HLS playlist url for videos, when transcoding has finished.
  final String? hlsUrl;
  final String? createdAt;

  StudioMedia({
    required this.id,
    required this.title,
    this.description,
    required this.isVideo,
    this.thumbnailUrl,
    this.mediaUrl,
    this.hlsUrl,
    this.createdAt,
  });

  factory StudioMedia.fromVideoJson(Map<String, dynamic> json) {
    return StudioMedia(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      isVideo: true,
      thumbnailUrl: resolveMedia(json['thumbnail_image_url'] ?? json['thumbnail_image']),
      mediaUrl: resolveMedia(json['video_url'] ?? json['video']),
      hlsUrl: resolveMedia(json['hls_url']),
      createdAt: json['create_at']?.toString(),
    );
  }

  factory StudioMedia.fromImageJson(Map<String, dynamic> json) {
    return StudioMedia(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      isVideo: false,
      thumbnailUrl: resolveMedia(json['thumbnail_image_url'] ?? json['thumbnail_image']),
      mediaUrl: resolveMedia(json['image_url'] ?? json['image']),
      createdAt: json['create_at']?.toString(),
    );
  }

  /// The best url to show as a preview (thumbnail, else the media itself).
  String? get previewUrl => thumbnailUrl ?? (isVideo ? null : mediaUrl);

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  static String? resolveMedia(dynamic url) {
    if (url == null) return null;
    final s = url.toString();
    if (s.isEmpty) return null;
    if (s.startsWith('http') || s.startsWith('blob:') || s.startsWith('data:')) return s;
    return '${Config.mediaBaseUrl}${s.startsWith('/') ? '' : '/'}$s';
  }
}
