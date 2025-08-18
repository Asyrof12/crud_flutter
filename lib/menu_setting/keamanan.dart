import 'package:flutter/material.dart';

class KeamananPage extends StatelessWidget {
  const KeamananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Pengaturan Keamanan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.blue),
              title: const Text('Ubah Kata Sandi'),
              subtitle: const Text('Ganti kata sandi akun Anda'),
              onTap: () {
                // Aksi ketika menu Ubah Kata Sandi ditekan
                showDialog(
                  context: context,
                  builder: (context) {
                    final oldPasswordController = TextEditingController();
                    final newPasswordController = TextEditingController();
                    final confirmPasswordController = TextEditingController();

                    return AlertDialog(
                      title: const Text('Ganti Kata Sandi'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: oldPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password Lama',
                              ),
                            ),
                            TextField(
                              controller: newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password Baru',
                              ),
                            ),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Konfirmasi Password Baru',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // tutup dialog
                          },
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // validasi sederhana dulu
                            if (newPasswordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Password baru tidak cocok!')),
                              );
                            } else {
                              // nanti nanti bisa sambung ke API
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Password berhasil diganti (dummy)')),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Ganti'),
                        ),
                      ],
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
              leading: const Icon(Icons.fingerprint, color: Colors.green),
              title: const Text('Autentikasi Biometrik'),
              subtitle: const Text('Aktifkan autentikasi biometrik'),
              onTap: () {
                // Aksi ketika menu Autentikasi Biometrik ditekan
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Autentikasi Biometrik'),
                    content: const Text(
                        'Aktifkan autentikasi biometrik pada akun Anda?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // update status biometrik dummy
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Biometrik diaktifkan (dummy)')),
                          );
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orange),
              title: const Text('Keamanan Akun'),
              subtitle: const Text('Pengaturan keamanan akun Anda'),
              onTap: () {
                // Aksi ketika menu Keamanan Akun ditekan
              },
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.purple),
              title: const Text('Privasi'),
              subtitle: const Text('Pengaturan privasi aplikasi'),
              onTap: () {
                // Aksi ketika menu Privasi ditekan
              },
            ),
          ),
        ],
      ),
    );
  }
}
