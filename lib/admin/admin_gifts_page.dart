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
    final subtitleController = TextEditingController(text: isEdit ? campaign['subtitle'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? campaign['description'] ?? '' : '');
    final prizeTitleController = TextEditingController(text: isEdit ? campaign['prize_title'] ?? '' : '');
    final prizeValueController = TextEditingController(text: isEdit ? (campaign['prize_value'] ?? '0').toString() : '0');
    final discountPercentController = TextEditingController(text: isEdit ? (campaign['discount_percent'] ?? '0').toString() : '0');
    final promoCodeController = TextEditingController(text: isEdit ? campaign['promo_code'] ?? '' : '');
    final rulesController = TextEditingController(text: isEdit ? campaign['rules'] ?? '' : '');
    final imageUrlController = TextEditingController(text: isEdit ? campaign['image_url'] ?? '' : '');
    final bannerUrlController = TextEditingController(text: isEdit ? campaign['banner_url'] ?? '' : '');
    final bgGradientController = TextEditingController(text: isEdit ? campaign['bg_gradient'] ?? 'from-red-600 to-orange-500' : 'from-red-600 to-orange-500');
    final startsAtController = TextEditingController(text: isEdit ? (campaign['starts_at'] ?? '') : '');
    final endsAtController = TextEditingController(text: isEdit ? (campaign['ends_at'] ?? '') : '');

    String type = isEdit ? campaign['type'] ?? 'giveaway' : 'giveaway';
    String status = isEdit ? campaign['status'] ?? 'active' : 'active';
    bool isFeatured = isEdit ? (campaign['is_featured'] == true || campaign['is_featured'] == 1) : false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> selectDateTime(TextEditingController controller) async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date == null) return;

              if (!context.mounted) return;

              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time == null) return;

              final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              setModalState(() {
                controller.text = dateTime.toUtc().toIso8601String().replaceAll('.000', '');
              });
            }

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
                      isEdit ? 'Aksiýany üýtgetmek' : 'Täze aksiýa / sowgat goşmak',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Aksiýanyň görnüşi', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'giveaway', child: Text('Bäsleşikler / Giveaway')),
                        DropdownMenuItem(value: 'promotion', child: Text('Aksiýalar')),
                        DropdownMenuItem(value: 'gift', child: Text('Sowgatlar')),
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
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Aksiýa statusy', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('Garaşylýar (Draft)')),
                        DropdownMenuItem(value: 'active', child: Text('Işjeň (Active)')),
                        DropdownMenuItem(value: 'finished', child: Text('Tamamlandy (Finished)')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Ýatyryldy (Cancelled)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            status = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Aksiýanyň ady', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Gysga düşündiriş (Subtitle)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: startsAtController,
                      readOnly: true,
                      onTap: () => selectDateTime(startsAtController),
                      decoration: const InputDecoration(
                        labelText: 'Başlanýan wagty',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: endsAtController,
                      readOnly: true,
                      onTap: () => selectDateTime(endsAtController),
                      decoration: InputDecoration(
                        labelText: 'Tamamlanýan wagty (goýulmasa möhletsiz)',
                        border: const OutlineInputBorder(),
                        suffixIcon: endsAtController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setModalState(() {
                                    endsAtController.clear();
                                  });
                                },
                              )
                            : const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: prizeTitleController,
                      decoration: const InputDecoration(labelText: 'Sowgadyň ady (Prize)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: prizeValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sowgat bahasy (TMT)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: discountPercentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Arzanladyş göterimi (%)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: promoCodeController,
                      decoration: const InputDecoration(labelText: 'Promo Kod', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: rulesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Aksiýanyň şertleri (Her setirde ýekeje şert)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Giňişleýin maglumat (Description)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Surat URL (Image)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bannerUrlController,
                      decoration: const InputDecoration(labelText: 'Banner Surat URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bgGradientController,
                      decoration: const InputDecoration(labelText: 'Arka tarapyň reňkleri (bg_gradient)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Baş sahypada tapawutly görkez', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isFeatured,
                          activeColor: const Color(0xFFDC2626),
                          onChanged: (val) {
                            setModalState(() {
                              isFeatured = val;
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
                              const SnackBar(content: Text('Aksiýanyň ady hökmanydyr'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (startsAtController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Başlanýan wagty hökmanydyr'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          final payload = {
                            'type': type,
                            'status': status,
                            'title': titleController.text,
                            'subtitle': subtitleController.text,
                            'starts_at': startsAtController.text,
                            'ends_at': endsAtController.text.isNotEmpty ? endsAtController.text : null,
                            'prize_title': prizeTitleController.text,
                            'prize_value': double.tryParse(prizeValueController.text) ?? 0.0,
                            'discount_percent': int.tryParse(discountPercentController.text) ?? 0,
                            'promo_code': promoCodeController.text,
                            'rules': rulesController.text,
                            'description': descController.text,
                            'image_url': imageUrlController.text,
                            'banner_url': bannerUrlController.text,
                            'bg_gradient': bgGradientController.text,
                            'is_featured': isFeatured,
                          };

                          try {
                            if (isEdit) {
                              await AdminService.updateCampaign(campaign['id'], payload);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aksiýa üstünlikli täzelendi'), backgroundColor: Colors.green),
                              );
                            } else {
                              await AdminService.createCampaign(payload);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Täze aksiýa üstünlikli döredildi'), backgroundColor: Colors.green),
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
                        child: const Text('Sakla'),
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
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 82,
                      ),
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
                                      'Sene: ${campaign['starts_at'] != null ? campaign['starts_at'].toString().split('T')[0] : ''} - ${campaign['ends_at'] != null ? campaign['ends_at'].toString().split('T')[0] : 'Möhletsiz'}',
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
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                      ),
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
