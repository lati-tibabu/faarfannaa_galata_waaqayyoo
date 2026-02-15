import 'package:flutter/material.dart';
import 'asset_text_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AssetTextScreen(
      title: 'Terms',
      assetPath: 'assets/legal/terms.txt',
    );
  }
}
