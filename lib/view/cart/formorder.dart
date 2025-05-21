import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/allpage.dart';
import 'package:flutter_application_1/widgets/button_widget.dart';
import 'package:flutter_application_1/widgets/input_widget.dart';

class OrderConfirmationSheet extends StatefulWidget {
  final TextEditingController fullnameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final String tongThanhToan;
  final VoidCallback onConfirm;
  final BuildContext parentContext;

  const OrderConfirmationSheet({
    super.key,
    required this.fullnameController,
    required this.phoneController,
    required this.emailController,
    required this.tongThanhToan,
    required this.onConfirm,
    required this.parentContext
  });

  @override
  State<OrderConfirmationSheet> createState() => _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState extends State<OrderConfirmationSheet> {
  
 void _handleConfirm() {
  if (widget.fullnameController.text.trim().isEmpty ||
      widget.phoneController.text.trim().isEmpty ||
      widget.emailController.text.trim().isEmpty) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
    );
    return;
  }

  widget.onConfirm();
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Xác nhận đặt hàng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Họ và tên',
            controller: widget.fullnameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Số điện thoại',
            controller: widget.phoneController,
            icon: Icons.phone,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Email',
            controller: widget.emailController,
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          Text('Bạn có chắc chắn muốn đặt hàng với tổng tiền ${widget.tongThanhToan} không?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                      backgroundColor: Colors.grey[300]),
                  child: const Text('Hủy',style: TextStyle(color: Colors.black),),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                      backgroundColor: Color(0xff0066FF)),
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
