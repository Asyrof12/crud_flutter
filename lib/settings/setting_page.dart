import 'package:flutter/material.dart';
import 'package:card/settings/hamburger.dart';
import 'package:card/menu_setting/keamanan.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KeamananPage()),
                  );
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      String selectedLanguage = 'English'; // default
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
                                selectedLanguage = value!;
                                Navigator.pop(
                                    context); // tutup dialog sementara
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Bahasa diubah ke Indonesia')),
                                );
                              },
                            ),
                            RadioListTile(
                              title: const Text('English'),
                              value: 'English',
                              groupValue: selectedLanguage,
                              onChanged: (value) {
                                selectedLanguage = value!;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Language changed to English')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
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
        ));
  }
}
