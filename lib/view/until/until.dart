import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';

String getNestedTengoi(Map<String, dynamic> product, String key) {
  final list = product[key];
  if (list is List && list.isNotEmpty) {
    return list[0]['tengoi'] ?? '';
  }
  return '';
}

String buildImageUrl(String url) {
  const String baseUrl = APIService.baseUrl;
  return (url.startsWith('http://') || url.startsWith('https://'))
      ? url
      : baseUrl + url;
}

bool isImageUrl(String url) {
  return url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.png') ||
      url.endsWith('.gif');
}

List<String> getDanhSachHinh(dynamic product) {
  const String baseUrl = APIService.baseUrl;
  List<String> imageList = [];

  if (product == null) return [];

  // 1. Hình đại diện
  String? daiDienUrl;
  final dynamic hinhDaiDien = product['hinhdaidien'];
  if (hinhDaiDien != null && hinhDaiDien.toString().isNotEmpty) {
    final String url = hinhDaiDien.toString();
    if (isImageUrl(url)) {
      daiDienUrl = buildImageUrl(url);
      imageList.add(daiDienUrl);
    }
  }

  // 2. Hình liên quan
  final dynamic rawHinhanh = product['hinhlienquan'];

  if (rawHinhanh is List) {
    // Nếu là List<Map>
    for (var item in rawHinhanh) {
      String? url;
      if (item is Map && item['hinhdaidien'] != null) {
        url = item['hinhdaidien'].toString();
      }

      if (url != null && isImageUrl(url)) {
        final fullUrl = buildImageUrl(url);
        if (fullUrl != daiDienUrl) {
          imageList.add(fullUrl);
        }
      }
    }
  } else if (rawHinhanh is String) {
    // Nếu là chuỗi: "image1.jpg,image2.jpg"
    final parts = rawHinhanh.split(RegExp(r'[;,]'));
    for (var part in parts) {
      final url = part.trim();
      if (url.isNotEmpty && isImageUrl(url)) {
        final fullUrl = buildImageUrl(url);
        if (fullUrl != daiDienUrl) {
          imageList.add(fullUrl);
        }
      }
    }
  }

  return imageList;
}

bool hasValidImage(dynamic product) {
  final hinh = product['hinhdaidien'];
  final hinhanh = product['hinhanh'];

  return !(hinh == null || hinh.toString().isEmpty) ||
      !(hinhanh == null || !(hinhanh is List) || hinhanh.isEmpty);
}

void showNotification(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(message, style: TextStyle(color: Colors.white),),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
