import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/auth/register.dart';
import 'package:flutter_application_1/view/cart/cart_page.dart';
import 'package:flutter_application_1/view/components/bottom_appbar.dart';
import 'package:flutter_application_1/view/detail/bottom_bar.dart';
import 'package:flutter_application_1/view/detail/detail_description.dart';
import 'package:flutter_application_1/view/detail/detail_imggallery.dart';
import 'package:flutter_application_1/view/detail/detail_pricetitle.dart';
import 'package:flutter_application_1/view/detail/specs_data.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/profile/profile.dart';
import 'package:flutter_application_1/view/until/technicalspec_detail.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final String productId;
  final ValueNotifier<int> categoryNotifier;
  final VoidCallback? onBack;

  const DetailPage(
      {super.key,
      required this.productId,
      required this.categoryNotifier,
      this.onBack});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? selectedImageUrl;
  String? htmlContent;
  bool isLoadingHtml = true;
  bool isExpanded = false;
  Map<String, dynamic>? productDetail;
  bool isLoading = true;
  bool isBackVisible = true;
  final ScrollController _scrollController = ScrollController();

  String _userid = '';
  String _pass = '';

  Future<void> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString('userid') ?? '';
    String pass = prefs.getString('pass') ?? '';

    setState(() {
      _userid = userid;
      _pass = pass;
    });
  }

  final ValueNotifier<int> categoryNotifier = ValueNotifier(35278);

  String getModuleNameFromCategoryId(int categoryId) {
    if (categoryModules.containsKey(categoryId)) {
      final moduleParts = categoryModules[categoryId];
      if (moduleParts != null && moduleParts.length >= 3) {
        return moduleParts[1]; // Lấy 'sanpham' hoặc 'tintuc'
      }
    }
    return 'sanpham'; // fallback nếu không có
  }

  // Hàm lấy chi tiết sản phẩm từ API
  Future<void> fetchProductDetail(String moduleType) async {
    print('categoryId: ${categoryNotifier.value}');
    final int productId = int.tryParse(widget.productId.toString()) ?? 0;
    print('Fetching product details from ID: $productId');
    final String url =
        'https://choixanh.com.vn/ww2/module.$moduleType.chitiet.asp?id=$productId';
    print('Fetching product details from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String responseBody = response.body;
        responseBody = responseBody.replaceAll(RegExp(r',\s*,\s*'), ',');
        responseBody =
            responseBody.replaceAll(RegExp(r',\s*(?=\s*[\}\]])'), '');
        responseBody = responseBody.replaceAll(RegExp(r',\s*$'), '');
        print('Sanitized response: $responseBody'); // In ra để kiểm tra

        try {
          // Kiểm tra xem dữ liệu có phải là mảng hay không
          final data = json.decode(responseBody);

          if (data is List && data.isNotEmpty) {
            final detail = data.first;
            final hinhAnhs = getDanhSachHinh(detail);

            setState(() {
              productDetail = detail;
              isLoading = false;
              selectedImageUrl = hinhAnhs.isNotEmpty ? hinhAnhs[0] : null;
            });
          } else {
            print('Không có dữ liệu hoặc không phải danh sách');
          }
        } catch (e) {
          print('Lỗi khi phân tích cú pháp JSON: $e');
        }
      } else {
        throw Exception('Lỗi khi tải chi tiết sản phẩm');
      }
    } catch (e) {
      print('Lỗi API: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchHtmlContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          htmlContent = response.body;
          isLoadingHtml = false;
        });
      } else {
        htmlContent = "<p>Không thể tải nội dung chi tiết.</p>";
      }
    } catch (e) {
      htmlContent = "<p>Lỗi tải nội dung: $e</p>";
    } finally {
      setState(() {
        isLoadingHtml = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final moduleType =
        getModuleNameFromCategoryId(widget.categoryNotifier.value);
    fetchProductDetail(moduleType);
    loadLoginStatus();

    final htmlUrl =
        'https://choixanh.com.vn/ww2/module.$moduleType.chitiet.asp?id=${widget.productId}&sl=30&pageid=1';
    if (htmlUrl.startsWith('http')) {
      fetchHtmlContent(htmlUrl);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isBackVisible) setState(() => isBackVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isBackVisible) setState(() => isBackVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Đang tải...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final product = productDetail ?? {};
    final hinhAnhs = getDanhSachHinh(product);
    final String title = product['tieude'] ?? 'Sản phẩm chưa có tên';
    final String price = product['gia'] ?? 'Chưa có giá';
    final String description = product['noidungchitiet'] ?? 'Không có mô tả';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 55, top: 0),
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // để trống phần appbar
                    if (hinhAnhs.isNotEmpty)
                      DetailImageGallery(
                        images: hinhAnhs,
                        onImageSelected: (url) {
                          setState(() => selectedImageUrl = url);
                        },
                      ),
                    const SizedBox(height: 16),
                    DetailPriceTitle(product: product),
                    DetailHtmlContent(
                      htmlContent: description,
                      isLoading: isLoadingHtml,
                      isExpanded: isExpanded,
                      onToggle: () => setState(() => isExpanded = !isExpanded),
                    ),
                    const SizedBox(height: 8),
                    TechnicalSpecs(
                      specs: {
                        for (var entry in productSpecsMapping)
                          entry.key: getNestedTengoi(product, entry.value)
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Transparent AppBar with back button
          SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isBackVisible ? 1.0 : 0.0,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.black.withOpacity(0.5)),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.black.withOpacity(0.5)),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        onPressed: () async {
                          await APIService.toggleFavourite(
                              context: context,
                              userId: _userid,
                              productId: int.tryParse(widget.productId) ?? 0,
                              tieude: product['tieude'],
                              gia: product['gia'],
                              hinhdaidien:
                                  'https://choixanh.com.vn/${product['hinhdaidien']}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom bar
          if ((productDetail?['gia'] ?? '').toString().trim().isNotEmpty &&
              hinhAnhs.isNotEmpty)
            BottomActionBar(
              tieude: product['tieude'],
              gia: product['gia'],
              hinhdaidien: product['hinhdaidien'],
              productId: int.tryParse(widget.productId) ?? 0,
              userId: _userid,
              passwordHash: _pass,
            )
        ],
      ),
    );
  }
}
