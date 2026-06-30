import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../models/studio_media.dart';
import 'photo_order_page.dart';

/// Detail / viewer for a single photo-studio media item.
/// Images are shown inline; videos open in the device player via url_launcher.
class StudioMediaDetailPage extends StatelessWidget {
  final StudioMedia media;
  const StudioMediaDetailPage({super.key, required this.media});

  Future<void> _openVideo(BuildContext context) async {
    final url = media.hlsUrl ?? media.mediaUrl;
    if (url == null) return;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wideony açyp bolmady')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const AppHeader(),
              _buildMedia(context),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      media.isVideo ? 'Wideo' : 'Surat',
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    if (media.description != null && media.description!.isNotEmpty) ...[
                      const Divider(height: 40, color: Color(0xFFF3F4F6)),
                      Text(
                        media.description!,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF374151), height: 1.6),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoOrderPage(serviceName: media.title.isEmpty ? 'Surat hyzmaty' : media.title),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Sargyt et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final preview = media.previewUrl ?? media.mediaUrl;
    return GestureDetector(
      onTap: media.isVideo ? () => _openVideo(context) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: preview != null
                ? Image.network(
                    preview,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(Icons.broken_image, size: 50, color: Color(0xFF9CA3AF)),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF3F4F6),
                    child: Icon(
                      media.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                      size: 60,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
          ),
          if (media.isVideo)
            const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
        ],
      ),
    );
  }
}
