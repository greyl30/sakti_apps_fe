import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Data tampilan setiap halaman onboarding
class SplashItem {
  const SplashItem({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}

// Widget konten onboarding
class SplashContent extends StatelessWidget {
  const SplashContent({super.key, required this.item});

  final SplashItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final topSpacing = (height * .15).clamp(54.0, 82.0).toDouble();
        final imageHeight = (height * .56).clamp(230.0, 285.0).toDouble();
        final imageTextGap = (height * .11).clamp(48.0, 68.0).toDouble();

        return Column(
          children: [
            SizedBox(height: topSpacing),
            SvgPicture.asset(
              item.image,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            SizedBox(height: imageTextGap),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: .75),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
