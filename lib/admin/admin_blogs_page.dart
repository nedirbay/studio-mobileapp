import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../services/admin_service.dart';
import '../config.dart';


class AdminBlogsPage extends StatefulWidget {
  const AdminBlogsPage({super.key});

  @override
  State<AdminBlogsPage> createState() => _AdminBlogsPageState();
}

class _AdminBlogsPageState extends State<AdminBlogsPage> {
  bool _isLoading = true;
  List<dynamic> _blogs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listBlogs();
      setState(() {
        _blogs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBlog(String slug) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blogy pozmak'),
        content: const Text('Hakykatdan hem bu blogy pozmak isleýärsiňizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Poz'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.deleteBlog(slug);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog pozuldy'), backgroundColor: Colors.green),
      );
      _loadBlogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showBlogEditor([dynamic blog]) {
    final bool isEdit = blog != null;
    final titleController = TextEditingController(text: isEdit ? blog['title'] ?? '' : '');
    final slugController = TextEditingController(text: isEdit ? blog['slug'] ?? '' : '');
    final contentController = TextEditingController(text: isEdit ? blog['content'] ?? '' : '');
    final dateController = TextEditingController(
      text: isEdit
          ? blog['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    String? mainImageUrl = isEdit ? (blog['main_image'] ?? blog['image'] ?? '') : '';
    List<dynamic> localMedia = isEdit && blog['media'] != null
        ? List<dynamic>.from(blog['media'].map((m) => {
              'kind': m['kind'] ?? 'image',
              'url': m['url'] ?? '',
            }))
        : [];

    bool isMainUploading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickMainImage() async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  setModalState(() => isMainUploading = true);
                  final url = await AdminService.uploadImage(
                    filePath: file.path,
                    fileBytes: file.bytes,
                    fileName: file.name,
                  );
                  setModalState(() {
                    mainImageUrl = url;
                    isMainUploading = false;
                  });
                }
              } catch (e) {
                setModalState(() => isMainUploading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat ýüklenmedi: $e'), backgroundColor: Colors.red),
                );
              }
            }

            Future<void> pickMediaFile(int index) async {
              try {
                final kind = localMedia[index]['kind'] ?? 'image';
                final result = await FilePicker.pickFiles(
                  type: kind == 'video' ? FileType.video : FileType.image,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faýl ýüklenilýär...'), duration: Duration(seconds: 1)),
                  );
                  final url = await AdminService.uploadImage(
                    filePath: file.path,
                    fileBytes: file.bytes,
                    fileName: file.name,
                  );
                  setModalState(() {
                    localMedia[index]['url'] = url;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faýl üstünlikli ýüklenildi!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Faýl ýüklenmedi: $e'), backgroundColor: Colors.red),
                );
              }
            }

            Future<void> selectDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setModalState(() {
                  dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            }

            return SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      maxWidth: 600,
                    ),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEdit ? 'Posty üýtgetmek' : 'Täze post goşmak',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Makalanyň ady',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    hintText: 'Başlygy ýazyň...',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                  ),
                                ),
                                if (isEdit) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Salgysy (Slug)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: slugController,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sene',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          TextField(
                                            controller: dateController,
                                            readOnly: true,
                                            onTap: selectDate,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.all(12),
                                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Esasy surat',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          ElevatedButton.icon(
                                            onPressed: isMainUploading ? null : pickMainImage,
                                            icon: isMainUploading
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.upload_file, size: 18),
                                            label: Text(
                                              mainImageUrl != null && mainImageUrl!.isNotEmpty
                                                  ? 'Suraty üýtget'
                                                  : 'Surat ýükle',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size.fromHeight(48),
                                              backgroundColor: Colors.grey[100],
                                              foregroundColor: Colors.black87,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                side: BorderSide(color: Colors.grey[400]!),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (mainImageUrl != null && mainImageUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _showFullScreenImage(mainImageUrl!),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _getMediaUrl(mainImageUrl!),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Text(
                                  'Mazmuny (Text)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: contentController,
                                  maxLines: 8,
                                  decoration: const InputDecoration(
                                    hintText: 'Makalanyň doly tekstini şu ýere ýazyň...',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Media Galereýasy',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        setModalState(() {
                                          localMedia.add({'kind': 'image', 'url': ''});
                                        });
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Media goş'),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                if (localMedia.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: Text(
                                        'Hiç hili media ýok.',
                                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: localMedia.length,
                                    itemBuilder: (context, idx) {
                                      final item = localMedia[idx];
                                      final String kind = item['kind'] ?? 'image';
                                      final String url = item['url'] ?? '';

                                      return Card(
                                        color: Colors.grey[50],
                                        margin: const EdgeInsets.only(bottom: 12),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SegmentedButton<String>(
                                                    segments: const [
                                                      ButtonSegment<String>(
                                                        value: 'image',
                                                        label: Text('Surat'),
                                                        icon: Icon(Icons.image, size: 16),
                                                      ),
                                                      ButtonSegment<String>(
                                                        value: 'video',
                                                        label: Text('Wideo'),
                                                        icon: Icon(Icons.videocam, size: 16),
                                                      ),
                                                    ],
                                                    selected: {kind},
                                                    onSelectionChanged: (newSel) {
                                                      setModalState(() {
                                                        localMedia[idx]['kind'] = newSel.first;
                                                        localMedia[idx]['url'] = '';
                                                      });
                                                    },
                                                    style: SegmentedButton.styleFrom(
                                                      visualDensity: VisualDensity.compact,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.red),
                                                    onPressed: () {
                                                      setModalState(() {
                                                        localMedia.removeAt(idx);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => pickMediaFile(idx),
                                                      icon: const Icon(Icons.file_upload_outlined, size: 16),
                                                      label: Text(
                                                        url.isNotEmpty ? 'Täze faýl ýükle' : 'Faýl saýla',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white,
                                                        foregroundColor: Colors.black87,
                                                        elevation: 0,
                                                        side: BorderSide(color: Colors.grey[300]!),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (url.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (kind == 'video') {
                                                      _showVideoPlayer(_getMediaUrl(url));
                                                    } else {
                                                      _showFullScreenImage(_getMediaUrl(url));
                                                    }
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: kind == 'video'
                                                        ? Container(
                                                            height: 100,
                                                            color: Colors.black87,
                                                            child: const Center(
                                                              child: Icon(Icons.play_circle_filled, color: Colors.white, size: 40),
                                                            ),
                                                          )
                                                        : Image.network(
                                                            _getMediaUrl(url),
                                                            height: 100,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        // Actions Footer
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Bes et'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (titleController.text.isEmpty || contentController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Adyny we mazmunyny dolduryň!'), backgroundColor: Colors.orange),
                                    );
                                    return;
                                  }

                                  final payload = {
                                    'title': titleController.text,
                                    'content': contentController.text,
                                    'main_image': mainImageUrl,
                                    'date': dateController.text,
                                    'media': localMedia.where((m) => m['url'].toString().isNotEmpty).toList(),
                                  };

                                  try {
                                    if (isEdit) {
                                      await AdminService.updateBlog(blog['slug'], payload);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Makala täzelendi'), backgroundColor: Colors.green),
                                      );
                                    } else {
                                      await AdminService.createBlog(payload);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Täze makala goşuldy'), backgroundColor: Colors.green),
                                      );
                                    }
                                    Navigator.pop(context);
                                    _loadBlogs();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Makalany sakla'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Täzelikler', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBlogs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _blogs.isEmpty
                  ? const Center(child: Text('Blog tapylmady'))
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 82,
                      ),
                      itemCount: _blogs.length,
                      itemBuilder: (context, index) {
                        final blog = _blogs[index];
                        final String title = blog['title'] ?? '';
                        final String slug = blog['slug'] ?? '';
                        final String image = blog['main_image'] ?? blog['image'] ?? '';
                        final String date = blog['date'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: image.isNotEmpty
                                  ? Image.network(
                                      _getMediaUrl(image),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
                                    )
                                  : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Sene: $date\nSlug: $slug'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showBlogEditor(blog),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteBlog(slug),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showBlogEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Relative URLs (e.g. "/media/...") are resolved against mediaBaseUrl.
  /// Absolute URLs (http/https) are returned as-is.
  String _getMediaUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${Config.mediaBaseUrl}${url.startsWith('/') ? '' : '/'}$url';
  }

  void _showVideoPlayer(String url) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(url: url),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerDialog extends StatefulWidget {
  final String url;
  const VideoPlayerDialog({super.key, required this.url});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
        });
        _controller.play();
        // Auto-hide controls after 2s
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }).catchError((err) {
        if (!mounted) return;
        setState(() {
          _error = err.toString();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate display size based on actual video aspect ratio
    double videoAspect = _initialized ? _controller.value.aspectRatio : 16 / 9;
    bool isLandscape = videoAspect > 1.0;

    // For landscape video, use full screen width; for portrait use limited width
    double dialogWidth = isLandscape ? screenSize.width : screenSize.width * 0.85;
    double dialogHeight = dialogWidth / videoAspect;

    // Cap height at 80% of screen height
    if (dialogHeight > screenSize.height * 0.8) {
      dialogHeight = screenSize.height * 0.8;
      dialogWidth = dialogHeight * videoAspect;
    }

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: isLandscape
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLandscape ? 0 : 16)),
      child: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Area
            GestureDetector(
              onTap: _toggleControls,
              child: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    // Video or loading/error
                    if (_initialized)
                      FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Wideo ýüklenmedi:\n$_error',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: Colors.white)),

                    // Controls overlay
                    if (_initialized)
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Center(
                            child: IconButton(
                              iconSize: 64,
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                    // Close button always visible
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress bar
            if (_initialized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
