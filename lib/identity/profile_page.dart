import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle logout
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ulanyjy Ady',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('user@example.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildProfileItem(Icons.shopping_bag_outlined, 'Meniň sargytlarym'),
            _buildProfileItem(Icons.favorite_outline, 'Halanlarym'),
            _buildProfileItem(Icons.settings_outlined, 'Sazlamalar'),
            _buildProfileItem(Icons.help_outline, 'Kömek'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {},
      ),
    );
  }
}
