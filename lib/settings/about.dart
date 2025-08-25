import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card/settings/hamburger.dart';
import '../providers/AppLanguage.dart';
import 'package:card/utils/lang.dart'; // file Lang kamu

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context); // ambil bahasa aktif
    final lang = Lang.texts[appLanguage.currentLang]!; // ambil teks sesuai bahasa
    
    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: Text(lang['about']!), // <-- sudah multi-language
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: Text(lang['Aplikasi Kontak']!), // Nama Aplikasi
              subtitle: const Text('Aplikasi Kontak'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: Text(lang['version']!),
              subtitle: const Text('1.0.0'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: Text(lang['developer']!),
              subtitle: const Text('SMKN 1 Pasuruan'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: Text(lang['kontak']!),
              subtitle: const Text('skensa@gmail.com'),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '© 2025 Magang DMC. All rights reserved.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
