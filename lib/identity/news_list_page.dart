import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../config.dart';
import '../services/blog_service.dart';
import '../services/settings_service.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  List<dynamic> _blogs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    try {
      final result = await BlogService.list(pageSize: 50);
      if (!mounted) return;
      setState(() {
        _blogs = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _resolveMedia(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final String base = Config.mediaBaseUrl;
    if (url.startsWith('/')) {
      return '$base$url';
    }
    return '$base/$url';
  }

  String _formatDate(String dateStr, String langCode) {
    try {
      final date = DateTime.parse(dateStr);
      final locale = langCode == 'TM' ? 'tk' : (langCode == 'RU' ? 'ru' : 'en');
      return DateFormat.yMMMd(locale).format(date);
    } catch (_) {
      return dateStr;
    }
  }

  bool _hasVideo(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media == null) return false;
    return media.any((m) => m['kind'] == 'video');
  }

  String _getVideoSource(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media == null) return '';
    final videoMedia = media.firstWhere((m) => m['kind'] == 'video', orElse: () => null);
    return videoMedia != null ? videoMedia['url'] ?? '' : '';
  }

  String _getImageSource(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media != null) {
      final imgMedia = media.firstWhere((m) => m['kind'] == 'image', orElse: () => null);
      if (imgMedia != null && imgMedia['url'] != null) return imgMedia['url'];
    }
    return blog['main_image'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          settings.translate('news'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _fetchBlogs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              : _blogs.isEmpty
                  ? Center(
                      child: Text(
                        settings.translate('no_news'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _blogs.length,
                      itemBuilder: (context, index) {
                        final blog = _blogs[index];
                        final title = blog['title'] ?? '';
                        final content = blog['content'] ?? '';
                        final dateStr = blog['date'] ?? '';
                        final imgSource = _getImageSource(blog);
                        final imageUrl = _resolveMedia(imgSource);
                        final hasVideoMedia = _hasVideo(blog);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 20.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsReelsViewer(
                                    blogs: _blogs,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Media cover
                                Stack(
                                  children: [
                                    if (imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        child: Image.network(
                                          imageUrl,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[800],
                                              child: const Center(
                                                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                    if (hasVideoMedia)
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.play_circle_fill, size: 14, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                settings.translate('video_label'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFFDC2626)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatDate(dateStr, settings.languageCode),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Text(
                                            settings.translate('play_reels'),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFDC2626)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class NewsReelsViewer extends StatefulWidget {
  final List<dynamic> blogs;
  final int initialIndex;

  const NewsReelsViewer({
    super.key,
    required this.blogs,
    required this.initialIndex,
  });

  @override
  State<NewsReelsViewer> createState() => _NewsReelsViewerState();
}

class _NewsReelsViewerState extends State<NewsReelsViewer> {
  late PageController _pageController;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.blogs.length,
            itemBuilder: (context, index) {
              return ReelItemView(
                blog: widget.blogs[index],
                isMuted: _isMuted,
                onMuteToggle: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
              );
            },
          ),
          // Top controls overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReelItemView extends StatelessWidget {
  final dynamic blog;
  final bool isMuted;
  final VoidCallback onMuteToggle;

  const ReelItemView({
    super.key,
    required this.blog,
    required this.isMuted,
    required this.onMuteToggle,
  });

  String _resolveMedia(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final String base = Config.mediaBaseUrl;
    if (url.startsWith('/')) {
      return '$base$url';
    }
    return '$base/$url';
  }

  bool _hasVideo(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media == null) return false;
    return media.any((m) => m['kind'] == 'video');
  }

  String _getVideoSource(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media == null) return '';
    final videoMedia = media.firstWhere((m) => m['kind'] == 'video', orElse: () => null);
    return videoMedia != null ? videoMedia['url'] ?? '' : '';
  }

  String _getImageSource(dynamic blog) {
    final media = blog['media'] as List<dynamic>?;
    if (media != null) {
      final imgMedia = media.firstWhere((m) => m['kind'] == 'image', orElse: () => null);
      if (imgMedia != null && imgMedia['url'] != null) return imgMedia['url'];
    }
    return blog['main_image'] ?? '';
  }

  String _formatDate(String dateStr, String langCode) {
    try {
      final date = DateTime.parse(dateStr);
      final locale = langCode == 'TM' ? 'tk' : (langCode == 'RU' ? 'ru' : 'en');
      return DateFormat.yMMMd(locale).format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = blog['title'] ?? '';
    final content = blog['content'] ?? '';
    final dateStr = blog['date'] ?? '';
    final isVideo = _hasVideo(blog);
    final settings = SettingsService();

    return Stack(
      children: [
        // Background media
        SizedBox.expand(
          child: isVideo
              ? ReelVideoPlayer(
                  videoUrl: _resolveMedia(_getVideoSource(blog)),
                  isMuted: isMuted,
                  posterUrl: _resolveMedia(_getImageSource(blog)),
                )
              : Image.network(
                  _resolveMedia(_getImageSource(blog)),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),

        // Bottom gradient for text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Information Overlay
        Positioned(
          left: 16,
          right: 80,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author metadata row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFF59E0B)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doganlar Blog',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(dateStr, settings.languageCode),
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.22,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isMuted;
  final String posterUrl;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.isMuted,
    required this.posterUrl,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isPlaying = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      if (!mounted) return;
      _controller!.setLooping(true);
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
      await _controller!.play();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Error loading video: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialized && _controller != null) {
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized || _controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Image.network(
        widget.posterUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
      );
    }
    if (!_initialized || _controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
          ),
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      );
    }
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
