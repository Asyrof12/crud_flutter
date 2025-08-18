import 'package:flutter/material.dart';
import 'package:card/settings/hamburger.dart';

class MySetting extends StatelessWidget {
  const MySetting({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: const Text("Setting"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Akun'),
              subtitle: const Text('Pengaturan akun Anda'),
              onTap: () {
                // Aksi ketika menu Akun ditekan
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text('Notifikasi'),
              subtitle: const Text('Pengaturan notifikasi'),
              onTap: () {
                // Aksi ketika menu Notifikasi ditekan
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orange),
              title: const Text('Keamanan'),
              subtitle: const Text('Pengaturan keamanan aplikasi'),
              onTap: () {
                // Aksi ketika menu Keamanan ditekan
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.purple),
              title: const Text('Bahasa'),
              subtitle: const Text('Pengaturan bahasa aplikasi'),
              onTap: () {
                // Aksi ketika menu Bahasa ditekan
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.red),
              title: const Text('Bantuan'),
              subtitle: const Text('Dapatkan bantuan dan dukungan'),
              onTap: () {
                // Aksi ketika menu Bantuan ditekan
              },
            ),
          ),
        ],
      )
    );
  }
}