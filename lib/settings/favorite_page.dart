import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritPage extends StatefulWidget {
  final String apiUrl;
  const FavoritPage({Key? key, required this.apiUrl}) : super(key: key);

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  // track id yang sedang diproses agar tidak double klik
  final Set<int> _pending = {};

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is bool) return v ? 1 : 0;
    return 0;
  }

  bool _isFav(Map<String, dynamic> item) => _toInt(item['is_favourite']) == 1;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      setState(() {
        isLoading = false;
        data = [];
      });
      return;
    }

    final url = "${widget.apiUrl}/phone-saved-by";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idUser": userId.toString()}),
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final allData = parsed is List ? parsed : (parsed['data'] ?? []);
      final list = List<Map<String, dynamic>>.from(allData);

      setState(() {
        // ambil hanya data yang favorit (tahan terhadap '1' atau 1)
        data = list.where(_isFav).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        data = [];
      });
    }
  }

  Future<void> _deleteContact(Map item) async {
    final id = _toInt(item['id']);

    try {
      final response = await http.post(
        Uri.parse("${widget.apiUrl}/delete"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        setState(() {
          data.removeWhere((c) => _toInt(c['id']) == id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Kontak ${item['name']} berhasil dihapus"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal hapus kontak (error ${response.statusCode})"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  void showDeleteConfirmDialog(Map item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Kontak"),
          content: Text("Yakin hapus ${item['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.microtask(() => _deleteContact(item));
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleUnfavourite(int id) async {
    if (_pending.contains(id)) return; // cegah double-tap
    setState(() => _pending.add(id));

    try {
      // NOTE: jika backend kamu pakai "/toggle-favourite", ganti baris di bawah ini.
      final url = "${widget.apiUrl}/favourite";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'is_favourite': 0}), // set 0 (unfav)
      );

      if (response.statusCode == 200) {
        setState(() {
          data.removeWhere((c) => _toInt(c['id']) == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dihapus dari favorit")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal update favorit (${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pending.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kontak Favorit")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Belum ada kontak favorit"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final id = _toInt(item['id']);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(item['name']?.toString() ?? "-"),
                        subtitle: Text(item['phone']?.toString() ?? "-"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              // LOVE icon (bukan star)
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: _pending.contains(id)
                                  ? null
                                  : () => _toggleUnfavourite(id),
                              tooltip: "Hapus dari favorit",
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
    );
  }
}
