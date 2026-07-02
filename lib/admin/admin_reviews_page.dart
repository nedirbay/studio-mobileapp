import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  bool _isLoading = true;
  List<dynamic> _reviews = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listReviews();
      setState(() {
        _reviews = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReview(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teswiri pozmak'),
        content: const Text('Hakykatdan hem bu teswiri pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteReview(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teswir pozuldy'), backgroundColor: Colors.green),
      );
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleReadStatus(int id, bool currentStatus) async {
    try {
      await AdminService.updateReviewReadStatus(id, !currentStatus);
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Haryt Teswirleri', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReviews),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _reviews.isEmpty
                  ? const Center(child: Text('Teswir tapylmady'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final r = _reviews[index];
                        final int id = r['id'] ?? 0;
                        final String user = r['user'] != null ? r['user']['username'] ?? 'Ulanyjy' : 'Nomalym';
                        final String pName = r['product_details'] != null ? r['product_details']['name'] ?? 'Haryt' : 'Haryt';
                        final String text = r['comment'] ?? '';
                        final int rating = int.tryParse(r['rating']?.toString() ?? '5') ?? 5;
                        final bool isRead = r['is_read'] == true || r['is_read'] == 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isRead ? Colors.white : const Color(0xFFFEF2F2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFFFCA5A5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text('Haryt: $pName', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                                            color: isRead ? Colors.grey : const Color(0xFFDC2626),
                                          ),
                                          onPressed: () => _toggleReadStatus(id, isRead),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _deleteReview(id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(text, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
