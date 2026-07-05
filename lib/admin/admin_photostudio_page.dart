import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../services/admin_service.dart';
import '../config.dart';

class AdminPhotoStudioPage extends StatefulWidget {
  const AdminPhotoStudioPage({super.key});

  @override
  State<AdminPhotoStudioPage> createState() => _AdminPhotoStudioPageState();
}

class _AdminPhotoStudioPageState extends State<AdminPhotoStudioPage> {
  bool _isLoading = true;
  String _tab = 'videos'; // 'videos' or 'images'
  String _searchQuery = '';
  List<dynamic> _videos = [];
  List<dynamic> _images = [];
  int _videosCount = 0;
  int _imagesCount = 0;
  int _videosPage = 1;
  int _imagesPage = 1;
  final int _pageSize = 10;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final vData = await AdminService.listStudioVideos(page: _videosPage, pageSize: _pageSize);
      final iData = await AdminService.listStudioImages(page: _imagesPage, pageSize: _pageSize);
      setState(() {
        _videos = vData['results'] ?? [];
        _videosCount = vData['count'] ?? 0;
        _images = iData['results'] ?? [];
        _imagesCount = iData['count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final vData = await AdminService.listStudioVideos(page: _videosPage, pageSize: _pageSize);
      setState(() {
        _videos = vData['results'] ?? [];
        _videosCount = vData['count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final iData = await AdminService.listStudioImages(page: _imagesPage, pageSize: _pageSize);
      setState(() {
        _images = iData['results'] ?? [];
        _imagesCount = iData['count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredVideos {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _videos;
    return _videos.where((v) {
      final title = (v['title'] ?? '').toString().toLowerCase();
      return title.contains(q);
    }).toList();
  }

  List<dynamic> get _filteredImages {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _images;
    return _images.where((img) {
      final title = (img['title'] ?? '').toString().toLowerCase();
      return title.contains(q);
    }).toList();
  }

  void _openCreate() {
    if (_tab == 'videos') {
      _showVideoFormDialog();
    } else {
      _showImageFormDialog();
    }
  }

  void _openEditVideo(dynamic video) {
    _showVideoFormDialog(video);
  }

  void _openEditImage(dynamic image) {
    _showImageFormDialog(image);
  }

  Future<void> _deleteVideo(dynamic video) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Tassyklaň'),
        content: const Text('Hakykatdanam pozmakçymy?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hawa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.deleteStudioVideo(video['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozuldy'), backgroundColor: Colors.green),
      );
      _loadVideos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteImage(dynamic image) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Tassyklaň'),
        content: const Text('Hakykatdanam pozmakçymy?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hawa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.deleteStudioImage(image['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozuldy'), backgroundColor: Colors.green),
      );
      _loadImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showVideoFormDialog([dynamic video]) {
    final bool isEdit = video != null;
    final titleController = TextEditingController(text: isEdit ? video['title'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? video['description'] ?? '' : '');

    PlatformFile? pickedThumbnailFile;
    PlatformFile? pickedVideoFile;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickThumbnail() async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedThumbnailFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat saýlap bolmady: $e'), backgroundColor: Colors.red),
                );
              }
            }

            Future<void> pickVideo() async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.video);
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedVideoFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wideo saýlap bolmady: $e'), backgroundColor: Colors.red),
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              title: Text(isEdit ? 'Wideo üýtgetmek' : 'Täze wideo goşmak', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Ady', hintText: 'Sözbaşy'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Thumbnail Surat (Görk) ”.jpg, .png”', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: pickedThumbnailFile != null
                                ? (pickedThumbnailFile!.bytes != null
                                    ? Image.memory(pickedThumbnailFile!.bytes!, fit: BoxFit.cover)
                                    : (pickedThumbnailFile!.path != null
                                        ? Image.network(pickedThumbnailFile!.path!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image))
                                        : const Icon(Icons.image)))
                                : (isEdit && video['thumbnail_image_url'] != null
                                    ? Image.network(_getMediaUrl(video['thumbnail_image_url']), fit: BoxFit.cover)
                                    : const Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: pickThumbnail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Surat saýlaň'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Wideo Faýl (.mp4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pickedVideoFile != null)
                          Text(pickedVideoFile!.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                        else if (isEdit && video['video_url'] != null)
                          const Text('Häzirki wideo ýüklenen', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))
                        else
                          const Text('Faýl saýlanmady', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: pickVideo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Wideo saýlaň'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Beýany',
                        hintText: 'Wideo barada...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Goýbolsun'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sözbaşy hökman'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (!isEdit && pickedVideoFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Wideo faýl saýlaň'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (!isEdit && pickedThumbnailFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thumbnail surat saýlaň'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            if (isEdit) {
                              await AdminService.updateStudioVideo(
                                id: video['id'],
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                videoPath: pickedVideoFile?.path,
                                videoBytes: pickedVideoFile?.bytes,
                                videoName: pickedVideoFile?.name,
                                thumbnailPath: pickedThumbnailFile?.path,
                                thumbnailBytes: pickedThumbnailFile?.bytes,
                                thumbnailName: pickedThumbnailFile?.name,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Wideo täzelendi'), backgroundColor: Colors.green),
                              );
                            } else {
                              await AdminService.createStudioVideo(
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                videoPath: pickedVideoFile?.path,
                                videoBytes: pickedVideoFile?.bytes,
                                videoName: pickedVideoFile?.name,
                                thumbnailPath: pickedThumbnailFile?.path,
                                thumbnailBytes: pickedThumbnailFile?.bytes,
                                thumbnailName: pickedThumbnailFile?.name,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Täze wideo goşuldy'), backgroundColor: Colors.green),
                              );
                            }
                            Navigator.pop(context);
                            _loadVideos();
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sakla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageFormDialog([dynamic image]) {
    final bool isEdit = image != null;
    final titleController = TextEditingController(text: isEdit ? image['title'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? image['description'] ?? '' : '');

    PlatformFile? pickedThumbnailFile;
    PlatformFile? pickedImageFile;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickThumbnail() async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedThumbnailFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat saýlap bolmady: $e'), backgroundColor: Colors.red),
                );
              }
            }

            Future<void> pickImage() async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedImageFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat saýlap bolmady: $e'), backgroundColor: Colors.red),
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              title: Text(isEdit ? 'Surat üýtgetmek' : 'Täze surat goşmak', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Ady', hintText: 'Sözbaşy'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Thumbnail Surat (Görk) ”.jpg, .png”', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: pickedThumbnailFile != null
                                ? (pickedThumbnailFile!.bytes != null
                                    ? Image.memory(pickedThumbnailFile!.bytes!, fit: BoxFit.cover)
                                    : (pickedThumbnailFile!.path != null
                                        ? Image.network(pickedThumbnailFile!.path!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image))
                                        : const Icon(Icons.image)))
                                : (isEdit && image['thumbnail_image_url'] != null
                                    ? Image.network(_getMediaUrl(image['thumbnail_image_url']), fit: BoxFit.cover)
                                    : const Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: pickThumbnail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Surat saýlaň'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Uly Surat Faýly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: pickedImageFile != null
                                ? (pickedImageFile!.bytes != null
                                    ? Image.memory(pickedImageFile!.bytes!, fit: BoxFit.cover)
                                    : (pickedImageFile!.path != null
                                        ? Image.network(pickedImageFile!.path!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image))
                                        : const Icon(Icons.image)))
                                : (isEdit && image['image_url'] != null
                                    ? Image.network(_getMediaUrl(image['image_url']), fit: BoxFit.cover)
                                    : const Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Surat saýlaň'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Beýany',
                        hintText: 'Surat barada...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Goýbolsun'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sözbaşy hökman'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (!isEdit && pickedImageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Surat faýl saýlaň'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (!isEdit && pickedThumbnailFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thumbnail surat saýlaň'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            if (isEdit) {
                              await AdminService.updateStudioImage(
                                id: image['id'],
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                imagePath: pickedImageFile?.path,
                                imageBytes: pickedImageFile?.bytes,
                                imageName: pickedImageFile?.name,
                                thumbnailPath: pickedThumbnailFile?.path,
                                thumbnailBytes: pickedThumbnailFile?.bytes,
                                thumbnailName: pickedThumbnailFile?.name,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Surat täzelendi'), backgroundColor: Colors.green),
                              );
                            } else {
                              await AdminService.createStudioImage(
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                imagePath: pickedImageFile?.path,
                                imageBytes: pickedImageFile?.bytes,
                                imageName: pickedImageFile?.name,
                                thumbnailPath: pickedThumbnailFile?.path,
                                thumbnailBytes: pickedThumbnailFile?.bytes,
                                thumbnailName: pickedThumbnailFile?.name,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Täze surat goşuldy'), backgroundColor: Colors.green),
                              );
                            }
                            Navigator.pop(context);
                            _loadImages();
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sakla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                  errorBuilder: (ctx, err, stack) => const Center(
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

  Widget _buildPaginationControls(String type, int totalPages) {
    final int currentPage = type == 'videos' ? _videosPage : _imagesPage;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      if (type == 'videos') {
                        _videosPage--;
                        _loadVideos();
                      } else {
                        _imagesPage--;
                        _loadImages();
                      }
                    });
                  }
                : null,
          ),
          Text(
            'Sahypa $currentPage / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      if (type == 'videos') {
                        _videosPage++;
                        _loadVideos();
                      } else {
                        _imagesPage++;
                        _loadImages();
                      }
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHlsStatusTag(String status) {
    Color bgColor;
    Color textColor;
    String displayStatus = status.isNotEmpty ? status : 'Garaşylýar';

    if (status == 'ready') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (status == 'processing') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else if (status == 'failed') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    } else {
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVideosList() {
    final vList = _filteredVideos;
    if (vList.isEmpty) {
      return const Center(child: Text('Wideo ýok', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)));
    }

    final totalPages = (_videosCount / _pageSize).ceil();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vList.length,
            itemBuilder: (context, index) {
              final v = vList[index];
              final int id = v['id'] ?? 0;
              final String title = v['title'] ?? '';
              final String desc = v['description'] ?? '';
              final String thumbUrl = v['thumbnail_image_url'] ?? '';
              final String hlsStatus = v['hls_status'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text('#$id', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (v['video_url'] != null && v['video_url'].toString().isNotEmpty) {
                            _showVideoPlayer(_getMediaUrl(v['video_url']));
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: thumbUrl.isNotEmpty
                                  ? Image.network(
                                      _getMediaUrl(thumbUrl),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 56,
                                        height: 56,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, size: 20),
                                      ),
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.video_file_outlined, size: 20),
                                    ),
                            ),
                            if (v['video_url'] != null && v['video_url'].toString().isNotEmpty)
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc.isNotEmpty ? desc : 'Beýan ýok',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildHlsStatusTag(hlsStatus),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _openEditVideo(v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _deleteVideo(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1) _buildPaginationControls('videos', totalPages),
      ],
    );
  }

  Widget _buildImagesList() {
    final imgList = _filteredImages;
    if (imgList.isEmpty) {
      return const Center(child: Text('Surat ýok', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)));
    }

    final totalPages = (_imagesCount / _pageSize).ceil();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: imgList.length,
            itemBuilder: (context, index) {
              final img = imgList[index];
              final int id = img['id'] ?? 0;
              final String title = img['title'] ?? '';
              final String desc = img['description'] ?? '';
              final String thumbUrl = img['thumbnail_image_url'] ?? img['image_url'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text('#$id', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          final mainUrl = img['image_url'] ?? img['thumbnail_image_url'] ?? '';
                          if (mainUrl.isNotEmpty) {
                            _showFullScreenImage(_getMediaUrl(mainUrl));
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: thumbUrl.isNotEmpty
                              ? Image.network(
                                  _getMediaUrl(thumbUrl),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, size: 20),
                                  ),
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.photo_outlined, size: 20),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc.isNotEmpty ? desc : 'Beýan ýok',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _openEditImage(img),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _deleteImage(img),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1) _buildPaginationControls('images', totalPages),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Foto Galereýa & Wideo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: 'videos',
                      label: Text('Wideolar ($_videosCount)'),
                      icon: const Icon(Icons.videocam_outlined),
                    ),
                    ButtonSegment<String>(
                      value: 'images',
                      label: Text('Suratlar ($_imagesCount)'),
                      icon: const Icon(Icons.photo_outlined),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _tab = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Colors.black,
                    selectedForegroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Gözleg...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadAll,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Goş', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: _loadAll, child: const Text('Täzeden synanyş')),
                          ],
                        ),
                      )
                    : _tab == 'videos'
                        ? _buildVideosList()
                        : _buildImagesList(),
          ),
        ],
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
    double videoAspect = _initialized ? _controller.value.aspectRatio : 16 / 9;
    bool isLandscape = videoAspect > 1.0;
    double dialogWidth = isLandscape ? screenSize.width : screenSize.width * 0.85;
    double dialogHeight = dialogWidth / videoAspect;

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
            GestureDetector(
              onTap: _toggleControls,
              child: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
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
