import 'package:flutter/material.dart';

class SettingItemCard extends StatelessWidget {
  final IconData icon;
  final IconData? iconRight;
  final String title;
  final VoidCallback? onTap;

  const SettingItemCard({
    super.key,
    required this.icon,
    this.iconRight,
    required this.title,
    this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.white, // ⬅️ Đảm bảo có màu nền để thấy ripple
        child: InkWell(
          onTap: onTap ?? () {}, // Tránh null gây lỗi
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                 Icon(iconRight, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
