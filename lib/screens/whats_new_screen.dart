import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WhatsNewScreen extends StatelessWidget {
  final VoidCallback? onClose;
  final String? versionLabel;

  const WhatsNewScreen({super.key, this.onClose, this.versionLabel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text("What's New"), centerTitle: true),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final appVersion =
              versionLabel ??
              (snapshot.hasData
                  ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                  : '');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appVersion.isEmpty
                          ? 'Latest release'
                          : 'Version $appVersion',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FeatureRow(
                      icon: Icons.palette_outlined,
                      text:
                          'New primary color picker with preset and custom wheel.',
                    ),
                    const _FeatureRow(
                      icon: Icons.folder_open,
                      text: 'Collections are now in the bottom navigation.',
                    ),
                    const _FeatureRow(
                      icon: Icons.rocket_launch_outlined,
                      text: 'Onboarding runs only on first install.',
                    ),
                    const _FeatureRow(
                      icon: Icons.spa_outlined,
                      text: 'Refined top bar and navigation styling updates.',
                    ),
                    const _FeatureRow(
                      icon: Icons.visibility_outlined,
                      text:
                          'Accessibility, language, and lyrics settings added.',
                    ),
                  ],
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
