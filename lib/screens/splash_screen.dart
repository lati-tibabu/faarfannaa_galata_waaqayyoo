import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatelessWidget {
  final double progress;
  const SplashScreen({super.key, this.progress = 0.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          gradient: RadialGradient(
            center: const Alignment(-1.0, -1.0),
            radius: 1.5,
            colors: [
              const Color(0x1FEE7A00),
              isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background mesh decorations
            Positioned(
              top: 100,
              left: 50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.auto_awesome,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.church,
                  size: 120,
                  color: isDark ? AppColors.secondary : Colors.grey,
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.6)
                            : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.grey.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Faarfannaa',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Galata Waaqayyoo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HYMNS OF PRAISE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  // Loading Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Loading hymns... ${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Offline Mode',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '© 2025 CodeLabs Apps',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
