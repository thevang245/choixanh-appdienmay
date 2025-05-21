import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPriceTitle extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailPriceTitle({super.key, required this.product});

  @override
  State<DetailPriceTitle> createState() => _DetailPriceTitleState();
}

class _DetailPriceTitleState extends State<DetailPriceTitle> {
  String formatPriceToText(int price) {
    final formatter = NumberFormat.decimalPattern('vi'); // Format chuẩn VN
    return '${formatter.format(price)} đ';
  }

  @override
Widget build(BuildContext context) {
  final giaRaw = widget.product['gia'];
  
  // Nếu không có giá hoặc không phải số -> không hiển thị gì hết
  if (giaRaw == null || int.tryParse(giaRaw.toString()) == null) {
    return const SizedBox.shrink();
  }

  final giaTien = formatPriceToText(int.parse(giaRaw.toString()));

  return Padding(
    padding: const EdgeInsets.only(left: 8, right: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giá: $giaTien',
          style: const TextStyle(
            fontSize: 22,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product['tieude'] ?? 'Không có tiêu đề',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
}