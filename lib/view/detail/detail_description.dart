import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;

class DetailHtmlContent extends StatelessWidget {
  final String? htmlContent;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggle;

  const DetailHtmlContent({
    super.key,
    required this.htmlContent,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggle,
  });

  /// An toàn hơn: nếu null hoặc lỗi sẽ trả về "Không có nội dung"
  String _safeShortenHtml(String? html, int maxLength) {
    print("HTML Content: $htmlContent");

    if (html == null || html.trim().isEmpty) return "<p>Không có nội dung</p>";
    try {
      final document = html_parser.parse(html);
      final text = document.body?.text ?? '';
      if (text.length <= maxLength) return html;
      final truncatedText = text.substring(0, maxLength) + "...";
      return "<p>$truncatedText</p>";
    } catch (e) {
      return "<p>Lỗi phân tích nội dung</p>";
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final safeHtmlContent = htmlContent?.trim().isNotEmpty == true
        ? htmlContent!
        : "<p>Không có nội dung</p>";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Html(
            data: isExpanded
                ? safeHtmlContent
                : _safeShortenHtml(safeHtmlContent, 300),
            style: {
              "body": Style(
                fontSize: FontSize(16.0),
                color: Colors.black,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(color: Color(0xff0066FF), fontSize: 15),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xff0066FF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
