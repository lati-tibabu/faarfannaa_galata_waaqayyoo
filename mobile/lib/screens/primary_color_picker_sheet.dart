import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme.dart';

class PrimaryColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onSave;

  const PrimaryColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.onSave,
  });

  @override
  State<PrimaryColorPickerSheet> createState() =>
      _PrimaryColorPickerSheetState();
}

class _PrimaryColorPickerSheetState extends State<PrimaryColorPickerSheet> {
  static const List<Color> _presetColors = [
    AppColors.primary,
    Color(0xFF2563EB), // Blue
    Color(0xFF14B8A6), // Teal
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFFA855F7), // Purple
    Color(0xFF64748B), // Slate
    Color(0xFF0F172A), // Dark
  ];

  late Color _color;
  final TextEditingController _hexController = TextEditingController();
  bool _didCommit = false;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor.withValues(alpha: 1);
    _hexController.text = colorToHex(_color, enableAlpha: false);
  }

  @override
  void dispose() {
    _commitSelection();
    _hexController.dispose();
    super.dispose();
  }

  void _setColor(Color color, {bool updateHex = true}) {
    final next = color.withValues(alpha: 1);
    setState(() => _color = next);
    if (updateHex) {
      _hexController.text = colorToHex(next, enableAlpha: false);
    }
  }

  void _commitSelection() {
    if (_didCommit) return;
    _didCommit = true;
    widget.onSave(_color.withValues(alpha: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _commitSelection(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        _commitSelection();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      'Primary Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _setColor(AppColors.primary),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          colorToHex(_color, enableAlpha: false),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: primary.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                        ),
                        child: Text(
                          'Live preview',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Presets',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                BlockPicker(
                  pickerColor: _color,
                  onColorChanged: (c) => _setColor(c),
                  availableColors: _presetColors,
                  layoutBuilder: (context, colors, child) {
                    final crossAxisCount = width >= 430 ? 8 : 6;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [for (final c in colors) child(c)],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                ColorPicker(
                  pickerColor: _color,
                  onColorChanged: (c) => _setColor(c, updateHex: false),
                  paletteType: PaletteType.hueWheel,
                  enableAlpha: false,
                  displayThumbColor: true,
                  hexInputBar: true,
                  hexInputController: _hexController,
                  labelTypes: const [ColorLabelType.hex],
                  colorPickerWidth: width - 32,
                  pickerAreaHeightPercent: 0.7,
                  portraitOnly: true,
                  pickerAreaBorderRadius: BorderRadius.circular(18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
