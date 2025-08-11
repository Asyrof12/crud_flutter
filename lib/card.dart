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

  // Controller untuk input form tambah kontak
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isAdding = false;

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
      print("🔍 Fetching from: $url");

      final response = await http.get(Uri.parse(url));

      print("📡 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

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
      isAdding = true;
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
        isAdding = false;
      });
    }
  }

  void showAddContactModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
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
              onPressed: isAdding
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      phoneController.clear();
                    },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isAdding
                  ? null
                  : () async {
                      await addPhone();
                    },
              child: isAdding
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
