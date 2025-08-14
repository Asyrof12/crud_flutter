import 'package:flutter/material.dart';
import 'package:card/settings/hamburger.dart';
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: const Text("About Aplikasi"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Nama Aplikasi'),
              subtitle: const Text('Aplikasi Kontak'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: const Text('Versi'),
              subtitle: const Text('1.0.0'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: const Text('Dikembangkan oleh'),
              subtitle: const Text('SMKN 1 Pasuruan'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Kontak'),
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
