import '../../../config.dart';
import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final PageController pageController;
  final Function(int) onPageChanged;
  final Function(int) onFullScreenTap;
  final String? badge;

  const ImageGallery({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onFullScreenTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final String currentPath = images[index];
                      final url = currentPath.startsWith('http') ? currentPath : '${Config.mediaBaseUrl}${currentPath.startsWith('/') ? '' : '/'}$currentPath';
                      return GestureDetector(
                        onTap: () => onFullScreenTap(index),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            url, 
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentIndex == i ? 24 : 8,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: currentIndex == i ? const Color(0xFFDC2626) : Colors.grey[300],
                      ),
                    )),
                  ),
                ),
              if (badge != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!.toUpperCase(), 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Thumbnails
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final String currentPath = images[index];
                final url = currentPath.startsWith('http') ? currentPath : '${Config.mediaBaseUrl}${currentPath.startsWith('/') ? '' : '/'}$currentPath';
                bool isSelected = currentIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFDC2626) : Colors.grey[200]!,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: const Color(0xFFDC2626).withOpacity(0.1), blurRadius: 10)
                      ] : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
