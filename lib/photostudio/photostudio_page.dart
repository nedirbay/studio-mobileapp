import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/top_bar.dart';
import 'photostudio_detail_page.dart';
import '../services/sync_service.dart';

class PhotoStudioPage extends StatefulWidget {
  const PhotoStudioPage({super.key});

  @override
  State<PhotoStudioPage> createState() => _PhotoStudioPageState();
}

class _PhotoStudioPageState extends State<PhotoStudioPage> {
  List<dynamic> blogs = [];
  List<dynamic> categories = [];
  int? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchBlogs();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/photostudio/categories/'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(utf8.decode(response.bodyBytes)) ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/photostudio/blogs/'));
      if (response.statusCode == 200) {
        setState(() {
          blogs = json.decode(utf8.decode(response.bodyBytes)) ?? [];
          isLoading = false;
        });
        SyncService.checkForUpdates();
      }
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
      setState(() => isLoading = false);
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
            _buildCategoryList(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : blogs.isEmpty
                      ? const Center(child: Text('Blog ýok.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            final blog = blogs[index];
                            final String? mainImg = blog['main_image'];
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoStudioDetailPage(blogId: blog['id']),
                                    ),
                                  );
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
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            height: 200,
                                            color: const Color(0xFFF9FAFB),
                                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            blog['category_name'] ?? 'Foto Studio',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            blog['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            blog['content'] ?? '',
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

  Widget _buildCategoryList() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final dynamic category = isAll ? null : categories[index - 1];
          final bool isSelected = isAll ? selectedCategoryId == null : selectedCategoryId == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isAll ? 'Hemmesi' : category['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategoryId = isAll ? null : category['id'];
                  fetchBlogs(); // Re-fetch or filter locally
                });
              },
              selectedColor: Colors.black,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}
