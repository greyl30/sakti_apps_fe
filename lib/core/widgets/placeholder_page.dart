import 'package:flutter/material.dart';

import 'app_bottom_navigation.dart';

/// Halaman placeholder reusable untuk menu yang belum diimplementasikan.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    this.bottomNavigationIndex,
  });

  final String title;
  final int? bottomNavigationIndex;

  @override
  Widget build(BuildContext context) {
    final hasBottomNavigation = bottomNavigationIndex != null;

    return Scaffold(
      appBar: hasBottomNavigation
          ? null
          : AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7A7A7A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasBottomNavigation
          ? AppBottomNavigation(currentIndex: bottomNavigationIndex!)
          : null,
    );
  }
}
