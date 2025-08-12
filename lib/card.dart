import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyCard extends StatefulWidget {
  final String apiUrl;
  const MyCard({super.key, required this.apiUrl});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  List data = [];
  bool isLoading = true;
  String? errorMessage;

  // Controller untuk input form tambah & edit kontak
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isAddingOrEditing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = "${widget.apiUrl}/list";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed is List) {
          setState(() {
            data = parsed;
            isLoading = false;
            errorMessage = null;
          });
        } else if (parsed is Map && parsed['data'] is List) {
          setState(() {
            data = parsed['data'];
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            errorMessage = "Data tidak dalam format list";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Gagal load data (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  Future<void> addPhone() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan nomor harus diisi')),
      );
      return;
    }

    setState(() {
      isAddingOrEditing = true;
    });

    try {
      final url = "${widget.apiUrl}/add-phone";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil tambah kontak')),
        );
        nameController.clear();
        phoneController.clear();
        Navigator.of(context).pop(); // tutup modal
        fetchData(); // reload data kontak
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal tambah kontak (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isAddingOrEditing = false;
      });
    }
  }

  void showAddContactModal() {
    nameController.clear();
    phoneController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kontak'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      phoneController.clear();
                    },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () async {
                      await addPhone();
                    },
              child: isAddingOrEditing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void showEditContactModal(Map contact) {
    nameController.text = contact['name'] ?? '';
    phoneController.text = contact['phone'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Kontak'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      phoneController.clear();
                    },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isAddingOrEditing
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fungsi update belum dibuat')),
                      );
                      nameController.clear();
                      phoneController.clear();
                    },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmDialog(Map contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus kontak "${contact['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Nanti tambahkan fungsi delete API di sini
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fungsi hapus belum dibuat')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Kontak")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(item['name'] ?? 'Tanpa Nama'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['phone'] ?? 'Tidak ada nomor'),
                            const SizedBox(height: 4),
                            Text(
                              "Created: ${formatDate(item['created_at'])}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showEditContactModal(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDeleteConfirmDialog(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContactModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
