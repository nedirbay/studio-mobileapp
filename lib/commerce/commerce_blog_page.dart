import 'package:flutter/material.dart';
import '../config.dart';
import '../widgets/top_bar.dart';
import '../services/blog_service.dart';

class CommerceBlogPage extends StatefulWidget {
  const CommerceBlogPage({super.key});

  @override
  State<CommerceBlogPage> createState() => _CommerceBlogPageState();
}

class _CommerceBlogPageState extends State<CommerceBlogPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final result = await BlogService.list();
      if (!mounted) return;
      setState(() {
        posts = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching blog posts: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Blog & Täzelikler')),
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : posts.isEmpty
                      ? const Center(child: Text('Täzelik ýok.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final String? mainImg = post['main_image'];
                            final String imageUrl = (mainImg != null && mainImg.isNotEmpty)
                                ? (mainImg.startsWith('http') ? mainImg : '${Config.mediaBaseUrl}$mainImg')
                                : '';

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  // Navigate to blog detail
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Image.network(
                                          imageUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            post['content'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey[700], height: 1.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
