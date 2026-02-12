import 'package:flutter/material.dart';
import 'asset_text_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AssetTextScreen(
      title: 'Privacy Policy',
      assetPath: 'assets/legal/privacy_policy.txt',
    );
  }
}
