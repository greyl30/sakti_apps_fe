import 'package:flutter/material.dart';

// Page indicator onboarding dengan animasi smooth
class SplashIndicator extends StatelessWidget {
  const SplashIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 28 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF9EA4AF) : const Color(0xFFD2D6DD),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
