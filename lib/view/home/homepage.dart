import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/components/product_card.dart';
import 'package:flutter_application_1/view/contact/contact.dart';
import 'package:flutter_application_1/view/detail/detail_page.dart';
import 'package:flutter_application_1/view/drawer/category_drawer.dart';
import 'package:flutter_application_1/view/until/technicalspec_item.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/button_widget.dart';
import 'package:flutter_application_1/widgets/input_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<int> categoryNotifier;
  final Function(dynamic product) onProductTap;

  const HomePage(
      {super.key, required this.categoryNotifier, required this.onProductTap});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _categoryId = 0;
  List<dynamic> products = [];
  bool isLoading = true;
  late final VoidCallback _listener;

  // Lấy danh mục từ DanhMucDrawer một lần duy nhất
  late final Map<String, dynamic> danhMucData;

  @override
  void initState() {
    super.initState();
    loadLoginStatus();
    danhMucData = DanhMucDrawer(onCategorySelected: (_) {}).danhMucData;
    _categoryId = widget.categoryNotifier.value;
    fetchProducts();

    _listener = () {
      if (!mounted) return;
      setState(() {
        _categoryId = widget.categoryNotifier.value;
        isLoading = true;
      });
      fetchProducts();
    };
    widget.categoryNotifier.addListener(_listener);
  }

  Future<void> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('userid') ?? '';
    setState(() {
      Global.userId = user;
    });
  }

  Future<void> fetchProducts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> allProducts = [];

      if (_categoryId == 0) {
        final danhMucChaIds = [
          35279,
          35278,
          35280,
          35283,
          35004,
          35139,
          35149,
          35028
        ];

        for (int id in danhMucChaIds) {
          final modules = categoryModules[id];
          if (modules == null) continue;

          final fetched = await APIService.fetchProductsByCategory(
            ww2: modules[0],
            product: modules[1],
            extention: modules[2],
            categoryId: id,
          );

          allProducts.addAll(fetched);
        }
      } else {
        final modules = categoryModules[_categoryId];
        if (modules == null) {
          setState(() {
            products = [];
            isLoading = false;
          });
          return;
        }

        allProducts = await APIService.fetchProductsByCategory(
          ww2: modules[0],
          product: modules[1],
          extention: modules[2],
          categoryId: _categoryId,
        );
      }

      if (!mounted) return;

      setState(() {
        products = allProducts;
        isLoading = false;
        hasValidImage(products);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String findCategoryNameById(Map<String, dynamic> data, int id) {
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is int) {
        if (value == id) {
          return key;
        }
      } else if (value is Map) {
        if (value['id'] == id) {
          return key;
        }
        if (value.containsKey('children')) {
          final nameInChildren = findCategoryNameById(value['children'], id);
          if (nameInChildren.isNotEmpty) return nameInChildren;
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Trường hợp không có dữ liệu
    if (products.isEmpty && _categoryId != 35028) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Text(
            'Không có dữ liệu',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // 👉 THÊM: Trường hợp categoryId = 3 thì hiển thị form
    if (_categoryId == 35028) {
      return ContactForm();
    }

    // Trường hợp categoryId = 0: nhóm sản phẩm theo danh mục
    if (_categoryId == 0) {
      Map<int, List<dynamic>> groupedByCategory = {};
      for (var product in products) {
        int catId = product['categoryId'] ?? 0;
        groupedByCategory.putIfAbsent(catId, () => []).add(product);
      }

      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: groupedByCategory.entries.map((entry) {
              final categoryId = entry.key;
              final productList = entry.value.where((product) {
                if (categoryId == 35004) return true;
                return hasValidImage(product);
              }).toList();

              if (productList.isEmpty) return SizedBox.shrink();

              final categoryName =
                  findCategoryNameById(danhMucData, categoryId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    categoryName.isNotEmpty
                        ? categoryName
                        : 'Danh mục $categoryId',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  MasonryGridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return ProductCard(
                        product: product,
                        categoryId: categoryId,
                        onTap: () => widget.onProductTap(product),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }

    // Trường hợp các category khác
    final visibleProducts = products.where((product) {
      if (_categoryId == 35004) return true;
      return hasValidImage(product);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: visibleProducts.isEmpty
          ? Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                itemCount: visibleProducts.length,
                itemBuilder: (context, index) {
                  final product = visibleProducts[index];
                  return ProductCard(
                    product: product,
                    categoryId: _categoryId,
                    onTap: () => widget.onProductTap(product),
                  );
                },
              ),
            ),
    );
  }
}

class Global {
  static String userId = '';
}
