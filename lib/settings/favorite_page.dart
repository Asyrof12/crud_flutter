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
  List data = [];
  List<String> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    final userId = prefs.getInt('id');

    if (userId == null) {
      setState(() {
        isLoading = false;
        data = [];
      });
      return;
    }

    final url = "${widget.apiUrl}/list-all?saved_by=$userId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final allData = parsed is List ? parsed : (parsed['data'] ?? []);
      setState(() {
        favorites = favs;
        data = allData
            .where((item) => favs.contains(item['id'].toString()))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        data = [];
      });
    }
  }

  /// toggle favorite
  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
        data.removeWhere((item) => item['id'].toString() == id);
      } else {
        favorites.add(id);
      }
    });
    await prefs.setStringList('favorites', favorites);
  }

  Future<void> _deleteContact(Map item) async {
    final prefs = await SharedPreferences.getInstance();
    final id = int.parse(item['id'].toString());

    try {
      final response = await http.post(
        Uri.parse("${widget.apiUrl}/delete"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        setState(() {
          data.removeWhere((c) => c['id'].toString() == id.toString());
          favorites.remove(id.toString());
        });

        await prefs.setStringList('favorites', favorites);

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
                content:
                    Text("Gagal hapus kontak (error ${response.statusCode})")),
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

  /// delete contact confirm
  void showDeleteConfirmDialog(Map item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Kontak"),
          content: Text("Yakin hapus ${item['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // langsung nutup
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                // Tutup dialog dulu
                Navigator.of(context).pop();

                // Jalankan hapus setelah dialog benar² tertutup
                Future.microtask(() {
                  _deleteContact(item);
                });
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
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
                    final isFav = favorites.contains(item['id'].toString());

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(item['name'] ?? "-"),
                        subtitle: Text(item['phone'] ?? "-"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _toggleFavorite(item['id'].toString()),
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