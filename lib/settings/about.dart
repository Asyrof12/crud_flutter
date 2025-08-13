import 'package:flutter/material.dart';
import 'package:card/card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () async {
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                final selected = await showMenu<String>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  items: [
                    const PopupMenuItem(
                      value: 'contacts',
                      child: Row(
                        children: [
                          Icon(Icons.contacts, size: 20),
                          SizedBox(width: 8),
                          Text('Daftar Kontak'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('About Aplikasi'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20),
                          SizedBox(width: 8),
                          Text('Setting'),
                        ],
                      ),
                    ),
                  ],
                );

                if (selected != null) {
                  if (selected == 'contacts') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyCard(apiUrl: dotenv.env['API_URL'] ?? ''),
                      ),
                    );
                  } else if (selected == 'about') {
                    // sudah di halaman ini
                  } else if (selected == 'settings') {
                    print('Buka Setting');
                  }
                }
              },
            );
          },
        ),
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
              subtitle: const Text('Aplikasi Kontak Sederhana'),
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
              subtitle: const Text('Nama Developer'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Kontak'),
              subtitle: const Text('email@example.com'),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '© 2025 Nama Developer. All rights reserved.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
