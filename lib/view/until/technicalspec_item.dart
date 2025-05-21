import 'package:flutter/material.dart';
class TechnicalSpecsItem extends StatelessWidget {
  final Map<String, String> specs;

  const TechnicalSpecsItem({super.key, required this.specs});

 IconData getIconForSpec(String key) {
  switch (key.toLowerCase()) {
    case 'thương hiệu':
      return Icons.business;
    case 'cpu':
      return Icons.memory;
    case 'ram':
      return Icons.sd_storage;
    case 'ổ cứng':
      return Icons.storage;
    case 'kích cỡ màn hình':
      return Icons.tablet_android;
    case 'hiệu năng và pin':
      return Icons.battery_charging_full;
    case 'bộ nhớ trong':
      return Icons.save;
    case 'tần số quét':
      return Icons.speed;
    case 'chip xử lý':
      return Icons.developer_board;
    default:
      return Icons.info_outline;
  }
}


  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: specs.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(getIconForSpec(e.key), size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
