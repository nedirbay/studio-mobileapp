import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';
  String _selectedRole = '';
  String? _error;

  final List<String> _roles = ['', 'Admin', 'Customer', 'Staff'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listUsers(search: _searchQuery, role: _selectedRole);
      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ulanyjyny pozmak'),
        content: const Text('Bu ulanyjyny pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteUser(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulanyjy pozuldy'), backgroundColor: Colors.green),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showUserEditor([dynamic user]) {
    final bool isEdit = user != null;
    final nameController = TextEditingController(text: isEdit ? user['username'] ?? '' : '');
    final emailController = TextEditingController(text: isEdit ? user['email'] ?? '' : '');
    final passController = TextEditingController();
    String role = isEdit ? user['role_name'] ?? 'Customer' : 'Customer';
    bool isActive = isEdit ? (user['is_active'] == true || user['is_active'] == 1) : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ulanyjy maglumatlary' : 'Täze ulanyjy goşmak'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Ulanyjy ady'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email salgysy'),
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: passController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Paroly'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Roly'),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Customer', child: Text('Müşderi (Customer)')),
                        DropdownMenuItem(value: 'Staff', child: Text('Işgär (Staff)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            role = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Işjeň status'),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            setModalState(() {
                              isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty || (!isEdit && passController.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doldurylmadyk öýjükler bar'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    final payload = {
                      'username': nameController.text,
                      'email': emailController.text,
                      'role_name': role,
                      'is_active': isActive,
                      if (!isEdit) 'password': passController.text,
                    };

                    try {
                      if (isEdit) {
                        await AdminService.updateUser(user['id'], payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ulanyjy täzelendi'), backgroundColor: Colors.green),
                        );
                      } else {
                        await AdminService.createUser(payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Täze ulanyjy döredildi'), backgroundColor: Colors.green),
                        );
                      }
                      Navigator.pop(context);
                      _loadUsers();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Ýatda sakla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Ulanyjylar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Gözle...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (val) {
                      _searchQuery = val;
                      _loadUsers();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      hint: const Text('Roly'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Ählisi')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                        DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedRole = val ?? '';
                          _loadUsers();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _users.isEmpty
                        ? const Center(child: Text('Ulanyjy tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final u = _users[index];
                              final int id = u['id'] ?? 0;
                              final String username = u['username'] ?? '';
                              final String email = u['email'] ?? '';
                              final String roleName = u['role_name'] ?? 'Müşderi';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: ListTile(
                                  title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('$email\nRoly: $roleName'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showUserEditor(u),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteUser(id),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showUserEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
