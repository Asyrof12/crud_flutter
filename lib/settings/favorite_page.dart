import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:card/providers/AppLanguage.dart';

class FavoritPage extends StatefulWidget {
  final String apiUrl;
  const FavoritPage({Key? key, required this.apiUrl}) : super(key: key);

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;
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
    final lang = Provider.of<AppLanguage>(context, listen: false);

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
        data = list.where(_isFav).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        data = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.getText("failed_load"))),
      );
    }
  }

  Future<void> _deleteContact(Map item) async {
    final id = _toInt(item['id']);
    final lang = Provider.of<AppLanguage>(context, listen: false);

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
              content: Text(
                "${lang.getText("contact_deleted")}: ${item['name']}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${lang.getText("failed_delete")} (${response.statusCode})",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${lang.getText("error_msg")}: $e"),
          ),
        );
      }
    }
  }

  void showDeleteConfirmDialog(Map item) {
    final lang = Provider.of<AppLanguage>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText("confirm_delete")),
          content: Text("${lang.getText("delete_contact_q")}: ${item['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText("cancel")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.microtask(() => _deleteContact(item));
              },
              child: Text(lang.getText("delete_contact")),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleUnfavourite(int id) async {
    if (_pending.contains(id)) return;
    setState(() => _pending.add(id));
    final lang = Provider.of<AppLanguage>(context, listen: false);

    try {
      final url = "${widget.apiUrl}/favourite";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'is_favourite': 0}),
      );

      if (response.statusCode == 200) {
        setState(() {
          data.removeWhere((c) => _toInt(c['id']) == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lang.getText("contact_deleted"))),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${lang.getText("failed_edit")} (${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${lang.getText("error_msg")}: $e")),
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
    final lang = Provider.of<AppLanguage>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(lang.getText("favorit"))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(child: Text(lang.getText("no_data")))
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
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: _pending.contains(id) ? null : () => _toggleUnfavourite(id),
                              tooltip: lang.getText("remove_from_fav"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDeleteConfirmDialog(item),
                              tooltip: lang.getText("delete_contact"),
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
