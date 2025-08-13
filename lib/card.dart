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
      final url = "${widget.apiUrl}/list-all";
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

  Future<void> editPhone(String id) async {
    final idController = TextEditingController(text: id);
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
      final url = "${widget.apiUrl}/edit"; // endpoint API edit
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'phone': phone}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil edit kontak')),
        );
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal edit (${response.statusCode})')),
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

  Future<void> deletePhone(int id) async {
  try {
    final response = await http.post(
      Uri.parse("${widget.apiUrl}/delete"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus'),
        backgroundColor: Colors.red,),
      );
      await fetchData(); // refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus (${response.statusCode})'),
        backgroundColor: const Color.fromARGB(255, 71, 71, 71),),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  void showAddContactModal() {
  final localNameController = TextEditingController();
  final localPhoneController = TextEditingController();
  final scaffoldContext = context; // context Scaffold utama

  showDialog(
    context: scaffoldContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      bool isAdding = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Kontak'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: localNameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: localPhoneController,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isAdding ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isAdding
                    ? null
                    : () async {
                        final name = localNameController.text.trim();
                        final phone = localPhoneController.text.trim();

                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            const SnackBar(content: Text('Nama dan nomor harus diisi')),
                          );
                          return;
                        }

                        setState(() => isAdding = true);

                        try {
                          final url = "${widget.apiUrl}/add-phone";
                          final response = await http.post(
                            Uri.parse(url),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'name': name, 'phone': phone}),
                          );

                          if (response.statusCode == 200 || response.statusCode == 201) {
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              const SnackBar(content: Text('Berhasil tambah kontak')),
                            );
                            Navigator.of(dialogContext).pop();
                            fetchData();
                          } else {
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(content: Text('Gagal tambah kontak (${response.statusCode})')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() => isAdding = false);
                        }
                      },
                child: isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tambah'),
              ),
            ],
          );
        },
      );
    },
  );
}

  void showEditContactModal(Map contact) {
  nameController.text = contact['name'] ?? '';
  phoneController.text = contact['phone'] ?? '';
  final idController =
      TextEditingController(text: contact['id']?.toString() ?? '');

  final rootContext = context; // context Scaffold utama

  showDialog(
    context: rootContext, // pakai rootContext, bukan context biasa
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Edit Kontak'),
            Text(
              idController.text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
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
                    Navigator.of(dialogContext).pop();
                    nameController.clear();
                    phoneController.clear();
                  },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: isAddingOrEditing
                ? null
                : () async {
                    Navigator.of(dialogContext).pop(); // tutup dialog dulu
                    await editPhone(idController.text);
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(content: Text('Kontak berhasil diubah')),
                    );
                  },
            child: isAddingOrEditing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Simpan'),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await deletePhone(int.parse(contact['id'].toString()));
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