import 'package:flutter/material.dart';
import '../theme.dart';

class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'HYMN 142',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 2,
              ),
            ),
            const Text(
              'Waaqayyoon Galateeffadhaa',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Player Placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x1FFF7A00),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Play Melody (Coming Soon)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Lyrics
            _LyricSection(
              label: 'VERSE 1',
              content: [
                'Waaqayyoon galateeffadhaa,',
                'Inni gaarii dha,',
                'Araarri isaas barabaraaf,',
                'Hamma bara baraatti.',
              ],
            ),

            _LyricSection(
              label: 'CHORUS',
              isChorus: true,
              content: [
                'Galanni kan Waaqayyoo ti,',
                'Inni guddaa dha,',
                'Hojiin isaas dinqii dha,',
                'Nuyi hundumaaf.',
              ],
            ),

            _LyricSection(
              label: 'VERSE 2',
              content: [
                'Humna isaa guddichaan,',
                'Bantiiwwan waaqaa uume,',
                'Addunyaa kana hundumaa,',
                'Ogummaa isaan tole.',
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(icon: Icons.favorite_border, label: 'Favorite'),
            _VerticalDivider(),
            _ActionButton(icon: Icons.ios_share, label: 'Share'),
            _VerticalDivider(),
            _ActionButton(icon: Icons.content_copy, label: 'Copy'),
          ],
        ),
      ),
    );
  }
}

class _LyricSection extends StatelessWidget {
  final String label;
  final List<String> content;
  final bool isChorus;

  const _LyricSection({
    required this.label,
    required this.content,
    this.isChorus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: isChorus ? const EdgeInsets.all(24) : EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 40),
      decoration: isChorus
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ...content.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: isChorus ? FontWeight.bold : FontWeight.w500,
                  fontStyle: isChorus ? FontStyle.italic : FontStyle.normal,
                  color: isChorus
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white10);
  }
}
