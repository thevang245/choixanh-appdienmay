import 'package:flutter/material.dart';

class TechnicalSpecs extends StatelessWidget {
  final Map<String, String> specs;

  const TechnicalSpecs({super.key, required this.specs});

  @override
Widget build(BuildContext context) {
  // Lọc các thông số không rỗng
  final validSpecs = specs.entries.where((e) => e.value.isNotEmpty).toList();

  // Nếu không có thông số nào hợp lệ thì không hiển thị gì
  if (validSpecs.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: Colors.grey[200],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông số kỹ thuật',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: validSpecs
              .map((e) => TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${e.key}:',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child:
                          Text(e.value, style: const TextStyle(fontSize: 17)),
                    ),
                  ]))
              .toList(),
        ),
      ],
    ),
  );
}

}