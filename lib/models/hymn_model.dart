class Hymn {
  final int number;
  final String title;
  final List<HymnSection> sections;

  Hymn({required this.number, required this.title, required this.sections});

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      number: json['number'] as int,
      title: json['title'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => HymnSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HymnSection {
  final String type; // INT, VRS, CHR, OTR
  final List<String> lines;

  HymnSection({required this.type, required this.lines});

  factory HymnSection.fromJson(Map<String, dynamic> json) {
    return HymnSection(
      type: json['type'] as String,
      lines: List<String>.from(json['lines'] as List<dynamic>),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'INT':
        return 'Seensa';
      case 'VRS':
        return 'Boqonnaa';
      case 'CHR':
        return 'Faarfannaa';
      default:
        return '';
    }
  }
}
