import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class favouritePage extends StatefulWidget {
  const favouritePage({super.key});

  @override
  State<favouritePage> createState() => favouritePageState();
}

class favouritePageState extends State<favouritePage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> favouriteItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Bắt lifecycle
    loadUserAndFavourites();
    reloadFavourites();
  }

  Future<void> reloadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('userid') ?? '';
    final key = 'favourite_items_$user';
    final items = prefs.getStringList(key) ?? [];

    final List<Map<String, dynamic>> loadedItems = [];

    for (var itemStr in items) {
      try {
        final itemMap = json.decode(itemStr);
        loadedItems.add(itemMap);
      } catch (_) {}
    }

    setState(() {
      favouriteItems = loadedItems;
    });
  }

  Future<void> loadUserAndFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'favourite_items_${Global.userId}';
    final items = prefs.getStringList(key) ?? [];

    final List<Map<String, dynamic>> loadedItems = [];

    for (var itemStr in items) {
      try {
        final itemMap = json.decode(itemStr);
        loadedItems.add(itemMap);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: favouriteItems.isEmpty
          ? const Center(child: Text('Chưa có sản phẩm yêu thích'))
          : ListView.builder(
              itemCount: favouriteItems.length,
              itemBuilder: (context, index) {
                final item = favouriteItems[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.network(
                          item['hinhdaidien'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 60),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['tieude']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['gia']} VNĐ',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
