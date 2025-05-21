import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarthistoryPage extends StatefulWidget {
  const CarthistoryPage({super.key});

  @override
  State<CarthistoryPage> createState() => CarthistoryPageState();
}

class CarthistoryPageState extends State<CarthistoryPage> {
  List<CartItemModel> orderHistory = [];

  @override
  void initState() {
    super.initState();
    loadOrderHistory();
  }

  Future<void> loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'order_history_${Global.userId}';
    final data = prefs.getStringList(key) ?? [];

    print('🔍 Dữ liệu lịch sử mua hàng ($key):');
    for (var item in data) {
      print(item); // log từng JSON string
    }

    setState(() {
      orderHistory =
          data.map((e) => CartItemModel.fromJson(jsonDecode(e))).toList();
    });

    print('✅ Số lượng item đã load: ${orderHistory.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        title: Text(
          'Lịch sử mua hàng',
          style: TextStyle(
            color: Color(0xff0066FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orderHistory.isEmpty
          ? Center(child: Text('Chưa có đơn hàng nào.'))
          : ListView.builder(
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final item = orderHistory[index];
                print(
                    '🖼️ item.image: ${item.image} (${item.image.runtimeType})');

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Image.network(
                        item.image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.name}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${item.price}',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 15),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xff0066FF),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                      14,
                                    )),
                                  ),
                                  child: Text(
                                    'Mua lại',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
