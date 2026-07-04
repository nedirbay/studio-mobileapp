import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_service.dart';

class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  bool _isLoading = true;
  List<dynamic> _logs = [];
  List<dynamic> _filteredLogs = [];
  String? _error;

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedMethod = 'Hemmesi';
  String _selectedStatusGroup = 'Hemmesi';
  
  // Auto-refresh state
  bool _autoRefresh = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    if (!_autoRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final data = await AdminService.listLogs();
      setState(() {
        _logs = data;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _toggleAutoRefresh(bool? value) {
    if (value == null) return;
    setState(() {
      _autoRefresh = value;
    });
    _refreshTimer?.cancel();
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _loadLogs();
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    List<dynamic> temp = List.from(_logs);

    // 1. Text Search
    if (query.isNotEmpty) {
      temp = temp.where((log) {
        final user = (log['user'] ?? '').toString().toLowerCase();
        final path = (log['path'] ?? '').toString().toLowerCase();
        final method = (log['method'] ?? '').toString().toLowerCase();
        return user.contains(query) || path.contains(query) || method.contains(query);
      }).toList();
    }

    // 2. Method Filter
    if (_selectedMethod != 'Hemmesi') {
      temp = temp.where((log) {
        final m = (log['method'] ?? '').toString().toUpperCase();
        return m == _selectedMethod.toUpperCase();
      }).toList();
    }

    // 3. Status Group Filter
    if (_selectedStatusGroup != 'Hemmesi') {
      temp = temp.where((log) {
        final int status = int.tryParse(log['status']?.toString() ?? '0') ?? 0;
        if (_selectedStatusGroup == '2xx (Şowly)') {
          return status >= 200 && status < 300;
        } else if (_selectedStatusGroup == '4xx (Müşderi hatasy)') {
          return status >= 400 && status < 500;
        } else if (_selectedStatusGroup == '5xx (Serwer hatasy)') {
          return status >= 500;
        }
        return true;
      }).toList();
    }

    setState(() {
      _filteredLogs = temp;
    });
  }

  Future<void> _exportCSV() async {
    try {
      final csv = await AdminService.exportLogsCSV();
      await Clipboard.setData(ClipboardData(text: csv));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV maglumatlary göçürildi! Olary islendik ýere goýup bilersiňiz.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV eksport edilmedi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteSingleLog(dynamic log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log ýazgysyny pozmak'),
        content: const Text('Bu log ýazgysyny pozmak isleýärsiňizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Sakla')),
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
      await AdminService.deleteLogs({
        'action': 'delete_selected',
        'selected_logs': [log],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ýazgy pozuldy'), backgroundColor: Colors.green),
      );
      _loadLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ähli loglary pozmak'),
        content: const Text('Ähli log ýazgylaryny doly pozmak isleýärsiňizmi? Bu amaly yzyna gaýtaryp bolmaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ählisini poz'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.deleteLogs({'action': 'delete_all'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ähli ýazgylar pozuldy'), backgroundColor: Colors.green),
      );
      _loadLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteByDateRange() async {
    DateTime? startDate;
    DateTime? endDate;

    final pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Başlangyç senäni saýlaň',
    );

    if (pickedStart == null) return;
    startDate = pickedStart;

    if (!mounted) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2030),
      helpText: 'Ahyrky senäni saýlaň',
    );

    if (pickedEnd == null) return;
    endDate = pickedEnd;

    final startStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final endStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sene boýunça pozmak'),
        content: Text('$startStr we $endStr seneleri aralygyndaky ähli loglary pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteLogs({
        'action': 'delete_by_date',
        'start_date': startStr,
        'end_date': endStr,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sene aralygyndaky ýazgylar pozuldy'), backgroundColor: Colors.green),
      );
      _loadLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogDetail(dynamic log) {
    showDialog(
      context: context,
      builder: (context) {
        final timestamp = log['timestamp'] ?? 'Bilinmeýär';
        final duration = log['duration'] ?? 'Bilinmeýär';
        final user = log['user'] ?? 'Anonymous';
        final method = (log['method'] ?? 'GET').toString().toUpperCase();
        final path = log['path'] ?? '/';
        final status = log['status']?.toString() ?? '200';

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Log maglumaty', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailItem('Hasaba alnan wagty', timestamp, Icons.access_time_rounded),
                const SizedBox(height: 12),
                _detailItem('Işleme möhleti', duration, Icons.timer_outlined),
                const SizedBox(height: 12),
                _detailItem('Gatnaşyjy ulanyjy', user, Icons.person_outline),
                const SizedBox(height: 12),
                _detailBadgeItem('Hereket / Metod', method, _getMethodColor(method)),
                const SizedBox(height: 12),
                _detailBadgeItem('Jogap statusy', status, _getStatusColor(status)),
                const SizedBox(height: 16),
                const Text('API Sorag ýoly (Path)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: SelectableText(
                    path,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: path));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API ýoly göçürildi!'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Ýoly göçür'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailBadgeItem(String label, String value, Color color) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getMethodColor(String method) {
    final m = method.toUpperCase();
    if (m == 'POST') return Colors.green;
    if (m == 'PUT' || m == 'PATCH') return Colors.orange;
    if (m == 'DELETE') return Colors.red;
    return Colors.blue;
  }

  Color _getStatusColor(String statusStr) {
    final s = int.tryParse(statusStr) ?? 200;
    if (s >= 200 && s < 300) return Colors.green;
    if (s >= 400 && s < 500) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ulgam loglary',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            Text(
              'GET bolmadyk API ýüzlenmeleriniň ýazgylary',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadLogs,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'csv') {
                _exportCSV();
              } else if (value == 'date') {
                _deleteByDateRange();
              } else if (value == 'all') {
                _deleteAllLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, color: Colors.green),
                    SizedBox(width: 10),
                    Text('CSV Göçürip al'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Sene boýunça poz'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Ählisini arassala'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ulanyjy ady ýa-da API ýoly...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Method filter dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMethod,
                            isExpanded: true,
                            hint: const Text('Metod'),
                            items: ['Hemmesi', 'GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map((String m) {
                              return DropdownMenuItem<String>(
                                value: m,
                                child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedMethod = val);
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status filter dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatusGroup,
                            isExpanded: true,
                            hint: const Text('Status'),
                            items: ['Hemmesi', '2xx (Şowly)', '4xx (Müşderi hatasy)', '5xx (Serwer hatasy)'].map((String s) {
                              return DropdownMenuItem<String>(
                                value: s,
                                child: Text(
                                  s, 
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStatusGroup = val);
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Auto refresh option row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Awto-täzelemek (10 sekunt)',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Switch.adaptive(
                      value: _autoRefresh,
                      onChanged: _toggleAutoRefresh,
                      activeColor: const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Logs list area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadLogs,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Gaýtadan synanyş'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredLogs.isEmpty
                        ? const Center(child: Text('Gözlege laýyk log ýazgysy tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            itemCount: _filteredLogs.length,
                            itemBuilder: (context, index) {
                              final log = _filteredLogs[index];
                              final timestamp = log['timestamp'] ?? '';
                              final user = log['user'] ?? 'Anonymous';
                              final method = (log['method'] ?? 'GET').toString().toUpperCase();
                              final path = log['path'] ?? '/';
                              final status = log['status']?.toString() ?? '200';

                              final methodColor = _getMethodColor(method);
                              final statusColor = _getStatusColor(status);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                elevation: 0,
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () => _showLogDetail(log),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header row: timestamp & delete button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time_rounded, color: Colors.grey, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  timestamp,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                              onPressed: () => _deleteSingleLog(log),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Badges row
                                        Row(
                                          children: [
                                            // Method Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: methodColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                method,
                                                style: TextStyle(
                                                  color: methodColor,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Status Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // User
                                            const Icon(Icons.person_outline, color: Colors.grey, size: 14),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                user,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: user == 'Anonymous' ? Colors.grey : Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Path
                                        Text(
                                          path,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
