import 'package:flutter/material.dart';
import 'package:card/settings/hamburger.dart';
import 'package:card/menu_setting/keamanan.dart';

class MySetting extends StatelessWidget {
  final String username;
  final String phone;

  const MySetting({
    super.key,
    required this.username,
    required this.phone,
  });

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
          // Menu Akun
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Akun'),
              subtitle: const Text('Info akun Anda'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Info Akun'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: $username'),
                          const SizedBox(height: 8),
                          Text('Phone: $phone'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Menu Notifikasi
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text('Notifikasi'),
              subtitle: const Text('Pengaturan notifikasi'),
              onTap: () {},
            ),
          ),

          // Menu Keamanan
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orange),
              title: const Text('Keamanan'),
              subtitle: const Text('Pengaturan keamanan aplikasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KeamananPage()),
                );
              },
            ),
          ),

          // Menu Bahasa
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.purple),
              title: const Text('Bahasa'),
              subtitle: const Text('Pengaturan bahasa aplikasi'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String selectedLanguage = 'English';
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Pilih Bahasa'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                title: const Text('Indonesia'),
                                value: 'Indonesia',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('English'),
                                value: 'English',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          selectedLanguage == 'English'
                                              ? 'Language changed to English'
                                              : 'Bahasa diubah ke Indonesia')),
                                );
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Menu Bantuan
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.red),
              title: const Text('Bantuan'),
              subtitle: const Text('Dapatkan bantuan dan dukungan'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
