import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminGiftsPage extends StatefulWidget {
  const AdminGiftsPage({super.key});

  @override
  State<AdminGiftsPage> createState() => _AdminGiftsPageState();
}

class _AdminGiftsPageState extends State<AdminGiftsPage> {
  bool _isLoading = true;
  List<dynamic> _campaigns = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCampaigns();
      setState(() {
        _campaigns = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCampaign(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aksiýany pozmak'),
        content: const Text('Hakykatdan hem bu aksiýany pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCampaign(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aksiýa pozuldy'), backgroundColor: Colors.green),
      );
      _loadCampaigns();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showCampaignEditor([dynamic campaign]) {
    final bool isEdit = campaign != null;
    final titleController = TextEditingController(text: isEdit ? campaign['title'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? campaign['description'] ?? '' : '');
    final rulesController = TextEditingController(text: isEdit ? campaign['rules'] ?? '' : '');
    final imageController = TextEditingController(text: isEdit ? campaign['image'] ?? '' : '');
    final startController = TextEditingController(text: isEdit ? (campaign['start_date'] ?? '').toString().split('T')[0] : '');
    final endController = TextEditingController(text: isEdit ? (campaign['end_date'] ?? '').toString().split('T')[0] : '');

    String type = isEdit ? campaign['type'] ?? 'giveaway' : 'giveaway';
    bool isActive = isEdit ? (campaign['is_active'] == true || campaign['is_active'] == 1) : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Aksiýany üýtgetmek' : 'Täze aksiýa / sowgat',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Aksiýa ady', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Düşündiriş', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: rulesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Düzgünler', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Surat URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startController,
                            decoration: const InputDecoration(labelText: 'Başlanýan senesi (YYYY-MM-DD)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endController,
                            decoration: const InputDecoration(labelText: 'Gutarýan senesi (YYYY-MM-DD)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Görnüşi (Type)', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'giveaway', child: Text('Giveaway / Utuşly bäsleşik')),
                        DropdownMenuItem(value: 'promotion', child: Text('Promotion / Arzanlaşyk')),
                        DropdownMenuItem(value: 'gift', child: Text('Gift / Sowgat')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            type = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Işjeň (Active)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Switch(
                          value: isActive,
                          activeColor: const Color(0xFFDC2626),
                          onChanged: (val) {
                            setModalState(() {
                              isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sözbaşy hökman doldurylmaly'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          final payload = {
                            'title': titleController.text,
                            'description': descController.text.isNotEmpty ? descController.text : null,
                            'rules': rulesController.text.isNotEmpty ? rulesController.text : null,
                            'image': imageController.text.isNotEmpty ? imageController.text : null,
                            'start_date': startController.text.isNotEmpty ? '${startController.text}T00:00:00Z' : null,
                            'end_date': endController.text.isNotEmpty ? '${endController.text}T00:00:00Z' : null,
                            'type': type,
                            'is_active': isActive,
                          };

                          try {
                            if (isEdit) {
                              await AdminService.updateCampaign(campaign['id'], payload);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aksiýa täzelendi'), backgroundColor: Colors.green),
                              );
                            } else {
                              await AdminService.createCampaign(payload);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Täze aksiýa döredildi'), backgroundColor: Colors.green),
                              );
                            }
                            Navigator.pop(context);
                            _loadCampaigns();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                        child: const Text('Ýatda sakla'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showParticipants(dynamic campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCampaignParticipantsPage(
          campaignId: campaign['id'],
          campaignTitle: campaign['title'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Aksiýalar & Sowgatlar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCampaigns),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _campaigns.isEmpty
                  ? const Center(child: Text('Aksiýa tapylmady'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = _campaigns[index];
                        final int id = campaign['id'] ?? 0;
                        final String title = campaign['title'] ?? '';
                        final String desc = campaign['description'] ?? '';
                        final String type = campaign['type'] ?? 'giveaway';
                        final bool active = campaign['is_active'] == true || campaign['is_active'] == 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: type == 'giveaway' ? Colors.purple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: TextStyle(
                                          color: type == 'giveaway' ? Colors.purple : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.people_alt_outlined, color: Colors.teal),
                                          onPressed: () => _showParticipants(campaign),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                          onPressed: () => _showCampaignEditor(campaign),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _deleteCampaign(id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      active ? 'Işjeň' : 'Işjeň däl',
                                      style: TextStyle(color: active ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Sene: ${campaign['start_date'] != null ? campaign['start_date'].toString().split('T')[0] : ''} - ${campaign['end_date'] != null ? campaign['end_date'].toString().split('T')[0] : ''}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
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
        onPressed: () => _showCampaignEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AdminCampaignParticipantsPage extends StatefulWidget {
  final int campaignId;
  final String campaignTitle;

  const AdminCampaignParticipantsPage({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<AdminCampaignParticipantsPage> createState() => _AdminCampaignParticipantsPageState();
}

class _AdminCampaignParticipantsPageState extends State<AdminCampaignParticipantsPage> {
  bool _isLoading = true;
  List<dynamic> _participants = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCampaignParticipants(widget.campaignId);
      setState(() {
        _participants = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await AdminService.updateParticipantStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gatnaşyjy statusy ${status == "approved" ? "tassyklandy" : "ret edildi"}'), backgroundColor: Colors.green),
      );
      _loadParticipants();
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
        title: Text(widget.campaignTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadParticipants),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _participants.isEmpty
                  ? const Center(child: Text('Gatnaşyjy ýok'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final p = _participants[index];
                        final int id = p['id'] ?? 0;
                        final String name = p['full_name'] ?? 'Ulanyjy';
                        final String phone = p['phone'] ?? '';
                        final String note = p['note'] ?? '';
                        final String status = p['status'] ?? 'pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: status == 'approved'
                                            ? Colors.green.withOpacity(0.1)
                                            : status == 'rejected'
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status == 'approved'
                                            ? 'Tassyklandy'
                                            : status == 'rejected'
                                                ? 'Ret edildi'
                                                : 'Garaşylýar',
                                        style: TextStyle(
                                          color: status == 'approved'
                                              ? Colors.green
                                              : status == 'rejected'
                                                  ? Colors.red
                                                  : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Telefon: $phone', style: TextStyle(color: Colors.grey[600])),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text('Bellik: $note', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                ],
                                if (status == 'pending') ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(id, 'approved'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Tassykla'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(id, 'rejected'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Ret et'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
