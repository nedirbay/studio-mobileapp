import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/photostudio_service.dart';
import '../models/studio_media.dart';
import 'widgets/studio_order_tab.dart';
import 'widgets/photo_viewer_page.dart';
import '../identity/profile_page.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';

class StudioMainPage extends StatefulWidget {
  final int initialTab;

  const StudioMainPage({super.key, this.initialTab = 0});

  @override
  State<StudioMainPage> createState() => _StudioMainPageState();
}

class _StudioMainPageState extends State<StudioMainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const _VideosTabBody(),
      const _PhotosTabBody(),
      const StudioOrderTab(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex == 0 || _currentIndex == 1) ...[
              const TopBar(),
              const AppHeader(),
            ],
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: children,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFDC2626), // brand color
          unselectedItemColor: const Color(0xFF9CA3AF),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), activeIcon: Icon(Icons.videocam_rounded), label: 'Wideolar'),
            BottomNavigationBarItem(icon: Icon(Icons.photo_library_outlined), activeIcon: Icon(Icons.photo_library_rounded), label: 'Suratlar'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note_rounded), label: 'Sargyt et'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _VideosTabBody extends StatefulWidget {
  const _VideosTabBody();

  @override
  State<_VideosTabBody> createState() => _VideosTabBodyState();
}

class _VideosTabBodyState extends State<_VideosTabBody> {
  List<StudioMedia> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await PhotoStudioService.videos();
      if (!mounted) return;
      setState(() {
        _videos = res;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Wideolary ýükläp bolmady';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playVideo(StudioMedia media) async {
    final url = media.hlsUrl ?? media.mediaUrl;
    if (url == null) return;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wideony açyp bolmady')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (_error != null) return _buildError(_error!);
    if (_videos.isEmpty) return _buildEmpty('Häzirlikçe wideo ýok');

    return RefreshIndicator(
      onRefresh: _fetch,
      color: const Color(0xFFDC2626),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final media = _videos[index];
          final preview = media.previewUrl ?? media.mediaUrl;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.5),
              child: InkWell(
                onTap: () => _playVideo(media),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (preview != null)
                            Image.network(preview, fit: BoxFit.cover, errorBuilder: (c, e, s) => _fallback())
                          else
                            _fallback(),
                          Container(color: Colors.black26),
                          const Center(child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallback() => Container(color: const Color(0xFFF3F4F6), child: const Icon(Icons.videocam_outlined, size: 40, color: Color(0xFF9CA3AF)));

  Widget _buildError(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(msg), const SizedBox(height: 12), OutlinedButton(onPressed: _fetch, child: const Text('Gaýtadan synanyş'))]));

  Widget _buildEmpty(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.videocam_outlined, size: 48, color: Colors.grey), const SizedBox(height: 12), Text(msg, style: const TextStyle(color: Colors.grey))]));
}

class _PhotosTabBody extends StatefulWidget {
  const _PhotosTabBody();

  @override
  State<_PhotosTabBody> createState() => _PhotosTabBodyState();
}

class _PhotosTabBodyState extends State<_PhotosTabBody> {
  List<StudioMedia> _photos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await PhotoStudioService.images();
      if (!mounted) return;
      setState(() {
        _photos = res;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Suratlary ýükläp bolmady';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (_error != null) return _buildError(_error!);
    if (_photos.isEmpty) return _buildEmpty('Häzirlikçe surat ýok');

    return RefreshIndicator(
      onRefresh: _fetch,
      color: const Color(0xFFDC2626),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final media = _photos[index];
          final preview = media.mediaUrl;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.5),
              child: InkWell(
                onTap: () {
                  if (preview != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewerPage(imageUrl: preview, title: media.title),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18.5)),
                        child: Hero(
                          tag: preview ?? '',
                          child: preview != null
                              ? Image.network(preview, fit: BoxFit.cover, errorBuilder: (c, e, s) => _fallback())
                              : _fallback(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallback() => Container(color: const Color(0xFFF3F4F6), child: const Icon(Icons.image_outlined, size: 40, color: Color(0xFF9CA3AF)));

  Widget _buildError(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(msg), const SizedBox(height: 12), OutlinedButton(onPressed: _fetch, child: const Text('Gaýtadan synanyş'))]));

  Widget _buildEmpty(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.image_outlined, size: 48, color: Colors.grey), const SizedBox(height: 12), Text(msg, style: const TextStyle(color: Colors.grey))]));
}
