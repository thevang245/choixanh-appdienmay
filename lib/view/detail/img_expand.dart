import 'package:flutter/material.dart';

class FullScreenGalleryViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGalleryViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController _pageController =
        PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    panEnabled: true,
                    scaleEnabled: true,
                    boundaryMargin: EdgeInsets.all(20),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
