import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import 'photo_order_page.dart';

class PhotoStudioDetailPage extends StatefulWidget {
  final int blogId;
  const PhotoStudioDetailPage({super.key, required this.blogId});

  @override
  State<PhotoStudioDetailPage> createState() => _PhotoStudioDetailPageState();
}

class _PhotoStudioDetailPageState extends State<PhotoStudioDetailPage> {
  Map<String, dynamic>? blog;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogDetail();
  }

  Future<void> fetchBlogDetail() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/photostudio/blogs/${widget.blogId}/'));
      if (response.statusCode == 200) {
        setState(() {
          blog = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching blog detail: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (blog == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Tapylmady')),
        body: const Center(child: Text('Maglumat tapylmady.')),
      );
    }

    final mediaList = blog!['media'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const AppHeader(),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog!['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      blog!['category_name'] ?? 'Foto Studio',
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 40, color: Color(0xFFF3F4F6)),
                    Text(
                      blog!['content'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              if (mediaList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Galereýa',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mediaList.length,
                        itemBuilder: (context, index) {
                          final media = mediaList[index];
                          final String? url = media['file'];
                          final bool isVideo = media['is_video'] ?? false;
                          
                          if (url == null) return const SizedBox.shrink();
                          
                          final fullUrl = url.startsWith('http') ? url : '${Config.mediaBaseUrl}$url';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: isVideo
                                  ? Container(
                                      height: 200,
                                      color: Colors.black12,
                                      child: const Center(
                                        child: Icon(Icons.play_circle_fill, size: 50, color: Colors.black54),
                                      ),
                                    )
                                  : Image.network(
                                      fullUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),
              
              // Order Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoOrderPage(serviceName: blog!['title'] ?? 'Surat hyzmaty'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sargyt et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              const SizedBox(height: 60),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
