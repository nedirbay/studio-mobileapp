import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../models/studio_media.dart';
import '../services/photostudio_service.dart';
import '../services/sync_service.dart';
import 'photostudio_detail_page.dart';
import 'photo_order_page.dart';

/// Photo-studio gallery — videos and photos for viewing (UI-UX experiment),
/// backed by the photostudio `videos/` and `images/` endpoints.
class PhotoStudioPage extends StatefulWidget {
  const PhotoStudioPage({super.key});

  @override
  State<PhotoStudioPage> createState() => _PhotoStudioPageState();
}

class _PhotoStudioPageState extends State<PhotoStudioPage> {
  List<StudioMedia> _videos = [];
  List<StudioMedia> _images = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all'; // all | video | image

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
      final results = await Future.wait([
        PhotoStudioService.videos(),
        PhotoStudioService.images(),
      ]);
      if (!mounted) return;
      setState(() {
        _videos = results[0];
        _images = results[1];
        _isLoading = false;
      });
      SyncService.checkForUpdates();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Mazmuny ýükläp bolmady';
        _isLoading = false;
      });
    }
  }

  List<StudioMedia> get _items {
    switch (_filter) {
      case 'video':
        return _videos;
      case 'image':
        return _images;
      default:
        return [..._videos, ..._images];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            _buildFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : _error != null
                      ? _buildEmpty(_error!, retry: true)
                      : _items.isEmpty
                          ? _buildEmpty('Häzirlikçe mazmun ýok')
                          : RefreshIndicator(
                              onRefresh: _fetch,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (context, index) => _MediaTile(
                                  media: _items[index],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudioMediaDetailPage(media: _items[index]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.event_available_outlined),
        label: const Text('Sargyt et'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PhotoOrderPage(serviceName: 'Foto studio hyzmaty')),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    const tabs = [
      ('all', 'Hemmesi'),
      ('video', 'Wideolar'),
      ('image', 'Suratlar'),
    ];
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (final t in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t.$2),
                selected: _filter == t.$1,
                onSelected: (_) => setState(() => _filter = t.$1),
                selectedColor: Colors.black,
                labelStyle: TextStyle(color: _filter == t.$1 ? Colors.white : Colors.black),
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message, {bool retry = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_library_outlined, size: 56, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF6B7280))),
          if (retry) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _fetch, child: const Text('Gaýtadan synanyş')),
          ],
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final StudioMedia media;
  final VoidCallback onTap;

  const _MediaTile({required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final preview = media.previewUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (preview != null)
                    Image.network(
                      preview,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _fallback(),
                    )
                  else
                    _fallback(),
                  if (media.isVideo)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, size: 44, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        color: const Color(0xFFF3F4F6),
        child: Icon(
          media.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
          size: 40,
          color: const Color(0xFF9CA3AF),
        ),
      );
}
